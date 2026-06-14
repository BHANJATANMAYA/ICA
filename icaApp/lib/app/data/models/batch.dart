class Batch {
  final String id;
  final String name;
  final String? description;
  final String? defaultTiming;

  Batch({
    required this.id,
    required this.name,
    this.description,
    this.defaultTiming,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultTiming: json['default_timing'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'default_timing': defaultTiming,
    };
  }
}
