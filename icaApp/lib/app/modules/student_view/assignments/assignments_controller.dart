import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/assignment.dart';
import '../../../data/models/homework_submission.dart';
import '../../dashboard/dashboard_controller.dart';

class AssignmentsController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<Assignment> assignments = <Assignment>[].obs;
  // Map of assignmentId -> HomeworkSubmission
  RxMap<String, HomeworkSubmission> submissions = <String, HomeworkSubmission>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignments();
    
    // Reactively refresh on student profile switch
    ever(_dashboardController.selectedStudent, (_) {
      fetchAssignments();
    });
  }

  Future<void> fetchAssignments() async {
    final student = _dashboardController.selectedStudent.value;
    if (student == null || student.batchId == null) {
      assignments.clear();
      submissions.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      
      // 1. Fetch assignments
      final assignmentsRes = await _client
          .from('assignments')
          .select('*')
          .eq('batch_id', student.batchId!)
          .order('due_date', ascending: true);

      final List<Assignment> loadedAssignments = (assignmentsRes as List)
          .map((data) => Assignment.fromJson(data as Map<String, dynamic>))
          .toList();

      // 2. Fetch homework submissions for this student
      final submissionsRes = await _client
          .from('homework_submissions')
          .select('*')
          .eq('student_id', student.id);

      final List<HomeworkSubmission> loadedSubmissions = (submissionsRes as List)
          .map((data) => HomeworkSubmission.fromJson(data as Map<String, dynamic>))
          .toList();

      // Map submissions by assignment_id
      final Map<String, HomeworkSubmission> subMap = {};
      for (var sub in loadedSubmissions) {
        subMap[sub.assignmentId] = sub;
      }

      assignments.assignAll(loadedAssignments);
      submissions.assignAll(subMap);
    } catch (e) {
      Get.snackbar('Error Loading Assignments', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitHomework(String assignmentId, String driveLink) async {
    final student = _dashboardController.selectedStudent.value;
    if (student == null) return;

    try {
      isLoading.value = true;

      // Upsert: writes to homework_submissions, matching unique constraint (assignment_id, student_id)
      await _client.from('homework_submissions').upsert({
        'assignment_id': assignmentId,
        'student_id': student.id,
        'drive_link': driveLink,
        'status': 'submitted',
        'submitted_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Success', 'Homework submitted successfully!');
      
      // Send notification entry in background for the submission (optional, but premium)
      try {
        final parentId = _dashboardController.parentId.value;
        if (parentId.isNotEmpty) {
          await _client.from('notifications').insert({
            'target_parent_id': parentId,
            'type': 'submission',
            'message': 'Homework for "${assignments.firstWhere((a) => a.id == assignmentId).title}" has been submitted for ${student.name}.',
          });
        }
      } catch (_) {}

      await fetchAssignments(); // Reload states
    } catch (e) {
      Get.snackbar('Error Submitting Homework', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
