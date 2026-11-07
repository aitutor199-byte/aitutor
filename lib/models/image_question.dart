class ImageQuestion {
  final String id;
  final String userId;
  final String? conversationId;
  final String imageUrl;
  final String? extractedText;
  final String? questionText;
  final String? answerText;
  final DateTime createdAt;

  ImageQuestion({
    required this.id,
    required this.userId,
    this.conversationId,
    required this.imageUrl,
    this.extractedText,
    this.questionText,
    this.answerText,
    required this.createdAt,
  });

  factory ImageQuestion.fromJson(Map<String, dynamic> json) {
    return ImageQuestion(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String?,
      imageUrl: json['image_url'] as String,
      extractedText: json['extracted_text'] as String?,
      questionText: json['question_text'] as String?,
      answerText: json['answer_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'conversation_id': conversationId,
      'image_url': imageUrl,
      'extracted_text': extractedText,
      'question_text': questionText,
      'answer_text': answerText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
