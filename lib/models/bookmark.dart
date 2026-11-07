class Bookmark {
  final String id;
  final String userId;
  final String? lessonId;
  final String? questionId;
  final String? explanationId;
  final String? title;
  final String? note;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    this.lessonId,
    this.questionId,
    this.explanationId,
    this.title,
    this.note,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String?,
      questionId: json['question_id'] as String?,
      explanationId: json['explanation_id'] as String?,
      title: json['title'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'question_id': questionId,
      'explanation_id': explanationId,
      'title': title,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
