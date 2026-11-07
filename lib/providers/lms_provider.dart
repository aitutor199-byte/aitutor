import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/lesson_progress.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_attempt.dart';
import '../models/bookmark.dart';

class LMSProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Data holders
  List<Subject> _subjects = [];
  List<Chapter> _chapters = [];
  List<Lesson> _lessons = [];
  LessonProgress? _currentLessonProgress;
  List<Quiz> _quizzes = [];
  List<QuizQuestion> _currentQuizQuestions = [];
  QuizAttempt? _currentQuizAttempt;
  List<Bookmark> _bookmarks = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Subject> get subjects => _subjects;
  List<Chapter> get chapters => _chapters;
  List<Lesson> get lessons => _lessons;
  LessonProgress? get currentLessonProgress => _currentLessonProgress;
  List<Quiz> get quizzes => _quizzes;
  List<QuizQuestion> get currentQuizQuestions => _currentQuizQuestions;
  QuizAttempt? get currentQuizAttempt => _currentQuizAttempt;
  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load Subjects with pagination
  Future<void> loadSubjects({int page = 1, int pageSize = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await _supabase
          .from('subjects')
          .select()
          .eq('is_active', true)
          .order('order_index')
          .range(from, to);

      _subjects = (response as List)
          .map((json) => Subject.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load subjects error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Chapters for a Subject
  Future<void> loadChapters(String subjectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('subject_id', subjectId)
          .eq('is_active', true)
          .order('order_index');

      _chapters = (response as List)
          .map((json) => Chapter.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load chapters error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Lessons for a Chapter
  Future<void> loadLessons(String chapterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('chapter_id', chapterId)
          .eq('is_published', true)
          .order('order_index');

      _lessons = (response as List)
          .map((json) => Lesson.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load lessons error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Lesson Progress
  Future<void> loadLessonProgress(String userId, String lessonId) async {
    try {
      final response = await _supabase
          .from('lesson_progress')
          .select()
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      if (response != null) {
        _currentLessonProgress = LessonProgress.fromJson(response);
      } else {
        _currentLessonProgress = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Load lesson progress error: $e');
    }
  }

  // Update Lesson Progress
  Future<void> updateLessonProgress({
    required String userId,
    required String lessonId,
    bool? isCompleted,
    int? completionPercentage,
    int? timeSpentMinutes,
  }) async {
    try {
      final data = <String, dynamic>{
        'last_accessed_at': DateTime.now().toIso8601String(),
      };

      if (isCompleted != null) data['is_completed'] = isCompleted;
      if (completionPercentage != null) {
        data['completion_percentage'] = completionPercentage;
      }
      if (timeSpentMinutes != null) {
        data['time_spent_minutes'] = timeSpentMinutes;
      }

      if (_currentLessonProgress == null) {
        // Create new progress
        final response = await _supabase.from('lesson_progress').insert({
          'user_id': userId,
          'lesson_id': lessonId,
          ...data,
        }).select().single();

        _currentLessonProgress = LessonProgress.fromJson(response);
      } else {
        // Update existing
        await _supabase
            .from('lesson_progress')
            .update(data)
            .eq('id', _currentLessonProgress!.id);

        await loadLessonProgress(userId, lessonId);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Update lesson progress error: $e');
      notifyListeners();
    }
  }

  // Load Quizzes
  Future<void> loadQuizzes({
    String? lessonId,
    String? chapterId,
    String? subjectId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var query = _supabase
          .from('quizzes')
          .select()
          .eq('is_published', true);

      if (lessonId != null) query = query.eq('lesson_id', lessonId);
      if (chapterId != null) query = query.eq('chapter_id', chapterId);
      if (subjectId != null) query = query.eq('subject_id', subjectId);

      final response = await query;

      _quizzes = (response as List)
          .map((json) => Quiz.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load quizzes error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Quiz Questions
  Future<void> loadQuizQuestions(String quizId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('order_index');

      _currentQuizQuestions = (response as List)
          .map((json) => QuizQuestion.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load quiz questions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start Quiz Attempt
  Future<void> startQuizAttempt({
    required String userId,
    required String quizId,
    required int totalMarks,
  }) async {
    try {
      final response = await _supabase.from('quiz_attempts').insert({
        'user_id': userId,
        'quiz_id': quizId,
        'total_marks': totalMarks,
      }).select().single();

      _currentQuizAttempt = QuizAttempt.fromJson(response);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Start quiz attempt error: $e');
      notifyListeners();
    }
  }

  // Submit Quiz Answer
  Future<void> submitQuizAnswer({
    required String attemptId,
    required String questionId,
    required String userAnswer,
    required bool isCorrect,
    required int marksObtained,
  }) async {
    try {
      await _supabase.from('quiz_answers').insert({
        'attempt_id': attemptId,
        'question_id': questionId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'marks_obtained': marksObtained,
      });
    } catch (e) {
      debugPrint('Submit quiz answer error: $e');
    }
  }

  // Complete Quiz Attempt
  Future<void> completeQuizAttempt({
    required String attemptId,
    required int obtainedMarks,
    required double percentage,
    required bool isPassed,
  }) async {
    try {
      await _supabase.from('quiz_attempts').update({
        'submitted_at': DateTime.now().toIso8601String(),
        'obtained_marks': obtainedMarks,
        'percentage': percentage,
        'is_passed': isPassed,
      }).eq('id', attemptId);

      await loadQuizAttempt(attemptId);
    } catch (e) {
      debugPrint('Complete quiz attempt error: $e');
    }
  }

  // Load Quiz Attempt
  Future<void> loadQuizAttempt(String attemptId) async {
    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select()
          .eq('id', attemptId)
          .single();

      _currentQuizAttempt = QuizAttempt.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Load quiz attempt error: $e');
    }
  }

  // Load Bookmarks
  Future<void> loadBookmarks(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _bookmarks = (response as List)
          .map((json) => Bookmark.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load bookmarks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Bookmark
  Future<void> addBookmark({
    required String userId,
    String? lessonId,
    String? questionId,
    String? explanationId,
    String? title,
    String? note,
  }) async {
    try {
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'lesson_id': lessonId,
        'question_id': questionId,
        'explanation_id': explanationId,
        'title': title,
        'note': note,
      });

      await loadBookmarks(userId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Add bookmark error: $e');
      notifyListeners();
    }
  }

  // Remove Bookmark
  Future<void> removeBookmark(String bookmarkId, String userId) async {
    try {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('id', bookmarkId);

      await loadBookmarks(userId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Remove bookmark error: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
