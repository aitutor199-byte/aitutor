import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/study_plan.dart';
import '../../models/study_plan_task.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  bool _isGenerating = false;
  List<StudyPlan> _studyPlans = [];
  List<StudyPlanTask> _tasks = [];

  Future<void> _generateStudyPlan() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate study plan via AI
      // This would call an Edge Function to create a personalized plan
      
      setState(() {
        _studyPlans = [];
        _tasks = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate study plan: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Plan'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isGenerating ? null : _generateStudyPlan,
          ),
        ],
      ),
      body: _studyPlans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No study plan yet'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateStudyPlan,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate AI Study Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purple,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _studyPlans.length,
              itemBuilder: (context, index) {
                final plan = _studyPlans[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Chip(
                              label: Text(plan.isActive ? 'Active' : 'Inactive'),
                              backgroundColor: plan.isActive ? AppTheme.lightGreen : Colors.grey.shade200,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (plan.subjects != null)
                          Wrap(
                            spacing: 8,
                            children: plan.subjects!.map((subject) {
                              return Chip(label: Text(subject));
                            }).toList(),
                          ),
                        const SizedBox(height: 16),
                        Text('Daily Study: ${plan.dailyStudyMinutes ?? 0} minutes'),
                        Text('Weekly Study: ${plan.weeklyStudyHours ?? 0} hours'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
