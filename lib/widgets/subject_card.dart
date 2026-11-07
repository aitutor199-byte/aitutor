import 'package:flutter/material.dart';
import '../config/theme.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  Color _getCardColor() {
    switch (subject) {
      case 'Mathematics':
        return AppTheme.lightBlue;
      case 'Physics':
        return AppTheme.lightPurple;
      case 'Chemistry':
        return AppTheme.lightGreen;
      case 'Biology':
        return AppTheme.lightPink;
      case 'English':
        return AppTheme.lightYellow;
      case 'Computer Science':
        return AppTheme.lightCyan;
      case 'General Science':
        return AppTheme.lightGreen;
      case 'History':
        return AppTheme.lightYellow;
      case 'Geography':
        return AppTheme.lightBlue;
      case 'University Studies':
        return AppTheme.lightPurple;
      default:
        return AppTheme.lightBlue;
    }
  }

  IconData _getSubjectIcon() {
    switch (subject) {
      case 'Mathematics':
        return Icons.calculate;
      case 'Physics':
        return Icons.science;
      case 'Chemistry':
        return Icons.biotech;
      case 'Biology':
        return Icons.eco;
      case 'English':
        return Icons.menu_book;
      case 'Computer Science':
        return Icons.computer;
      case 'General Science':
        return Icons.science;
      case 'History':
        return Icons.history_edu;
      case 'Geography':
        return Icons.public;
      case 'University Studies':
        return Icons.school;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getCardColor(),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getSubjectIcon(),
                size: 40,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 12),
              Text(
                subject,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Learn and explore',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
