import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedTab = 'global';
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          Switch(
            value: _isVisible,
            onChanged: (value) {
              setState(() {
                _isVisible = value;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryGreen,
            child: Row(
              children: [
                _buildTabButton('Global', 'global'),
                const SizedBox(width: 8),
                _buildTabButton('Weekly', 'weekly'),
                const SizedBox(width: 8),
                _buildTabButton('Monthly', 'monthly'),
              ],
            ),
          ),
          Expanded(
            child: _buildLeaderboardList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          foregroundColor: isSelected ? AppTheme.primaryGreen : Colors.white,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(index),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('Student ${index + 1}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(1000 - index * 50)} XP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${index + 1} badges',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.brown.shade400;
      default:
        return AppTheme.primaryGreen;
    }
  }
}
