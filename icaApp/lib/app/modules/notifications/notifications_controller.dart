import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../data/models/notification.dart';
import '../dashboard/dashboard_controller.dart';

class NotificationsController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final parentId = _dashboardController.parentId.value;
    if (parentId.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final response = await _client
          .from('notifications')
          .select()
          .eq('target_parent_id', parentId)
          .order('created_at', ascending: false);

      final List<NotificationModel> loaded = (response as List)
          .map((data) => NotificationModel.fromJson(data as Map<String, dynamic>))
          .toList();

      notifications.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error Loading Alerts', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    final parentId = _dashboardController.parentId.value;
    if (parentId.isEmpty) return;

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('target_parent_id', parentId);
      
      // Fetch updated states from DB
      await fetchNotifications();
      _dashboardController.fetchNotificationCount(parentId);
    } catch (e) {
      Get.snackbar('Error Updating Alerts', e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      
      await fetchNotifications();
      _dashboardController.fetchNotificationCount(_dashboardController.parentId.value);
    } catch (e) {
      Get.snackbar('Error Updating Alert', e.toString());
    }
  }
}
