class Achievement {
  final String id;
  final String title;
  final String? description;
  final String? icon;
  final String? category;
  final int xpReward;
  final String? requirementType;
  final int? requirementValue;
  final bool isActive;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.category,
    required this.xpReward,
    this.requirementType,
    this.requirementValue,
    required this.isActive,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      category: json['category'] as String?,
      xpReward: json['xp_reward'] as int,
      requirementType: json['requirement_type'] as String?,
      requirementValue: json['requirement_value'] as int?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
