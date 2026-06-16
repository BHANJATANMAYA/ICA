import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../dashboard/dashboard_controller.dart';
import 'group_chat_controller.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final GroupChatController controller;
  late final DashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GroupChatController());
    dashboardController = Get.find<DashboardController>();

    // Bind scroll behavior to list updates
    controller.messages.listen((_) {
      if (mounted) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Chat',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Obx(() {
              final student = dashboardController.selectedStudent.value;
              return Text(
                student != null ? 'Batch Chat' : 'Chess Batch Room',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              );
            }),
          ],
        ),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Chat history
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.chessGold,
                    ),
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.chessGold,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Start the Conversation',
                          style: AppTypography.sectionHeader,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No messages have been sent in this batch yet. Say hello to your batch mates and coaches!',
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

              // Trigger initial scroll after load
              _scrollToBottom();

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe =
                      msg.senderId == dashboardController.parentId.value &&
                      msg.senderType == 'parent';

                  return _buildChatBubble(msg, isMe);
                },
              );
            }),
          ),

          // Input panel
          _buildInputPanel(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(dynamic msg, bool isMe) {
    Color bubbleColor = isMe ? AppColors.chessGold : AppColors.white;
    Color textColor = isMe ? Colors.white : AppColors.deepNavy;

    // Determine sender type description / colors
    String typeTag = msg.senderType.toUpperCase();
    Color tagColor = Colors.grey;
    if (msg.senderType == 'admin') {
      typeTag = 'COACH';
      tagColor = AppColors.alertRed;
    } else if (msg.senderType == 'student') {
      typeTag = 'STUDENT';
      tagColor = AppColors.chessGold;
    } else if (msg.senderType == 'parent') {
      typeTag = 'PARENT';
      tagColor = AppColors.deepNavy;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: AppColors.deepNavy.withValues(alpha: 0.1),
              radius: 16,
              child: Text(
                msg.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender Details
                if (!isMe)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.senderName,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeTag,
                          style: TextStyle(
                            color: tagColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 2),

                // Message bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe
                          ? const Radius.circular(12)
                          : const Radius.circular(0),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.message,
                        style: AppTypography.body.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('h:mm a').format(msg.createdAt),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : AppColors.darkGray,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type chess message...',
                  hintStyle: AppTypography.caption,
                  border: InputBorder.none,
                ),
                style: AppTypography.body,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (val) => _send(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.chessGold),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      controller.sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }
}
