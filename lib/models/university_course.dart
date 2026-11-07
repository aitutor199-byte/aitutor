class UniversityCourse {
  final String id;
  final String institutionId;
  final String? departmentId;
  final String? teacherId;
  final String title;
  final String? description;
  final String? subject;
  final String? educationLevel;
  final int? durationWeeks;
  final bool isPublished;
  final bool isFree;
  final double? price;
  final DateTime createdAt;

  UniversityCourse({
    required this.id,
    required this.institutionId,
    this.departmentId,
    this.teacherId,
    required this.title,
    this.description,
    this.subject,
    this.educationLevel,
    this.durationWeeks,
    required this.isPublished,
    required this.isFree,
    this.price,
    required this.createdAt,
  });

  factory UniversityCourse.fromJson(Map<String, dynamic> json) {
    return UniversityCourse(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      departmentId: json['department_id'] as String?,
      teacherId: json['teacher_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      subject: json['subject'] as String?,
      educationLevel: json['education_level'] as String?,
      durationWeeks: json['duration_weeks'] as int?,
      isPublished: json['is_published'] as bool,
      isFree: json['is_free'] as bool,
      price: (json['price'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
