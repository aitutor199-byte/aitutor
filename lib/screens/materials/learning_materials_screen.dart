import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LearningMaterialsScreen extends StatefulWidget {
  const LearningMaterialsScreen({super.key});

  @override
  State<LearningMaterialsScreen> createState() => _LearningMaterialsScreenState();
}

class _LearningMaterialsScreenState extends State<LearningMaterialsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Materials'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showGenerateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGenerateOptions(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMaterialsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildOptionCard(Icons.summarize, 'Summary', () => _generateMaterial('summary')),
          const SizedBox(width: 12),
          _buildOptionCard(Icons.note, 'Notes', () => _generateMaterial('notes')),
          const SizedBox(width: 12),
          _buildOptionCard(Icons.style, 'Flashcards', () => _generateMaterial('flashcards')),
          const SizedBox(width: 12),
          _buildOptionCard(Icons.quiz, 'Questions', () => _generateMaterial('questions')),
          const SizedBox(width: 12),
          _buildOptionCard(Icons.book, 'Explanation', () => _generateMaterial('explanation')),
        ],
      ),
    );
  }

  Widget _buildOptionCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildMaterialsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No materials yet'),
          const SizedBox(height: 8),
          Text('Generate materials using AI', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Learning Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'summary', child: Text('Summary')),
                DropdownMenuItem(value: 'notes', child: Text('Notes')),
                DropdownMenuItem(value: 'flashcards', child: Text('Flashcards')),
                DropdownMenuItem(value: 'questions', child: Text('Questions')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateMaterial('custom');
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _generateMaterial(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating $type...')),
    );
  }
}
