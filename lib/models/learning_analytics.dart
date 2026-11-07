class LearningAnalytics {
  final String id;
  final String userId;
  final DateTime date;
  final int questionsAsked;
  final int lessonsCompleted;
  final int quizzesAttempted;
  final int studyTimeMinutes;
  final List<String>? subjectsStudied;
  final List<String>? weakTopics;
  final List<String>? strongTopics;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningAnalytics({
    required this.id,
    required this.userId,
    required this.date,
    required this.questionsAsked,
    required this.lessonsCompleted,
    required this.quizzesAttempted,
    required this.studyTimeMinutes,
    this.subjectsStudied,
    this.weakTopics,
    this.strongTopics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningAnalytics.fromJson(Map<String, dynamic> json) {
    return LearningAnalytics(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      questionsAsked: json['questions_asked'] as int,
      lessonsCompleted: json['lessons_completed'] as int,
      quizzesAttempted: json['quizzes_attempted'] as int,
      studyTimeMinutes: json['study_time_minutes'] as int,
      subjectsStudied: (json['subjects_studied'] as List<dynamic>?)?.cast<String>(),
      weakTopics: (json['weak_topics'] as List<dynamic>?)?.cast<String>(),
      strongTopics: (json['strong_topics'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'questions_asked': questionsAsked,
      'lessons_completed': lessonsCompleted,
      'quizzes_attempted': quizzesAttempted,
      'study_time_minutes': studyTimeMinutes,
      'subjects_studied': subjectsStudied,
      'weak_topics': weakTopics,
      'strong_topics': strongTopics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
