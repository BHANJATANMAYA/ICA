import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../data/models/group_message.dart';
import '../../dashboard/dashboard_controller.dart';

class GroupChatController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RxBool isLoading = true.obs;
  RxList<GroupMessage> messages = <GroupMessage>[].obs;
  RealtimeChannel? _chatChannel;

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    subscribeToChat();

    // Reload when selected student changes
    ever(_dashboardController.selectedStudent, (_) {
      fetchMessages();
      subscribeToChat();
    });
  }

  @override
  void onClose() {
    _chatChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> fetchMessages() async {
    final student = _dashboardController.selectedStudent.value;
    if (student == null || student.batchId == null) {
      messages.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final response = await _client
          .from('group_messages')
          .select('*')
          .eq('batch_id', student.batchId!)
          .order('created_at', ascending: true); // Ascending order for chat timeline

      final List<GroupMessage> loaded = (response as List)
          .map((data) => GroupMessage.fromJson(data as Map<String, dynamic>))
          .toList();

      messages.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error Loading Messages', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void subscribeToChat() {
    _chatChannel?.unsubscribe();
    final student = _dashboardController.selectedStudent.value;
    if (student == null || student.batchId == null) return;

    _chatChannel = _client
        .channel('public:group_messages:batch=${student.batchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'batch_id',
            value: student.batchId!,
          ),
          callback: (payload) {
            // Parse new message and append to list locally if not already present
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              final newMsg = GroupMessage.fromJson(newRecord);
              if (!messages.any((m) => m.id == newMsg.id)) {
                messages.add(newMsg);
              }
            }
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final student = _dashboardController.selectedStudent.value;
    final parentId = _dashboardController.parentId.value;
    
    if (student == null || student.batchId == null || parentId.isEmpty) return;

    try {
      // In Student View, the sender is technically the parent account acting on behalf of the student
      await _client.from('group_messages').insert({
        'batch_id': student.batchId!,
        'sender_id': parentId,
        'sender_name': student.name, // Display the active student's name in chat
        'sender_type': 'parent',
        'message': text.trim(),
      });
      // Realtime subscription will automatically receive this insert and update the UI
    } catch (e) {
      Get.snackbar('Error Sending Message', e.toString());
    }
  }
}
