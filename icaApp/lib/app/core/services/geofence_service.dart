import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../utils/uuid_generator.dart';

/// Academy geofence configuration — Parul University, Vadodara
class AcademyGeofence {
  static const double lat = 22.2678;
  static const double lng = 73.1433;
  static const double radiusMeters = 200.0;
}

/// Service for geofence-based attendance check-in.
///
/// Uses geolocator for a one-shot manual check on "Check In" tap.
/// No background geofencing required.
class GeofenceService {
  GeofenceService._();

  // ─── Permission Helpers ───

  /// Check current location permission status.
  static Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  /// Request location permission (when-in-use).
  static Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// Open device location settings (when permanently denied).
  static Future<bool> openSettings() => Geolocator.openLocationSettings();

  // ─── Position ───

  /// Get current device position with high accuracy.
  static Future<Position> getCurrentPosition() =>
      Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

  // ─── Geofence Calculation ───

  /// Returns distance in metres from [pos] to the academy.
  static double distanceFromAcademy(Position pos) {
    return Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      AcademyGeofence.lat,
      AcademyGeofence.lng,
    );
  }

  /// Returns true if [pos] is within the 200m academy geofence.
  static bool isWithinGeofence(Position pos) {
    return distanceFromAcademy(pos) <= AcademyGeofence.radiusMeters;
  }

  // ─── Drift — Write-first logging ───

  /// Write a geofence log to drift immediately (offline-safe).
  /// Returns the log ID.
  static Future<String> writeGeofenceLog({
    required String studentId,
    required Position position,
    required String eventType, // 'enter' | 'exit' | 'manual'
  }) async {
    final db = Get.find<AppDatabase>();
    final id = UuidGenerator.generate();

    await db.insertGeofenceLog(
      GeofenceLogsCompanion.insert(
        id: id,
        studentId: studentId,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        eventType: drift.Value(eventType),
        timestamp: DateTime.now().toIso8601String(),
      ),
    );

    // Attempt sync immediately (non-blocking)
    syncPendingLogs().catchError((e) {
      if (kDebugMode) debugPrint('[GeofenceService] Sync error: $e');
    });

    return id;
  }

  // ─── Supabase Sync ───

  /// Upload unsynced geofence logs to Supabase geofence_logs table.
  /// Called on foreground restore and after each new log entry.
  static Future<void> syncPendingLogs() async {
    try {
      final db = Get.find<AppDatabase>();
      final unsynced = await db.getUnsyncedGeofenceLogs();

      if (unsynced.isEmpty) return;

      final client = Supabase.instance.client;

      for (final log in unsynced) {
        await client.from('geofence_logs').upsert({
          'id': log.id,
          'student_id': log.studentId,
          'lat': log.lat,
          'lng': log.lng,
          'accuracy': log.accuracy,
          'event_type': log.eventType,
          'timestamp': log.timestamp,
        });

        await db.markGeofenceLogSynced(log.id);

        if (kDebugMode) {
          debugPrint('[GeofenceService] Synced log ${log.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GeofenceService] syncPendingLogs error: $e');
      }
      // Retry will happen on next foreground / next check-in
    }
  }
}
