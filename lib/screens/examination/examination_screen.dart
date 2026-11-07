import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/examination.dart';
import '../../models/quiz_question.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lms_provider.dart';

class ExaminationScreen extends StatefulWidget {
  final Examination examination;

  const ExaminationScreen({
    super.key,
    required this.examination,
  });

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> {
  bool _isStarted = false;
  bool _isSubmitted = false;
  bool _isLoading = false;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _currentQuestionIndex = 0;
  Map<String, String> _userAnswers = {};
  List<QuizQuestion> _questions = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExamination() async {
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      await lmsProvider.loadExaminationQuestions(widget.examination.id);
      setState(() {
        _questions = lmsProvider.currentQuizQuestions;
        _isStarted = true;
        _remainingSeconds = widget.examination.durationMinutes * 60;
      });
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading examination: $e'), backgroundColor: Colors.red),
      );
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
          _submitExamination();
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
      _userAnswers[_questions[_currentQuestionIndex]['id']] = answer;
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

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_questions[_currentQuestionIndex].id] = answer;
    });
  }

  void _submitExamination() {
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
    });
    // Calculate and submit results
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStarted) {
      return _buildStartScreen();
    }

    if (_isSubmitted) {
      return _buildResultScreen();
    }

    return _buildExaminationScreen();
  }

  Widget _buildStartScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.examination.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                widget.examination.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.examination.description != null)
                Text(
                  widget.examination.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              _buildInfoCard(
                icon: Icons.timer,
                label: 'Duration',
                value: '${widget.examination.durationMinutes} minutes',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.star,
                label: 'Total Marks',
                value: '${widget.examination.totalMarks}',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.done_all,
                label: 'Passing Score',
                value: '${widget.examination.passingScore}%',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startExamination,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Examination'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExaminationScreen() {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.examination.title)),
        body: const Center(child: Text('No questions available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examination.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.timer, color: _remainingSeconds < 300 ? Colors.red : AppTheme.orange),
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
          LinearProgressIndicator(value: (_currentQuestionIndex + 1) / _questions.length),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Question ${_currentQuestionIndex + 1} of ${_questions.length}'),
          ),
          Expanded(
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_questions[_currentQuestionIndex]['question_text'] ?? 'Question'),
                ),
              ),
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
                    onPressed: _currentQuestionIndex < _questions.length - 1 ? _nextQuestion : _submitExamination,
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

  Widget _buildResultScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.examination.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 24),
            Text(
              'Examination Submitted',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Results will be available after review'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('Return to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
