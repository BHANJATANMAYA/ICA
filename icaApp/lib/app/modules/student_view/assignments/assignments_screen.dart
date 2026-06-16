import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'assignments_controller.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignmentsController());

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Homework Assignments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAssignments(),
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

        if (controller.assignments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: AppColors.chessGold,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Assignments Found',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No homework assignments have been created for your batch yet.',
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
          itemCount: controller.assignments.length,
          itemBuilder: (context, index) {
            final assignment = controller.assignments[index];
            final submission = controller.submissions[assignment.id];

            final isSubmitted =
                submission != null &&
                (submission.status == 'submitted' ||
                    submission.status == 'reviewed');

            final badgeColor = isSubmitted
                ? AppColors.successGreen
                : AppColors.chessGold;
            final badgeText = isSubmitted ? 'SUBMITTED' : 'PENDING';

            final formattedDueDate = assignment.dueDate != null
                ? DateFormat(
                    'EEE, MMM d, y • h:mm a',
                  ).format(assignment.dueDate!)
                : 'No Due Date';

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
                    backgroundColor: badgeColor.withValues(alpha: 0.1),
                    radius: 18,
                    child: Icon(
                      isSubmitted
                          ? Icons.check_circle_outline
                          : Icons.assignment_outlined,
                      color: badgeColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    assignment.title,
                    style: AppTypography.sectionHeader.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Due: $formattedDueDate',
                    style: AppTypography.caption,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: badgeColor, width: 1),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  childrenPadding: const EdgeInsets.all(16.0),
                  children: [
                    if (assignment.description != null &&
                        assignment.description!.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          assignment.description!,
                          style: AppTypography.body,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (isSubmitted) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.successGreen.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link,
                              color: AppColors.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                submission.driveLink,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.successGreen,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Submission form button
                    ElevatedButton.icon(
                      onPressed: () => _showSubmissionDialog(
                        context,
                        controller,
                        assignment.id,
                        initialLink: submission?.driveLink,
                      ),
                      icon: Icon(
                        isSubmitted ? Icons.edit : Icons.upload,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        isSubmitted
                            ? 'Resubmit Homework'
                            : 'Submit Homework Link',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.chessGold,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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

  void _showSubmissionDialog(
    BuildContext context,
    AssignmentsController controller,
    String assignmentId, {
    String? initialLink,
  }) {
    final linkController = TextEditingController(text: initialLink);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Submit Homework',
          style: AppTypography.sectionHeader,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Please upload your worksheet/game link to Google Drive and paste the shareable link below.',
                style: AppTypography.body.copyWith(color: AppColors.darkGray),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Google Drive Share Link',
                  hintText: 'https://drive.google.com/...',
                  border: OutlineInputBorder(),
                ),
                style: AppTypography.body,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }

                  // Regex validation for Google Drive / Docs links
                  final regExp = RegExp(
                    r'^https?://(drive|docs)\.google\.com/.*',
                  );
                  if (!regExp.hasMatch(value)) {
                    return 'Must be a valid Google Drive or Docs link';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.deepNavy),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                controller.submitHomework(
                  assignmentId,
                  linkController.text.trim(),
                );
                Get.back(); // close dialog
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.chessGold,
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
