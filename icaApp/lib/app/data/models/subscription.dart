class Subscription {
  final String id;
  final String studentId;
  final String planId;
  final String status; // 'active', 'overdue', 'expired'
  final DateTime startDate;
  final DateTime endDate;

  Subscription({
    required this.id,
    required this.studentId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      planId: json['plan_id'] as String,
      status: json['status'] as String? ?? 'active',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'plan_id': planId,
      'status': status,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    };
  }
}
