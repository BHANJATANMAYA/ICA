import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase/supabase_client.dart';
import '../../data/models/notification.dart';
import '../dashboard/dashboard_controller.dart';

class NotificationsController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController =
      Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Fetch notifications — reads from drift cache first, falls back to Supabase.
  Future<void> fetchNotifications() async {
    final parentId = _dashboardController.parentId.value;
    if (parentId.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;

      // MODULE 1: Read from drift cache first (offline-first)
      final db = Get.find<AppDatabase>();
      final cachedItems = await db.getNotificationsForParent(parentId);

      if (cachedItems.isNotEmpty) {
        notifications.assignAll(
          cachedItems.map((n) => NotificationModel(
                id: n.id,
                targetParentId: n.targetParentId,
                type: n.type,
                message: n.body,
                isRead: n.isRead,
                createdAt: DateTime.tryParse(n.createdAt) ?? DateTime.now(),
              )),
        );
        isLoading.value = false;
      }

      // Then fetch fresh data from Supabase (background refresh)
      final response = await _client
          .from('notifications')
          .select()
          .eq('target_parent_id', parentId)
          .order('created_at', ascending: false);

      final List<NotificationModel> loaded = (response as List)
          .map((data) =>
              NotificationModel.fromJson(data as Map<String, dynamic>))
          .toList();

      notifications.assignAll(loaded);

      // Sync fresh data to drift cache
      await db.upsertNotifications(
        loaded.map((n) => CachedNotificationsCompanion.insert(
              id: n.id,
              targetParentId: n.targetParentId,
              body: drift.Value(n.message),
              type: drift.Value(n.type),
              isRead: drift.Value(n.isRead),
              createdAt: n.createdAt.toIso8601String(),
            )).toList(),
      );
    } catch (e) {
      // If Supabase fails, drift cache data (already loaded above) serves as fallback
      if (notifications.isEmpty) {
        Get.snackbar('Error Loading Alerts', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    final parentId = _dashboardController.parentId.value;
    if (parentId.isEmpty) return;

    try {
      // Update both Supabase and drift
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('target_parent_id', parentId);

      final db = Get.find<AppDatabase>();
      await db.markAllNotificationsRead(parentId);

      await fetchNotifications();
      _dashboardController.fetchNotificationCount(parentId);
    } catch (e) {
      Get.snackbar('Error Updating Alerts', e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Update Supabase
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);

      // Update drift cache
      final db = Get.find<AppDatabase>();
      await db.markNotificationRead(notificationId);

      await fetchNotifications();
      _dashboardController
          .fetchNotificationCount(_dashboardController.parentId.value);
    } catch (e) {
      Get.snackbar('Error Updating Alert', e.toString());
    }
  }
}
