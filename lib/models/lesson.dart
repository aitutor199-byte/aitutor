class Lesson {
  final String id;
  final String chapterId;
  final String title;
  final String content;
  final List<String> learningObjectives;
  final Map<String, dynamic>? definitions;
  final Map<String, dynamic>? examples;
  final Map<String, dynamic>? formulas;
  final List<String> imageUrls;
  final int orderIndex;
  final String language;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.content,
    required this.learningObjectives,
    this.definitions,
    this.examples,
    this.formulas,
    required this.imageUrls,
    required this.orderIndex,
    required this.language,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      chapterId: json['chapter_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      learningObjectives: (json['learning_objectives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      definitions: json['definitions'] as Map<String, dynamic>?,
      examples: json['examples'] as Map<String, dynamic>?,
      formulas: json['formulas'] as Map<String, dynamic>?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      orderIndex: json['order_index'] as int? ?? 0,
      language: json['language'] as String? ?? 'en',
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'title': title,
      'content': content,
      'learning_objectives': learningObjectives,
      'definitions': definitions,
      'examples': examples,
      'formulas': formulas,
      'image_urls': imageUrls,
      'order_index': orderIndex,
      'language': language,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
