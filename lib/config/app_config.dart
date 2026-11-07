import 'package:flutter_dotenv/flutter_dotenv.dart';

class Appconfig {
  // Supabase Configuration
  // These are loaded from .env file
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';

  // Gemini Configuration
  // The API key will be stored securely in Supabase Edge Functions
  // Never expose this in the Flutter app
  static const String geminiModel = 'gemini-1.5-flash';

  // App Configuration
  static const String appName = 'AI Tutor';
  static const String appVersion = '1.0.0';

  // Supported Languages
  static const List<String> supportedLanguages = [
    'English',
    'Urdu',
    'Pashto',
  ];

  // Education Levels
  static const List<String> educationLevels = [
    'Class 1-5',
    'Class 6-8',
    'Class 9-10',
    'Intermediate / College',
    'University',
    'Independent Learner',
  ];

  // Subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Computer Science',
    'General Science',
    'History',
    'Geography',
    'University Studies',
  ];
}
