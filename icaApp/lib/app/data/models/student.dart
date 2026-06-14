class Student {
  final String id;
  final String name;
  final int chessRating;
  final String level;
  final String? platformId;
  final String? parentId;
  final String? batchId;
  final bool isDeleted;

  Student({
    required this.id,
    required this.name,
    required this.chessRating,
    required this.level,
    this.platformId,
    this.parentId,
    this.batchId,
    required this.isDeleted,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      chessRating: json['chess_rating'] as int? ?? 1000,
      level: json['level'] as String? ?? 'Beginner',
      platformId: json['platform_id'] as String?,
      parentId: json['parent_id'] as String?,
      batchId: json['batch_id'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'chess_rating': chessRating,
      'level': level,
      'platform_id': platformId,
      'parent_id': parentId,
      'batch_id': batchId,
      'is_deleted': isDeleted,
    };
  }
}
