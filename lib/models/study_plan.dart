class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final String? educationLevel;
  final List<String>? subjects;
  final int? dailyStudyMinutes;
  final int? weeklyStudyHours;
  final List<String>? learningGoals;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.educationLevel,
    this.subjects,
    this.dailyStudyMinutes,
    this.weeklyStudyHours,
    this.learningGoals,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      educationLevel: json['education_level'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)?.cast<String>(),
      dailyStudyMinutes: json['daily_study_minutes'] as int?,
      weeklyStudyHours: json['weekly_study_hours'] as int?,
      learningGoals: (json['learning_goals'] as List<dynamic>?)?.cast<String>(),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'education_level': educationLevel,
      'subjects': subjects,
      'daily_study_minutes': dailyStudyMinutes,
      'weekly_study_hours': weeklyStudyHours,
      'learning_goals': learningGoals,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
