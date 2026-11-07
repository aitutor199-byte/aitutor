class HandwritingResult {
  final String id;
  final String userId;
  final String imageUrl;
  final String? recognizedText;
  final double? confidenceScore;
  final bool isProcessed;
  final DateTime createdAt;

  HandwritingResult({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.recognizedText,
    this.confidenceScore,
    required this.isProcessed,
    required this.createdAt,
  });

  factory HandwritingResult.fromJson(Map<String, dynamic> json) {
    return HandwritingResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      recognizedText: json['recognized_text'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      isProcessed: json['is_processed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'recognized_text': recognizedText,
      'confidence_score': confidenceScore,
      'is_processed': isProcessed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
