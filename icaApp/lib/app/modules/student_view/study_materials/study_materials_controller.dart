import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/study_material.dart';
import '../../dashboard/dashboard_controller.dart';

class StudyMaterialsController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<StudyMaterial> materials = <StudyMaterial>[].obs;
  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
    subscribeToMaterials();
    
    // Reactively update materials when the active student profile changes
    ever(_dashboardController.selectedStudent, (_) {
      fetchMaterials();
      subscribeToMaterials();
    });
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> fetchMaterials() async {
    final student = _dashboardController.selectedStudent.value;
    if (student == null || student.batchId == null) {
      materials.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final response = await _client
          .from('study_materials')
          .select('*')
          .eq('batch_id', student.batchId!)
          .order('created_at', ascending: false);

      final List<StudyMaterial> loaded = (response as List)
          .map((data) => StudyMaterial.fromJson(data as Map<String, dynamic>))
          .toList();

      materials.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error Loading Materials', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void subscribeToMaterials() {
    _realtimeChannel?.unsubscribe();
    final student = _dashboardController.selectedStudent.value;
    if (student == null || student.batchId == null) return;

    _realtimeChannel = _client
        .channel('public:study_materials:batch=${student.batchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'study_materials',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'batch_id',
            value: student.batchId!,
          ),
          callback: (payload) {
            fetchMaterials();
          },
        )
        .subscribe();
  }
}
