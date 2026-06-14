class Poll {
  final String id;
  final String batchId;
  final String question;
  final DateTime createdAt;

  Poll({
    required this.id,
    required this.batchId,
    required this.question,
    required this.createdAt,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as String,
      batchId: json['batch_id'] as String,
      question: json['question'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'question': question,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
