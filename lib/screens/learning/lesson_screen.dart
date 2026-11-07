import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/lesson.dart';
import '../../models/lesson_progress.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lms_provider.dart';
import '../chat/chat_screen.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final String? chapterId;
  final String subjectName;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.chapterId,
    required this.subjectName,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Lesson? _lesson;
  LessonProgress? _progress;
  Timer? _timer;
  int _timeSpentSeconds = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeSpentSeconds++;
      });
    });
  }

  Future<void> _loadLesson() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      // Load lesson data
      final lesson = await lmsProvider.loadLessonById(widget.lessonId);
      if (lesson != null) {
        setState(() {
          _lesson = lesson;
        });
      }

      // Load progress
      await lmsProvider.loadLessonProgress(
        authProvider.currentUser!.id,
        widget.lessonId,
      );

      setState(() {
        _progress = lmsProvider.currentLessonProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsCompleted() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);

    await lmsProvider.updateLessonProgress(
      userId: authProvider.currentUser!.id,
      lessonId: widget.lessonId,
      isCompleted: true,
      completionPercentage: 100,
      timeSpentMinutes: (_timeSpentSeconds / 60).round(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lesson marked as completed!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _addBookmark() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);

    await lmsProvider.addBookmark(
      userId: authProvider.currentUser!.id,
      lessonId: widget.lessonId,
      title: _lesson?.title,
      note: 'Bookmarked from lesson',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson bookmarked'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _askAIAboutLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          subject: widget.subjectName,
          lessonContext: _lesson?.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.subjectName),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.subjectName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load lesson',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLesson,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lesson == null) {
      return _buildPlaceholder();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _addBookmark,
          ),
        ],
      ),
      body: _buildLessonContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _askAIAboutLesson,
        icon: const Icon(Icons.psychology),
        label: const Text('Ask AI'),
        backgroundColor: AppTheme.purple,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Lesson content will be loaded here',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${widget.lessonId}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lesson!.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_lesson!.learningObjectives.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Learning Objectives:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._lesson!.learningObjectives.map((objective) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(objective)),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lesson content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson Content',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(_lesson!.content),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Definitions
          if (_lesson!.definitions != null && _lesson!.definitions!.isNotEmpty)
            Card(
              color: AppTheme.lightYellow,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: AppTheme.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Key Definitions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._lesson!.definitions!.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.value.toString()),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Examples
          if (_lesson!.examples != null && _lesson!.examples!.isNotEmpty)
            Card(
              color: AppTheme.lightGreen,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Examples',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._lesson!.examples!.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(entry.value.toString()),
                        )),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Previous lesson
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _markAsCompleted,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Next lesson
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}
