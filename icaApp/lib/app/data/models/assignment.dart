class Assignment {
  final String id;
  final String batchId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.batchId,
    required this.title,
    this.description,
    this.dueDate,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      batchId: json['batch_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
