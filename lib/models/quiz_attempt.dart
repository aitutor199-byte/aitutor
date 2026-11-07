class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final int totalMarks;
  final int obtainedMarks;
  final double percentage;
  final bool isPassed;
  final DateTime createdAt;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.startedAt,
    this.submittedAt,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.isPassed,
    required this.createdAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      totalMarks: json['total_marks'] as int,
      obtainedMarks: json['obtained_marks'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['is_passed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'started_at': startedAt.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'total_marks': totalMarks,
      'obtained_marks': obtainedMarks,
      'percentage': percentage,
      'is_passed': isPassed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
