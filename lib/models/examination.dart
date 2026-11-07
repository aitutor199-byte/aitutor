class Examination {
  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final String? educationLevel;
  final int durationMinutes;
  final int totalMarks;
  final int passingScore;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Examination({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.educationLevel,
    required this.durationMinutes,
    required this.totalMarks,
    required this.passingScore,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      educationLevel: json['education_level'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      totalMarks: json['total_marks'] as int,
      passingScore: json['passing_score'] as int? ?? 60,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'education_level': educationLevel,
      'duration_minutes': durationMinutes,
      'total_marks': totalMarks,
      'passing_score': passingScore,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
