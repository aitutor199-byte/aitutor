import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_question_generator.dart';

class QuestionGeneratorScreen extends StatefulWidget {
  const QuestionGeneratorScreen({super.key});

  @override
  State<QuestionGeneratorScreen> createState() => _QuestionGeneratorScreenState();
}

class _QuestionGeneratorScreenState extends State<QuestionGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionGenerator = AIQuestionGenerator();

  String _selectedSubject = Appconfig.subjects[0];
  String _selectedEducationLevel = Appconfig.educationLevels[0];
  String _selectedDifficulty = 'Medium';
  String _selectedQuestionType = 'multiple_choice';
  int _questionCount = 5;
  bool _isGenerating = false;
  String? _errorMessage;
  List<dynamic> _generatedQuestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Question Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Practice Questions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use AI to generate educational questions tailored to your needs.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdownField(
                label: 'Subject',
                value: _selectedSubject,
                items: Appconfig.subjects,
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Education Level',
                value: _selectedEducationLevel,
                items: Appconfig.educationLevels,
                onChanged: (value) {
                  setState(() {
                    _selectedEducationLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Difficulty',
                value: _selectedDifficulty,
                items: ['Easy', 'Medium', 'Hard'],
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Question Type',
                value: _selectedQuestionType,
                items: ['multiple_choice', 'true_false', 'fill_blank', 'short_answer'],
                onChanged: (value) {
                  setState(() {
                    _selectedQuestionType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildSliderField(
                label: 'Number of Questions',
                value: _questionCount.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    _questionCount = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateQuestions,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate Questions'),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: AppTheme.lightPink,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_generatedQuestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Generated Questions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ..._generatedQuestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.lightGreen,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question['question_text'] ?? '',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          if (question['options'] != null) ...[
                            const SizedBox(height: 12),
                            ...question['options'].entries.map((opt) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 44, bottom: 4),
                                child: Row(
                                  children: [
                                    Text('${opt.key}: '),
                                    Expanded(child: Text(opt.value.toString())),
                                  ],
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: AppTheme.primaryGreen),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Correct Answer: ${question['correct_answer']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (question['explanation'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(question['explanation']),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _generatedQuestions = [];
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Save to quiz
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save as Quiz'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Chip(label: Text(value.toInt().toString())),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _generateQuestions() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedQuestions = [];
    });

    try {
      final result = await _questionGenerator.generateQuestions(
        subject: _selectedSubject,
        educationLevel: _selectedEducationLevel,
        chapter: 'General',
        difficulty: _selectedDifficulty.toLowerCase(),
        questionCount: _questionCount,
        questionType: _selectedQuestionType,
      );

      setState(() {
        _generatedQuestions = result['questions'] ?? [];
      });

      if (_generatedQuestions.isEmpty) {
        setState(() {
          _errorMessage = 'No questions were generated. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate questions: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
}
