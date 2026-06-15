import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'attendance_controller.dart';
import '../../dashboard/dashboard_controller.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Attendance Ledger',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAttendance(),
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

        final students = dashboardController.students;
        if (students.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 64,
                    color: AppColors.chessGold,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Student Profiles',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a student profile to track their class attendance.',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final records = controller.attendanceMap[student.id] ?? [];
            final present = controller.getPresentCount(student.id);
            final absent = controller.getAbsentCount(student.id);
            final percentage = controller.getAttendancePercentage(student.id);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              color: AppColors.white,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.deepNavy,
                    radius: 20,
                    child: Text(
                      student.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: AppTypography.sectionHeader.copyWith(fontSize: 16),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Present: $present',
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Absent: $absent',
                        style: const TextStyle(
                          color: AppColors.alertRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rate: ${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.deepNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    if (records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No attendance records found for this student.',
                          style: AppTypography.caption,
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        separatorBuilder: (context, idx) =>
                            const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final record = records[idx];
                          final isPresent =
                              record.status.toLowerCase() == 'present';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isPresent
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      color: isPresent
                                          ? AppColors.successGreen
                                          : AppColors.alertRed,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'EEEE, MMMM d, y',
                                      ).format(record.classDate),
                                      style: AppTypography.body,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPresent
                                        ? AppColors.successGreen.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.alertRed.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    record.status.toUpperCase(),
                                    style: TextStyle(
                                      color: isPresent
                                          ? AppColors.successGreen
                                          : AppColors.alertRed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
