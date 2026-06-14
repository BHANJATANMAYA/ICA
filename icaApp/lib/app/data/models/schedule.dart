// import 'batch.dart';

class Schedule {
  final String id;
  final String batchId;
  final DateTime classDate;
  final String startTime;
  final String endTime;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String batchName;

  Schedule({
    required this.id,
    required this.batchId,
    required this.classDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.batchName,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Handle joined batches table relation
    String bName = 'Unknown Batch';
    if (json['batches'] != null) {
      if (json['batches'] is Map) {
        bName = json['batches']['name'] as String? ?? 'Unknown Batch';
      } else if (json['batches'] is List && json['batches'].isNotEmpty) {
        bName = json['batches'][0]['name'] as String? ?? 'Unknown Batch';
      }
    }

    return Schedule(
      id: json['id'] as String,
      batchId: json['batch_id'] as String,
      classDate: DateTime.parse(json['class_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: json['status'] as String? ?? 'scheduled',
      batchName: bName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'class_date': classDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
  }
}
