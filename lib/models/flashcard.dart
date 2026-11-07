class Flashcard {
  final String id;
  final String userId;
  final String front;
  final String back;
  final String? subject;
  final String? topic;
  final String difficulty;
  final DateTime? nextReviewDate;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.userId,
    required this.front,
    required this.back,
    this.subject,
    this.topic,
    required this.difficulty,
    this.nextReviewDate,
    required this.createdAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      subject: json['subject'] as String?,
      topic: json['topic'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      nextReviewDate: json['next_review_date'] != null ? DateTime.parse(json['next_review_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'front': front,
      'back': back,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
      'next_review_date': nextReviewDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
