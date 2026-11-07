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
  }) async {
    try {
      // Build conversation history for context
      final history = conversationHistory
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      // Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'ai-tutor',
        body: {
          'message': message,
          'history': history,
          'education_level': educationLevel,
          'language': language,
          'subject': subject,
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
}
