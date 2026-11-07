import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/quiz.dart';
import '../../models/quiz_question.dart';
import '../../models/quiz_attempt.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lms_provider.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Quiz? _quiz;
  List<QuizQuestion> _questions = [];
  QuizAttempt? _attempt;
  int _currentQuestionIndex = 0;
  Map<String, String> _userAnswers = {};
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitted = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      await lmsProvider.loadQuizQuestions(widget.quizId);
      setState(() {
        _questions = lmsProvider.currentQuizQuestions;
      });

      if (_questions.isEmpty) {
        setState(() {
          _errorMessage = 'No questions found for this quiz';
        });
      } else {
        await lmsProvider.startQuizAttempt(
          userId: authProvider.currentUser!.id,
          quizId: widget.quizId,
          totalMarks: _questions.fold(0, (sum, q) => sum + q.marks),
        );

        setState(() {
          _attempt = lmsProvider.currentQuizAttempt;
        });

        _quiz = await lmsProvider.getQuizById(widget.quizId);
        if (_quiz?.timeLimitMinutes != null) {
          _remainingSeconds = _quiz!.timeLimitMinutes! * 60;
          _startTimer();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quiz: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _submitQuiz();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_questions[_currentQuestionIndex].id] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
    });

    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);

    int obtainedMarks = 0;
    for (var question in _questions) {
      final userAnswer = _userAnswers[question.id];
      final isCorrect = userAnswer == question.correctAnswer;
      if (isCorrect) {
        obtainedMarks += question.marks;
      }

      await lmsProvider.submitQuizAnswer(
        attemptId: _attempt!.id,
        questionId: question.id,
        userAnswer: userAnswer ?? '',
        isCorrect: isCorrect,
        marksObtained: isCorrect ? question.marks : 0,
      );
    }

    final totalMarks = _questions.fold(0, (sum, q) => sum + q.marks);
    final percentage = (obtainedMarks / totalMarks) * 100;
    final isPassed = percentage >= 60;

    await lmsProvider.completeQuizAttempt(
      attemptId: _attempt!.id,
      obtainedMarks: obtainedMarks,
      percentage: percentage,
      isPassed: isPassed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuiz,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text('No questions available')),
      );
    }

    if (_isSubmitted) {
      return _buildResultScreen();
    }

    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        actions: [
          if (_remainingSeconds > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppTheme.orange),
                    const SizedBox(width: 8),
                    Text(_formatTime(_remainingSeconds)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentQuestionIndex + 1} of ${_questions.length}'),
                if (_questions[_currentQuestionIndex].marks > 1)
                  Chip(label: Text('${_questions[_currentQuestionIndex].marks} marks')),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildQuestionContent(_questions[_currentQuestionIndex]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _userAnswers[_questions[_currentQuestionIndex].id] != null
                        ? (_currentQuestionIndex < _questions.length - 1 ? _nextQuestion : _submitQuiz)
                        : null,
                    child: Text(_currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(QuizQuestion question) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.questionText, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (question.questionType == 'multiple_choice')
              ..._buildMultipleChoiceOptions(question)
            else if (question.questionType == 'true_false')
              ..._buildTrueFalseOptions(question)
            else if (question.questionType == 'fill_blank')
              _buildFillInBlank(question)
            else if (question.questionType == 'short_answer')
              _buildShortAnswer(question),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions(QuizQuestion question) {
    final options = question.options as Map<String, dynamic>?;
    if (options == null) return [];

    return options.entries.map((entry) {
      final isSelected = _userAnswers[question.id] == entry.key;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _selectAnswer(entry.key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.lightGreen : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppTheme.primaryGreen : Colors.grey),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.value.toString())),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTrueFalseOptions(QuizQuestion question) {
    return [
      _buildOptionButton(question, 'True', 'true'),
      _buildOptionButton(question, 'False', 'false'),
    ];
  }

  Widget _buildOptionButton(QuizQuestion question, String label, String value) {
    final isSelected = _userAnswers[question.id] == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectAnswer(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.lightGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFillInBlank(QuizQuestion question) {
    final controller = TextEditingController(text: _userAnswers[question.id] ?? '');
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Your answer'),
      onChanged: (value) => _selectAnswer(value),
    );
  }

  Widget _buildShortAnswer(QuizQuestion question) {
    final controller = TextEditingController(text: _userAnswers[question.id] ?? '');
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(labelText: 'Your answer'),
      onChanged: (value) => _selectAnswer(value),
    );
  }

  Widget _buildResultScreen() {
    final percentage = _attempt?.percentage ?? 0;
    final isPassed = _attempt?.isPassed ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: isPassed ? AppTheme.lightGreen : AppTheme.lightPink,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(isPassed ? Icons.check_circle : Icons.cancel,
                        size: 80, color: isPassed ? AppTheme.primaryGreen : Colors.red),
                    const SizedBox(height: 16),
                    Text(isPassed ? 'Quiz Passed!' : 'Quiz Failed',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: isPassed ? AppTheme.primaryGreen : Colors.red)),
                    const SizedBox(height: 8),
                    Text('${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: isPassed ? AppTheme.primaryGreen : Colors.red,
                              fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Obtained', '${_attempt?.obtainedMarks ?? 0}'),
                        _buildStat('Total', '${_attempt?.totalMarks ?? 0}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
