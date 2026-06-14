class StudyMaterial {
  final String id;
  final String batchId;
  final String title;
  final String? fileUrl;
  final String? linkUrl;

  StudyMaterial({
    required this.id,
    required this.batchId,
    required this.title,
    this.fileUrl,
    this.linkUrl,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] as String,
      batchId: json['batch_id'] as String,
      title: json['title'] as String,
      fileUrl: json['file_url'] as String?,
      linkUrl: json['link_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'title': title,
      'file_url': fileUrl,
      'link_url': linkUrl,
    };
  }
}
