class TrialRequest {
  final String id;
  final String name;
  final String? contactPhone;
  final String? contactEmail;
  final String? preferredBatchId;
  final String status; // 'new', 'contacted', 'scheduled', 'closed'

  TrialRequest({
    required this.id,
    required this.name,
    this.contactPhone,
    this.contactEmail,
    this.preferredBatchId,
    required this.status,
  });

  factory TrialRequest.fromJson(Map<String, dynamic> json) {
    return TrialRequest(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      preferredBatchId: json['preferred_batch_id'] as String?,
      status: json['status'] as String? ?? 'new',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'preferred_batch_id': preferredBatchId,
      'status': status,
    };
  }
}
