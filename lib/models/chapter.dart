class Chapter {
  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final int orderIndex;
  final String? educationLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.educationLevel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      educationLevel: json['education_level'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'order_index': orderIndex,
      'education_level': educationLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
