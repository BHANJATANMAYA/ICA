import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'schedule_controller.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller directly for this screen
    final controller = Get.put(ScheduleController());

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Class Schedule', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchSchedules(),
          )
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

        if (controller.schedules.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.chessGold),
                  const SizedBox(height: 16),
                  const Text('No Upcoming Classes', style: AppTypography.sectionHeader),
                  const SizedBox(height: 8),
                  Text(
                    'No scheduled classes were found for your active batch(es). Contact administration if you think this is an error.',
                    style: AppTypography.body.copyWith(color: AppColors.darkGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.schedules.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.schedules[index];
            
            Color statusColor = AppColors.chessGold;
            if (item.status == 'completed') {
              statusColor = AppColors.successGreen;
            } else if (item.status == 'cancelled') {
              statusColor = AppColors.alertRed;
            }

            final formattedDate = DateFormat('EEEE, MMMM d, y').format(item.classDate);
            final startTimeFormatted = item.startTime.substring(0, 5); // HH:MM
            final endTimeFormatted = item.endTime.substring(0, 5); // HH:MM

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.batchName,
                          style: AppTypography.sectionHeader.copyWith(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.event, color: AppColors.deepNavy, size: 18),
                        const SizedBox(width: 8),
                        Text(formattedDate, style: AppTypography.body),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.deepNavy, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '$startTimeFormatted - $endTimeFormatted',
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
