import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/subject.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
import '../../providers/lms_provider.dart';
import 'lesson_screen.dart';

class SubjectScreen extends StatefulWidget {
  final Subject subject;

  const SubjectScreen({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);
    await lmsProvider.loadChapters(widget.subject.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
      ),
      body: Consumer<LMSProvider>(
        builder: (context, lmsProvider, child) {
          if (lmsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lmsProvider.chapters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chapters available yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lmsProvider.chapters.length,
            itemBuilder: (context, index) {
              final chapter = lmsProvider.chapters[index];
              return _buildChapterCard(chapter);
            },
          );
        },
      ),
    );
  }

  Widget _buildChapterCard(Chapter chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.lightGreen,
          child: Icon(
            Icons.book,
            color: AppTheme.primaryGreen,
          ),
        ),
        title: Text(
          chapter.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: chapter.description != null
            ? Text(
                chapter.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        children: [
          FutureBuilder(
            future: _loadLessonsForChapter(chapter.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final lessons = snapshot.data ?? [];
              if (lessons.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No lessons available'),
                );
              }

              return Column(
                children: lessons.map((lesson) {
                  return ListTile(
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(lesson.title),
                    trailing: Icon(
                      lesson.isPublished
                          ? Icons.check_circle
                          : Icons.lock,
                      color: lesson.isPublished
                          ? AppTheme.primaryGreen
                          : Colors.grey,
                    ),
                    onTap: lesson.isPublished
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LessonScreen(
                                  lessonId: lesson.id,
                                  chapterId: chapter.id,
                                  subjectName: widget.subject.name,
                                ),
                              ),
                            );
                          }
                        : null,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Lesson>> _loadLessonsForChapter(String chapterId) async {
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);
    await lmsProvider.loadLessons(chapterId);
    return lmsProvider.lessons;
  }
}
