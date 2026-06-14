import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../data/models/student.dart';
import '../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;

  RxBool isLoading = true.obs;
  RxBool isParentView = true.obs;
  RxInt currentTabIndex = 0.obs;

  RxList<Student> students = <Student>[].obs;
  Rxn<Student> selectedStudent = Rxn<Student>();
  
  RxString parentName = 'Parent'.obs;
  RxString parentId = ''.obs;
  
  RxInt notificationCount = 0.obs;
  RealtimeChannel? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchParentAndStudents();
  }

  @override
  void onClose() {
    _notificationSubscription?.unsubscribe();
    super.onClose();
  }

  Future<void> fetchParentAndStudents() async {
    try {
      isLoading.value = true;
      final user = _client.auth.currentUser;
      if (user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // 1. Fetch parent profile
      final parentResponse = await _client
          .from('parents')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (parentResponse != null) {
        parentId.value = parentResponse['id'] as String;
        parentName.value = parentResponse['name'] as String;
        
        // Setup realtime notifications
        subscribeToNotifications(parentId.value);
        fetchNotificationCount(parentId.value);
        
        // 2. Fetch students
        await fetchStudents();
      } else {
        // If parent has no record, create one (fallback case for direct signups)
        final newParent = await _client.from('parents').insert({
          'auth_user_id': user.id,
          'name': user.userMetadata?['name'] ?? 'New Parent',
          'email': user.email ?? '',
        }).select().single();
        
        parentId.value = newParent['id'] as String;
        parentName.value = newParent['name'] as String;
        
        subscribeToNotifications(parentId.value);
        students.clear();
        selectedStudent.value = null;
      }
    } catch (e) {
      Get.snackbar('Error Loading Profile', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStudents() async {
    if (parentId.isEmpty) return;
    try {
      final response = await _client
          .from('students')
          .select()
          .eq('parent_id', parentId.value)
          .eq('is_deleted', false);

      final List<Student> loadedStudents = (response as List)
          .map((data) => Student.fromJson(data as Map<String, dynamic>))
          .toList();

      students.assignAll(loadedStudents);
      
      if (students.isNotEmpty) {
        // Retain selection if still in the list, otherwise select first
        if (selectedStudent.value == null || 
            !students.any((s) => s.id == selectedStudent.value!.id)) {
          selectedStudent.value = students.first;
        } else {
          // Refresh selected student data
          selectedStudent.value = students.firstWhere((s) => s.id == selectedStudent.value!.id);
        }
      } else {
        selectedStudent.value = null;
      }
    } catch (e) {
      Get.snackbar('Error Loading Students', e.toString());
    }
  }

  void switchView(bool parentView) {
    if (!parentView && students.isEmpty) {
      Get.snackbar('Student View', 'Please add a student profile first.');
      return;
    }
    isParentView.value = parentView;
    currentTabIndex.value = parentView ? 0 : 1;
  }

  void selectStudent(Student student) {
    selectedStudent.value = student;
    Get.back(); // close bottom sheet
    // Trigger update in child views by notifying change
    selectedStudent.refresh();
  }

  void fetchNotificationCount(String parentId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('target_parent_id', parentId)
          .eq('is_read', false);
      notificationCount.value = (response as List).length;
    } catch (e) {
      // Fail silently for notification counts
    }
  }

  void subscribeToNotifications(String pId) {
    _notificationSubscription?.unsubscribe();
    _notificationSubscription = _client
        .channel('public:notifications:parent_id=$pId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'target_parent_id',
            value: pId,
          ),
          callback: (payload) {
            fetchNotificationCount(pId);
          },
        )
        .subscribe();
  }

  Future<void> logout() async {
    _notificationSubscription?.unsubscribe();
    await _client.auth.signOut();
  }
}
