class LessonProgress {
  final String id;
  final String userId;
  final String lessonId;
  final bool isCompleted;
  final int completionPercentage;
  final int timeSpentMinutes;
  final DateTime lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.isCompleted,
    required this.completionPercentage,
    required this.timeSpentMinutes,
    required this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
      timeSpentMinutes: json['time_spent_minutes'] as int? ?? 0,
      lastAccessedAt: DateTime.parse(json['last_accessed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'is_completed': isCompleted,
      'completion_percentage': completionPercentage,
      'time_spent_minutes': timeSpentMinutes,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
