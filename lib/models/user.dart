class User {
  final String id;
  final String displayName;
  final String? email;
  final String educationLevel;
  final String preferredLanguage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.displayName,
    this.email,
    required this.educationLevel,
    required this.preferredLanguage,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String?,
      educationLevel: json['education_level'] as String,
      preferredLanguage: json['preferred_language'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'education_level': educationLevel,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
