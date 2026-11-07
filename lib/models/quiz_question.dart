class QuizQuestion {
  final String id;
  final String quizId;
  final String questionText;
  final String questionType;
  final Map<String, dynamic>? options;
  final String correctAnswer;
  final String? explanation;
  final int marks;
  final int orderIndex;
  final DateTime createdAt;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.options,
    required this.correctAnswer,
    this.explanation,
    required this.marks,
    required this.orderIndex,
    required this.createdAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      options: json['options'] as Map<String, dynamic>?,
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String?,
      marks: json['marks'] as int? ?? 1,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': questionType,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'marks': marks,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
