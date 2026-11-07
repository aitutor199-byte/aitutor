import 'package:supabase_flutter/supabase_flutter.dart';

class AIQuestionGenerator {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> generateQuestions({
    required String subject,
    required String educationLevel,
    required String chapter,
    required String difficulty,
    required int questionCount,
    required String questionType,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai-question-generator',
        body: {
          'subject': subject,
          'education_level': educationLevel,
          'chapter': chapter,
          'difficulty': difficulty,
          'question_count': questionCount,
          'question_type': questionType,
        },
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate questions: ${response.status}');
      }
    } catch (e) {
      throw Exception('AI Question Generator Error: $e');
    }
  }
}
