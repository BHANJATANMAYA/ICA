import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/schedule.dart';
import '../../dashboard/dashboard_controller.dart';

class ScheduleController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<Schedule> schedules = <Schedule>[].obs;
  RealtimeChannel? _scheduleSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
    subscribeToSchedules();
    
    // Reactively update schedules when active student profile changes
    ever(_dashboardController.selectedStudent, (_) {
      fetchSchedules();
      subscribeToSchedules();
    });
  }

  @override
  void onClose() {
    _scheduleSubscription?.unsubscribe();
    super.onClose();
  }

  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;
      
      final isParent = _dashboardController.isParentView.value;
      List<String> batchIds = [];

      if (isParent) {
        // Parent: get batches for all linked students
        batchIds = _dashboardController.students
            .map((s) => s.batchId)
            .where((id) => id != null)
            .cast<String>()
            .toList();
      } else {
        // Student: get batch of selected student only
        final student = _dashboardController.selectedStudent.value;
        if (student != null && student.batchId != null) {
          batchIds = [student.batchId!];
        }
      }

      if (batchIds.isEmpty) {
        schedules.clear();
        return;
      }

      // Query schedules with batch name joined
      final response = await _client
          .from('schedules')
          .select('*, batches(name)')
          .inFilter('batch_id', batchIds)
          .order('class_date', ascending: true);

      final List<Schedule> loaded = (response as List)
          .map((data) => Schedule.fromJson(data as Map<String, dynamic>))
          .toList();

      schedules.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error Loading Schedules', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void subscribeToSchedules() {
    _scheduleSubscription?.unsubscribe();
    
    // Listen to changes globally on the schedules table
    _scheduleSubscription = _client
        .channel('public:schedules_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'schedules',
          callback: (payload) {
            // Trigger fetch to reload list with updated relation joins
            fetchSchedules();
          },
        )
        .subscribe();
  }
}
