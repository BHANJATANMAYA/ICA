class AttendanceRecord {
  final String id;
  final String studentId;
  final String batchId;
  final DateTime classDate;
  final String status; // 'present', 'absent'

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.classDate,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      batchId: json['batch_id'] as String,
      classDate: DateTime.parse(json['class_date'] as String),
      status: json['status'] as String? ?? 'present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'batch_id': batchId,
      'class_date': classDate.toIso8601String().split('T')[0],
      'status': status,
    };
  }
}
