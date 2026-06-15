import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/student.dart';
// import '../../../data/models/batch.dart';
import 'profiles_controller.dart';
import '../../dashboard/dashboard_controller.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfilesController());
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Linked Students', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final students = dashboardController.students;
        
        if (students.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: AppColors.chessGold),
                  const SizedBox(height: 16),
                  const Text('No Students Linked', style: AppTypography.sectionHeader),
                  const SizedBox(height: 8),
                  Text(
                    'Link your child\'s profile to track schedules, attendance, billing, and homework.',
                    style: AppTypography.body.copyWith(color: AppColors.darkGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditSheet(context, controller),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Student Profile', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chessGold,
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
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
            final batch = controller.batches.firstWhereOrNull((b) => b.id == student.batchId);
            final batchName = batch?.name ?? 'No Batch Assigned';

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.deepNavy,
                          radius: 24,
                          child: Text(
                            student.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student.name, style: AppTypography.sectionHeader.copyWith(fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.chessGold,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      student.level,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rating: ${student.chessRating}',
                                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 18, color: AppColors.deepNavy),
                        const SizedBox(width: 8),
                        Text('Batch: $batchName', style: AppTypography.body),
                      ],
                    ),
                    if (student.platformId != null && student.platformId!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.videogame_asset, size: 18, color: AppColors.deepNavy),
                          const SizedBox(width: 8),
                          Text('Platform ID: ${student.platformId}', style: AppTypography.body),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddEditSheet(context, controller, student: student),
                          icon: const Icon(Icons.edit, size: 16, color: AppColors.deepNavy),
                          label: const Text('Edit', style: TextStyle(color: AppColors.deepNavy)),
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () => _confirmDelete(context, controller, student),
                          icon: const Icon(Icons.delete, size: 16, color: AppColors.alertRed),
                          label: const Text('Delete', style: TextStyle(color: AppColors.alertRed)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: Obx(() {
        if (dashboardController.students.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton(
          backgroundColor: AppColors.chessGold,
          onPressed: () => _showAddEditSheet(context, controller),
          child: const Icon(Icons.add, color: Colors.white),
        );
      }),
    );
  }

  void _showAddEditSheet(BuildContext context, ProfilesController controller, {Student? student}) {
    final nameController = TextEditingController(text: student?.name);
    final ratingController = TextEditingController(text: student?.chessRating.toString() ?? '1000');
    final platformIdController = TextEditingController(text: student?.platformId);
    
    final RxString selectedLevel = (student?.level ?? 'Beginner').obs;
    final RxnString selectedBatchId = RxnString(student?.batchId);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                student == null ? 'Add Student Profile' : 'Edit Student Profile',
                style: AppTypography.sectionHeader,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Name Field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Chess Rating
              TextField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chess Rating',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Platform ID
              TextField(
                controller: platformIdController,
                decoration: const InputDecoration(
                  labelText: 'Platform Username (e.g. Chess.com/Lichess)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Level Select
              const Text('Level', style: AppTypography.caption),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: selectedLevel.value,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                    ],
                    onChanged: (val) {
                      if (val != null) selectedLevel.value = val;
                    },
                  )),
              const SizedBox(height: 16),
              
              // Batch Select
              const Text('Select Batch', style: AppTypography.caption),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: selectedBatchId.value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Choose batch',
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
                  )),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Name is required');
                    return;
                  }
                  
                  final rating = int.tryParse(ratingController.text.trim()) ?? 1000;
                  
                  if (student == null) {
                    controller.addStudent(
                      name: nameController.text.trim(),
                      rating: rating,
                      level: selectedLevel.value,
                      platformId: platformIdController.text.trim(),
                      batchId: selectedBatchId.value,
                    );
                  } else {
                    controller.editStudent(
                      studentId: student.id,
                      name: nameController.text.trim(),
                      rating: rating,
                      level: selectedLevel.value,
                      platformId: platformIdController.text.trim(),
                      batchId: selectedBatchId.value,
                    );
                  }
                  Get.back(); // close bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.chessGold,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Profile'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context, ProfilesController controller, Student student) {
    Get.defaultDialog(
      title: 'Remove Profile',
      titleStyle: AppTypography.sectionHeader,
      middleText: 'Are you sure you want to remove ${student.name}\'s profile? This action cannot be undone.',
      middleTextStyle: AppTypography.body,
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.alertRed,
      textCancel: 'Cancel',
      cancelTextColor: AppColors.deepNavy,
      onConfirm: () {
        controller.softDeleteStudent(student.id);
        Get.back();
      },
    );
  }
}
