class Quiz {
  final String id;
  final String? lessonId;
  final String? chapterId;
  final String? subjectId;
  final String title;
  final String? description;
  final String questionType;
  final String? difficulty;
  final int? timeLimitMinutes;
  final int passingScore;
  final int totalMarks;
  final bool isAiGenerated;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quiz({
    required this.id,
    this.lessonId,
    this.chapterId,
    this.subjectId,
    required this.title,
    this.description,
    required this.questionType,
    this.difficulty,
    this.timeLimitMinutes,
    required this.passingScore,
    required this.totalMarks,
    required this.isAiGenerated,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String?,
      chapterId: json['chapter_id'] as String?,
      subjectId: json['subject_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      questionType: json['question_type'] as String,
      difficulty: json['difficulty'] as String?,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      passingScore: json['passing_score'] as int? ?? 60,
      totalMarks: json['total_marks'] as int? ?? 100,
      isAiGenerated: json['is_ai_generated'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'chapter_id': chapterId,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'question_type': questionType,
      'difficulty': difficulty,
      'time_limit_minutes': timeLimitMinutes,
      'passing_score': passingScore,
      'total_marks': totalMarks,
      'is_ai_generated': isAiGenerated,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
