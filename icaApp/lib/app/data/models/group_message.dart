class GroupMessage {
  final String id;
  final String batchId;
  final String senderId;
  final String senderName;
  final String senderType; // 'admin', 'parent', 'student'
  final String message;
  final DateTime createdAt;

  GroupMessage({
    required this.id,
    required this.batchId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'] as String,
      batchId: json['batch_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      senderType: json['sender_type'] as String? ?? 'student',
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_type': senderType,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
