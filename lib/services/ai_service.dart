import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class AIService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> getAIResponse({
    required String message,
    required List<Message> conversationHistory,
    required String educationLevel,
    required String language,
    String? subject,
    String? lessonContext,
    String? lessonTitle,
  }) async {
    try {
      // Build conversation history for context
      final history = conversationHistory
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      // Build system prompt with lesson context if available
      String systemPrompt = '';
      if (lessonContext != null || lessonTitle != null) {
        systemPrompt = 'Context: This question is about the lesson "${lessonTitle ?? lessonContext}". ';
      }

      // Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'ai-tutor',
        body: {
          'message': message,
          'history': history,
          'education_level': educationLevel,
          'language': language,
          'subject': subject,
          'lesson_context': lessonContext,
          'lesson_title': lessonTitle,
          'system_prompt': systemPrompt,
        },
      );

      if (response.status == 200) {
        final data = response.data;
        return data['response'] as String? ?? 'I apologize, but I could not generate a response.';
      } else {
        throw Exception('Failed to get AI response: ${response.status}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  Future<String> getLessonExplanation({
    required String lessonTitle,
    required String lessonContent,
    required String educationLevel,
    required String language,
    String? explanationType,
  }) async {
    try {
      String prompt = 'Explain this lesson for ${educationLevel} students in ${language}.\n\n';
      prompt += 'Lesson Title: ${lessonTitle}\n';
      prompt += 'Content: ${lessonContent}\n\n';

      if (explanationType != null) {
        prompt += 'Focus on: ${explanationType}\n';
      }

      final response = await _supabase.functions.invoke(
        'ai-tutor',
        body: {
          'message': prompt,
          'education_level': educationLevel,
          'language': language,
          'is_lesson_explanation': true,
        },
      );

      if (response.status == 200) {
        final data = response.data;
        return data['response'] as String? ?? 'I apologize, but I could not generate an explanation.';
      } else {
        throw Exception('Failed to get lesson explanation: ${response.status}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }
}
