import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LanguageLearningScreen extends StatefulWidget {
  const LanguageLearningScreen({super.key});

  @override
  State<LanguageLearningScreen> createState() => _LanguageLearningScreenState();
}

class _LanguageLearningScreenState extends State<LanguageLearningScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Learning'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildLearningContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildLanguageCard('English', 'English'),
          const SizedBox(width: 12),
          _buildLanguageCard('اردو', 'Urdu'),
          const SizedBox(width: 12),
          _buildLanguageCard('پښتو', 'Pashto'),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(String name, String language) {
    final isSelected = _selectedLanguage == language;
    return Card(
      color: isSelected ? AppTheme.primaryGreen : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearningContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('$_selectedLanguage Learning'),
          const SizedBox(height: 8),
          Text('Daily vocabulary, grammar, and practice', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActivityCard(Icons.book, 'Vocabulary'),
              const SizedBox(width: 16),
              _buildActivityCard(Icons.quiz, 'Grammar'),
              const SizedBox(width: 16),
              _buildActivityCard(Icons.record_voice_over, 'Speaking'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(IconData icon, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryGreen),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
