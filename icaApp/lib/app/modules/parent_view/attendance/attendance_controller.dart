import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/attendance_record.dart';
import '../../dashboard/dashboard_controller.dart';

class AttendanceController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  // Map of studentId -> list of attendance records
  RxMap<String, List<AttendanceRecord>> attendanceMap = <String, List<AttendanceRecord>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      final studentIds = _dashboardController.students.map((s) => s.id).toList();

      if (studentIds.isEmpty) {
        attendanceMap.clear();
        return;
      }

      final response = await _client
          .from('attendance_records')
          .select('*')
          .inFilter('student_id', studentIds)
          .order('class_date', ascending: false);

      final List<AttendanceRecord> records = (response as List)
          .map((data) => AttendanceRecord.fromJson(data as Map<String, dynamic>))
          .toList();

      // Group by student_id
      final Map<String, List<AttendanceRecord>> grouped = {};
      for (var id in studentIds) {
        grouped[id] = [];
      }
      for (var record in records) {
        grouped[record.studentId]?.add(record);
      }

      attendanceMap.assignAll(grouped);
    } catch (e) {
      Get.snackbar('Error Loading Attendance', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  int getPresentCount(String studentId) {
    final list = attendanceMap[studentId] ?? [];
    return list.where((r) => r.status.toLowerCase() == 'present').length;
  }

  int getAbsentCount(String studentId) {
    final list = attendanceMap[studentId] ?? [];
    return list.where((r) => r.status.toLowerCase() == 'absent').length;
  }

  double getAttendancePercentage(String studentId) {
    final list = attendanceMap[studentId] ?? [];
    if (list.isEmpty) return 100.0;
    final present = getPresentCount(studentId);
    return (present / list.length) * 100;
  }
}
