import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/plan.dart';
import '../../../data/models/student.dart';
import 'billing_controller.dart';
import '../../dashboard/dashboard_controller.dart';
import '../profiles/profiles_screen.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BillingController());
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Subscriptions & Billing',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.chessGold),
            ),
          );
        }

        final students = dashboardController.students;

        // HARD GATE: If no students exist, show gate block
        if (students.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.credit_card_off_outlined,
                    size: 64,
                    color: AppColors.alertRed,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Student Profile Required',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You must add at least one student profile under your account before purchasing a subscription plan.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const ProfilesScreen()),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Student Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chessGold,
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Active Memberships rollup
              const Text(
                'Active Subscriptions',
                style: AppTypography.sectionHeader,
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final subs =
                      controller.studentSubscriptions[student.id] ?? [];
                  final activeSub = subs.firstWhereOrNull(
                    (s) => s.status == 'active',
                  );

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeSub != null
                                    ? 'Expires: ${DateFormat('yyyy-MM-dd').format(activeSub.endDate)}'
                                    : 'No Active Subscription',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: activeSub != null
                                  ? AppColors.successGreen.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.alertRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: activeSub != null
                                    ? AppColors.successGreen
                                    : AppColors.alertRed,
                              ),
                            ),
                            child: Text(
                              activeSub != null ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                color: activeSub != null
                                    ? AppColors.successGreen
                                    : AppColors.alertRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section 2: Choose subscription plans
              const Text(
                'Choose Academy Plan',
                style: AppTypography.sectionHeader,
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemCount: controller.plans.length,
                itemBuilder: (context, index) {
                  final plan = controller.plans[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.chessGold,
                        width: 1.5,
                      ),
                    ),
                    color: AppColors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  plan.name,
                                  style: AppTypography.sectionHeader.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Unlimited chess batches, tactical materials, and tournament sheets.',
                                  style: AppTypography.caption,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${plan.price.toStringAsFixed(0)}',
                                style: AppTypography.screenTitle.copyWith(
                                  color: AppColors.chessGold,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                '/ ${plan.durationType}',
                                style: AppTypography.caption,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _selectStudentForPlan(
                                  context,
                                  controller,
                                  plan,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.chessGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  void _selectStudentForPlan(
    BuildContext context,
    BillingController controller,
    Plan plan,
  ) {
    final dashboardController = Get.find<DashboardController>();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Student for Plan',
              style: AppTypography.sectionHeader,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Which child would you like to enroll in "${plan.name}"?',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: dashboardController.students.length,
                itemBuilder: (context, index) {
                  final student = dashboardController.students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.deepNavy,
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(student.level, style: AppTypography.caption),
                    onTap: () {
                      Get.back(); // close student sheet
                      _launchRazorpaySimulator(
                        context,
                        controller,
                        student,
                        plan,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _launchRazorpaySimulator(
    BuildContext context,
    BillingController controller,
    Student student,
    Plan plan,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Razorpay Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Razorpay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chessGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TEST MODE',
                      style: TextStyle(
                        color: AppColors.chessGold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plan info
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Plan Enrolled:', style: AppTypography.caption),
                  Text(
                    plan.name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Student Name:', style: AppTypography.caption),
                  Text(
                    student.name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Payable:', style: AppTypography.caption),
                  Text(
                    '₹${plan.price.toStringAsFixed(0)}',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.chessGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),

              // Simulator options
              const Text(
                'Select Simulator Action',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // close dialog
                  controller.purchasePlan(studentId: student.id, plan: plan);
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Simulate Success',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.snackbar(
                    'Payment Failed',
                    'The transaction was simulated as failed by the user.',
                    backgroundColor: AppColors.alertRed.withValues(alpha: 0.1),
                    colorText: AppColors.alertRed,
                  );
                },
                icon: const Icon(Icons.cancel, color: Colors.white),
                label: const Text(
                  'Simulate Failure',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
