import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Mark all as read',
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.chessGold),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppColors.chessGold.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Notifications',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are all caught up! Updates from coaches and academy alerts will appear here.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.notifications[index];

            IconData iconData = Icons.info_outline;
            Color iconColor = AppColors.deepNavy;

            if (item.type == 'billing') {
              iconData = Icons.payment_outlined;
              iconColor = AppColors.chessGold;
            } else if (item.type == 'submission') {
              iconData = Icons.assignment_turned_in_outlined;
              iconColor = AppColors.successGreen;
            } else if (item.type == 'alert') {
              iconData = Icons.warning_amber_outlined;
              iconColor = AppColors.alertRed;
            }

            return GestureDetector(
              onTap: () {
                if (!item.isRead) {
                  controller.markAsRead(item.id);
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: item.isRead ? 1 : 3,
                color: item.isRead
                    ? AppColors.white.withValues(alpha: 0.9)
                    : AppColors.white,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: item.isRead
                        ? null
                        : const Border(
                            left: BorderSide(
                              color: AppColors.chessGold,
                              width: 4,
                            ),
                          ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.1),
                        radius: 20,
                        child: Icon(iconData, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.message,
                              style: AppTypography.body.copyWith(
                                fontWeight: item.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(item.createdAt),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
