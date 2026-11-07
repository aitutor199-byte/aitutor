class Classroom {
  final String id;
  final String name;
  final String? description;
  final String teacherId;
  final String invitationCode;
  final String? curriculum;
  final String? gradeLevel;
  final String? subject;
  final bool isActive;
  final DateTime createdAt;

  Classroom({
    required this.id,
    required this.name,
    this.description,
    required this.teacherId,
    required this.invitationCode,
    this.curriculum,
    this.gradeLevel,
    this.subject,
    required this.isActive,
    required this.createdAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      teacherId: json['teacher_id'] as String,
      invitationCode: json['invitation_code'] as String,
      curriculum: json['curriculum'] as String?,
      gradeLevel: json['grade_level'] as String?,
      subject: json['subject'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
