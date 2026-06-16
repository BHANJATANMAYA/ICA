import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'trial_booking_controller.dart';

class TrialBookingScreen extends StatelessWidget {
  const TrialBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrialBookingController());
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final RxnString selectedBatchId = RxnString();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'Book Trial Class',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.play_lesson,
                    color: AppColors.chessGold,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Request a Chess Demo',
                    style: AppTypography.sectionHeader,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the student details below to book a free trial session with our Grandmaster coaches.',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Child Name
                  TextFormField(
                    controller: nameController,
                    style: AppTypography.body,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: Icon(Icons.person, color: AppColors.deepNavy),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter the student\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact Phone
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.body,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone Number',
                      prefixIcon: Icon(Icons.phone, color: AppColors.deepNavy),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact Email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTypography.body,
                    decoration: const InputDecoration(
                      labelText: 'Contact Email Address',
                      prefixIcon: Icon(Icons.email, color: AppColors.deepNavy),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a contact email';
                      }
                      if (!val.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Preferred Batch Dropdown
                  const Text(
                    'Preferred Batch (Optional)',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: selectedBatchId.value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select a training tier',
                        prefixIcon: Icon(
                          Icons.school,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      items: controller.batches.map((batch) {
                        return DropdownMenuItem(
                          value: batch.id,
                          child: Text('${batch.name} (${batch.defaultTiming})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        selectedBatchId.value = val;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Book Now Button
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                controller.bookTrial(
                                  name: nameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  email: emailController.text.trim(),
                                  preferredBatchId: selectedBatchId.value,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.chessGold,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.chessGold.withValues(
                          alpha: 0.6,
                        ),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Book Trial Session',
                              style: AppTypography.buttonText,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
