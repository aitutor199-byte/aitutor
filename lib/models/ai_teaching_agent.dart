class AITeachingAgent {
  final String id;
  final String name;
  final String specialization;
  final String? description;
  final Map<String, dynamic>? capabilities;
  final String? systemPrompt;
  final bool isActive;
  final DateTime createdAt;

  AITeachingAgent({
    required this.id,
    required this.name,
    required this.specialization,
    this.description,
    this.capabilities,
    this.systemPrompt,
    required this.isActive,
    required this.createdAt,
  });

  factory AITeachingAgent.fromJson(Map<String, dynamic> json) {
    return AITeachingAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      description: json['description'] as String?,
      capabilities: json['capabilities'] as Map<String, dynamic>?,
      systemPrompt: json['system_prompt'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
