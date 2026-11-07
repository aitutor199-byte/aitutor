# AI Tutor

An intelligent AI-powered educational platform that works like a personal teacher. Built with Flutter, Supabase, and Google Gemini.

## Features

### Phase 1
- **Multilingual Support**: English, Urdu, and Pashto
- **AI-Powered Learning**: Smart explanations adapted to education level
- **Voice Features**: Speech-to-text and text-to-speech
- **Subject-Based Learning**: Mathematics, Physics, Chemistry, Biology, and more
- **Authentication**: Secure user management with Supabase
- **Chat Interface**: Conversational AI tutor

### Phase 2
- **Learning Management System**: Structured lessons and chapters
- **Interactive Quizzes**: Multiple question types with backend validation
- **Examinations**: Timed tests with automatic scoring
- **Progress Tracking**: Detailed learning statistics and charts
- **Bookmarks**: Save lessons and explanations
- **AI Question Generator**: Generate practice questions automatically
- **Enhanced Dashboard**: Visual progress with fl_chart
- **Multilingual RTL Support**: Proper rendering for Urdu and Pashto
- **Admin Foundation**: Content management database structure
- **Personalized Experience**: Tailored to student's education level and preferences
- **Secure**: Row-level security, no exposed API keys

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
- **Database**: PostgreSQL (via Supabase)
- **AI Model**: Google Gemini 1.5 Flash
- **Authentication**: Supabase Auth
- **Voice**: speech_to_text, flutter_tts

## Prerequisites

- Flutter SDK (3.5.0 or higher)
- A Supabase project
- Google Gemini API key

## Setup Instructions

### 1. Flutter Setup

Install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)

Verify installation:
```bash
flutter --version
```

### 2. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to your project dashboard
3. Navigate to SQL Editor
4. Run the migration files in order:
   - `supabase/migrations/001_initial_schema.sql` (Phase 1)
   - `supabase/migrations/002_lms_schema.sql` (Phase 2)
   - `supabase/migrations/003_admin_tables.sql` (Phase 2)
5. Copy your project URL and anon key from Settings > API

### 3. Gemini API Setup

1. Get an API key from [makersuite.google.com](https://makersuite.google.com/app/apikey)
2. In Supabase, go to Edge Functions
3. Deploy functions:
   - `ai-tutor`
   - `ai-question-generator`
   - `quiz-scoring`
4. Copy code from respective `supabase/functions/*/index.ts` files
5. Add environment variable: `GEMINI_API_KEY` = your actual Gemini API key

### 4. Configure the App

1. Create `.env` file in project root with your Supabase credentials
2. Use `.env.example` as a template
3. Add your actual Supabase URL and anon key

### 5. Install Dependencies

```bash
cd ai-turor
flutter pub get
```

### 6. Run the App

```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d android
```

## Project Structure

```
lib/
├── config/           # App configuration
│   ├── app_config.dart
│   ├── theme.dart
│   └── localization.dart
├── models/           # Data models
│   ├── user.dart
│   ├── conversation.dart
│   ├── message.dart
│   ├── subject.dart
│   ├── chapter.dart
│   ├── lesson.dart
│   ├── lesson_progress.dart
│   ├── quiz.dart
│   ├── quiz_question.dart
│   ├── quiz_attempt.dart
│   ├── bookmark.dart
│   └── examination.dart
├── providers/        # State management
│   ├── auth_provider.dart
│   ├── conversation_provider.dart
│   ├── settings_provider.dart
│   └── lms_provider.dart
├── screens/          # UI screens
│   ├── welcome/
│   ├── auth/
│   ├── dashboard/
│   ├── chat/
│   ├── profile/
│   ├── learning/
│   ├── quiz/
│   ├── bookmarks/
│   └── examination/
├── services/         # Backend services
│   ├── ai_service.dart
│   ├── voice_service.dart
│   ├── ai_question_generator.dart
│   ├── quiz_scoring_service.dart
│   └── pagination_service.dart
├── widgets/          # Reusable widgets
│   ├── subject_card.dart
│   └── rtl_wrapper.dart
└── main.dart
```

## Supported Education Levels

- Class 1-5
- Class 6-8
- Class 9-10
- Intermediate / College
- University
- Independent Learner

## Supported Languages

- English
- Urdu
- Pashto

## Security Notes

- Never commit API keys or secrets to GitHub
- Gemini API key is stored securely in Supabase Edge Functions
- Row Level Security (RLS) is enabled on all database tables
- Users can only access their own data

## Voice Features

Voice functionality depends on platform support:

- **English**: Fully supported on all platforms
- **Urdu**: May have limited TTS support depending on device
- **Pashto**: Limited TTS support, text-based fallback is recommended

## Testing

Run Flutter analyzer:
```bash
flutter analyze
```

Run tests:
```bash
flutter test
```

## Development Workflow

1. Make changes on a feature branch
2. Test thoroughly
3. Commit with meaningful messages
4. Create pull request
5. Do not merge without approval

## License

This project is for educational purposes.

## Support

For issues or questions, please refer to the project documentation or contact the development team.
