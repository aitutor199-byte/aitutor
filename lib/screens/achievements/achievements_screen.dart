import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  Set<String> _unlockedAchievements = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() {
    // Load achievements from Supabase
    setState(() {
      _achievements = [];
      _unlockedAchievements = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: _achievements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                final isUnlocked = _unlockedAchievements.contains(achievement.id);
                return Card(
                  color: isUnlocked ? AppTheme.lightGreen : Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(achievement.icon),
                          size: 48,
                          color: isUnlocked ? AppTheme.primaryGreen : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          achievement.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${achievement.xpReward} XP',
                          style: TextStyle(
                            color: isUnlocked ? AppTheme.primaryGreen : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isUnlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(Icons.lock, size: 16, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIcon(String? icon) {
    switch (icon) {
      case 'quiz':
        return Icons.quiz;
      case 'fire':
        return Icons.local_fire_department;
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'check_circle':
        return Icons.check_circle;
      case 'star':
        return Icons.star;
      case 'trending_up':
        return Icons.trending_up;
      case 'style':
        return Icons.style;
      default:
        return Icons.emoji_events;
    }
  }
}
