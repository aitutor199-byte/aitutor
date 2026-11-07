import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';

class QuizScoringService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Calculate quiz score on the backend to prevent client manipulation
  Future<Map<String, dynamic>> calculateQuizScore({
    required String attemptId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'quiz-scoring',
        body: {
          'attempt_id': attemptId,
        },
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to calculate score: ${response.status}');
      }
    } catch (e) {
      throw Exception('Quiz Scoring Error: $e');
    }
  }

  /// Validate quiz answer on backend
  Future<bool> validateAnswer({
    required String questionId,
    required String userAnswer,
  }) async {
    try {
      final response = await _supabase
          .from('quiz_questions')
          .select('correct_answer')
          .eq('id', questionId)
          .single();

      final correctAnswer = response['correct_answer'] as String;
      return userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    } catch (e) {
      throw Exception('Answer validation error: $e');
    }
  }
}
