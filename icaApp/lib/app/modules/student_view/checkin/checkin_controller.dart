import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/geofence_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../dashboard/dashboard_controller.dart';

enum CheckinStatus { idle, requesting, locating, syncing, success, failed }

class CheckinController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;

  Rx<CheckinStatus> status = CheckinStatus.idle.obs;
  RxString statusMessage = ''.obs;
  RxBool geofenceVerified = false.obs;
  RxDouble distanceFromAcademy = 0.0.obs;
  RxBool isManualMode = false.obs;

  /// Entry point for the check-in flow.
  ///
  /// [forceManual] skips location check (user chose Skip on disclosure screen).
  Future<void> checkIn({required bool forceManual}) async {
    final dashCtrl = Get.find<DashboardController>();
    final student = dashCtrl.selectedStudent.value;

    if (student == null) {
      Get.snackbar('No Student Selected',
          'Please select a student profile before checking in.');
      return;
    }

    // Find the student's batch
    String batchId = '';
    try {
      final batchRes = await _client
          .from('batch_students')
          .select('batch_id')
          .eq('student_id', student.id)
          .maybeSingle();
      batchId = batchRes?['batch_id'] as String? ?? '';
    } catch (_) {
      batchId = '';
    }

    if (batchId.isEmpty && student.batchId != null) {
      batchId = student.batchId!;
    }

    if (batchId.isEmpty) {
      Get.snackbar(
        'No Batch Assigned',
        'Student "${student.name}" is not assigned to any batch. Attendance check-in is only possible for students in a batch.',
      );
      return;
    }

    if (forceManual || isManualMode.value) {
      await _performManualCheckin(student.id, batchId);
      return;
    }

    await _performGeofenceCheckin(student.id, batchId);
  }

  /// Geofence-based check-in.
  Future<void> _performGeofenceCheckin(
      String studentId, String batchId) async {
    try {
      // Step 1: Check permission
      status.value = CheckinStatus.requesting;
      statusMessage.value = 'Checking location permission...';

      var permission = await GeofenceService.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await GeofenceService.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        // Show rationale and offer settings
        isManualMode.value = true;
        Get.snackbar(
          'Location Denied',
          'Location permission is needed for geofence check-in. Using manual mode.',
        );
        await _performManualCheckin(studentId, batchId);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        isManualMode.value = true;
        Get.defaultDialog(
          title: 'Location Permission',
          middleText:
              'Location permission was permanently denied. Please enable it in Settings to use geofence check-in.',
          textConfirm: 'Open Settings',
          textCancel: 'Manual Check-in',
          onConfirm: () async {
            Get.back();
            await GeofenceService.openSettings();
          },
          onCancel: () => _performManualCheckin(studentId, batchId),
        );
        return;
      }

      // Step 2: Get position
      status.value = CheckinStatus.locating;
      statusMessage.value = 'Getting your location...';

      final position = await GeofenceService.getCurrentPosition();
      final distance = GeofenceService.distanceFromAcademy(position);
      distanceFromAcademy.value = distance;

      // Step 3: Evaluate geofence
      final verified = GeofenceService.isWithinGeofence(position);
      geofenceVerified.value = verified;

      if (kDebugMode) {
        debugPrint('[Checkin] Distance: ${distance.toStringAsFixed(1)}m, Verified: $verified');
      }

      // Step 4: Write geofence log to drift (immediately)
      await GeofenceService.writeGeofenceLog(
        studentId: studentId,
        position: position,
        eventType: verified ? 'enter' : 'manual',
      );

      // Step 5: Sync attendance to Supabase
      await _upsertAttendance(
        studentId: studentId,
        batchId: batchId,
        geofenceVerified: verified,
      );

      status.value = CheckinStatus.success;
      final distanceText = distance.toStringAsFixed(0);
      statusMessage.value = verified
          ? 'Checked in ✓ (Geofence verified)'
          : 'Checked in (Manual — not at academy). You are ${distanceText}m away.';
    } catch (e) {
      status.value = CheckinStatus.failed;
      statusMessage.value = 'Check-in failed: ${e.toString()}';
      if (kDebugMode) debugPrint('[Checkin] Error: $e');
    }
  }

  /// Manual check-in (no geofence verification).
  Future<void> _performManualCheckin(String studentId, String batchId) async {
    try {
      status.value = CheckinStatus.syncing;
      statusMessage.value = 'Recording manual check-in...';
      geofenceVerified.value = false;

      await _upsertAttendance(
        studentId: studentId,
        batchId: batchId,
        geofenceVerified: false,
      );

      status.value = CheckinStatus.success;
      statusMessage.value = 'Checked in (Manual — location not verified)';
    } catch (e) {
      status.value = CheckinStatus.failed;
      statusMessage.value = 'Check-in failed: ${e.toString()}';
    }
  }

  /// Write attendance to Supabase and update drift cache.
  Future<void> _upsertAttendance({
    required String studentId,
    required String batchId,
    required bool geofenceVerified,
  }) async {
    status.value = CheckinStatus.syncing;
    statusMessage.value = 'Saving attendance...';

    final today = DateTime.now().toIso8601String().split('T')[0];

    // Upsert to Supabase attendance_records
    final result = await _client.from('attendance_records').upsert({
      'student_id': studentId,
      'batch_id': batchId.isNotEmpty ? batchId : null,
      'class_date': today,
      'status': 'present',
      'geofence_verified': geofenceVerified,
    }, onConflict: 'student_id,batch_id,class_date').select().maybeSingle();

    // Update drift CachedAttendance
    final db = Get.find<AppDatabase>();
    await db.upsertAttendance(
      CachedAttendanceCompanion.insert(
        id: result?['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        batchId: batchId,
        classDate: today,
        status: drift.Value('present'),
        geofenceVerified: drift.Value(geofenceVerified),
      ),
    );
  }

  void reset() {
    status.value = CheckinStatus.idle;
    statusMessage.value = '';
    geofenceVerified.value = false;
    distanceFromAcademy.value = 0.0;
  }
}
