class StudyPlanTask {
  final String id;
  final String studyPlanId;
  final String title;
  final String? subject;
  final String? lessonId;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final int? durationMinutes;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;

  StudyPlanTask({
    required this.id,
    required this.studyPlanId,
    required this.title,
    this.subject,
    this.lessonId,
    this.scheduledDate,
    this.scheduledTime,
    this.durationMinutes,
    required this.isCompleted,
    this.notes,
    required this.createdAt,
  });

  factory StudyPlanTask.fromJson(Map<String, dynamic> json) {
    return StudyPlanTask(
      id: json['id'] as String,
      studyPlanId: json['study_plan_id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String?,
      lessonId: json['lesson_id'] as String?,
      scheduledDate: json['scheduled_date'] != null ? DateTime.parse(json['scheduled_date'] as String) : null,
      scheduledTime: json['scheduled_time'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      isCompleted: json['is_completed'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'study_plan_id': studyPlanId,
      'title': title,
      'subject': subject,
      'lesson_id': lessonId,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'scheduled_time': scheduledTime,
      'duration_minutes': durationMinutes,
      'is_completed': isCompleted,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
