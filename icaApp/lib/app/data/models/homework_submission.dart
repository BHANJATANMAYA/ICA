class HomeworkSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String driveLink;
  final String status; // 'pending', 'submitted', 'reviewed'
  final DateTime submittedAt;

  HomeworkSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.driveLink,
    required this.status,
    required this.submittedAt,
  });

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmission(
      id: json['id'] as String,
      assignmentId: json['assignment_id'] as String,
      studentId: json['student_id'] as String,
      driveLink: json['drive_link'] as String,
      status: json['status'] as String? ?? 'pending',
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'drive_link': driveLink,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }
}
