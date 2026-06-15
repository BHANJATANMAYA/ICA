import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
// import '../../../data/models/student.dart';

import '../../../data/models/batch.dart';
import '../../dashboard/dashboard_controller.dart';

class ProfilesController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = false.obs;
  RxList<Batch> batches = <Batch>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      final response = await _client.from('batches').select('*');
      final List<Batch> loaded = (response as List)
          .map((data) => Batch.fromJson(data as Map<String, dynamic>))
          .toList();
      batches.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error Loading Batches', e.toString());
    }
  }

  Future<void> addStudent({
    required String name,
    required int rating,
    required String level,
    String? platformId,
    String? batchId,
  }) async {
    final parentId = _dashboardController.parentId.value;
    if (parentId.isEmpty) return;

    try {
      isLoading.value = true;
      await _client.from('students').insert({
        'parent_id': parentId,
        'name': name,
        'chess_rating': rating,
        'level': level,
        'platform_id': platformId,
        'batch_id': batchId,
        'is_deleted': false,
      });
      
      Get.snackbar('Success', 'Student profile added successfully.');
      await _dashboardController.fetchStudents(); // Refresh dashboard profiles list
    } catch (e) {
      Get.snackbar('Error Adding Profile', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editStudent({
    required String studentId,
    required String name,
    required int rating,
    required String level,
    String? platformId,
    String? batchId,
  }) async {
    try {
      isLoading.value = true;
      await _client.from('students').update({
        'name': name,
        'chess_rating': rating,
        'level': level,
        'platform_id': platformId,
        'batch_id': batchId,
      }).eq('id', studentId);

      Get.snackbar('Success', 'Student profile updated successfully.');
      await _dashboardController.fetchStudents(); // Refresh dashboard profiles list
    } catch (e) {
      Get.snackbar('Error Updating Profile', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> softDeleteStudent(String studentId) async {
    try {
      isLoading.value = true;
      await _client.from('students').update({
        'is_deleted': true,
      }).eq('id', studentId);

      Get.snackbar('Success', 'Student profile removed.');
      await _dashboardController.fetchStudents(); // Refresh dashboard profiles list
    } catch (e) {
      Get.snackbar('Error Deleting Profile', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
