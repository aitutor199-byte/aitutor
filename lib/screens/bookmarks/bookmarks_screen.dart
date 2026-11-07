import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/bookmark.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lms_provider.dart';
import '../learning/lesson_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);
    await lmsProvider.loadBookmarks(authProvider.currentUser!.id);
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lmsProvider = Provider.of<LMSProvider>(context, listen: false);
    await lmsProvider.removeBookmark(bookmark.id, authProvider.currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
      ),
      body: Consumer<LMSProvider>(
        builder: (context, lmsProvider, child) {
          if (lmsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lmsProvider.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark lessons and explanations to find them easily',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lmsProvider.bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = lmsProvider.bookmarks[index];
              return _buildBookmarkCard(bookmark);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookmarkCard(Bookmark bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          bookmark.lessonId != null ? Icons.menu_book : Icons.lightbulb,
          color: AppTheme.primaryGreen,
        ),
        title: Text(
          bookmark.title ?? 'Untitled Bookmark',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: bookmark.note != null
            ? Text(
                bookmark.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                _formatDate(bookmark.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove Bookmark'),
                content: const Text('Are you sure you want to remove this bookmark?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _removeBookmark(bookmark);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
          },
        ),
        onTap: bookmark.lessonId != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(
                      lessonId: bookmark.lessonId!,
                      subjectName: 'Subject',
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
