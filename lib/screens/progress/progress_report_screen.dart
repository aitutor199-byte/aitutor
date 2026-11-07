import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../models/learning_analytics.dart';

class ProgressReportScreen extends StatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  bool _isLoading = true;
  List<LearningAnalytics> _analytics = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    // Load analytics from Supabase
    setState(() {
      _isLoading = false;
      _analytics = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Reports'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics.isEmpty
              ? _buildEmptyState()
              : _buildAnalyticsContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No progress data yet'),
          const SizedBox(height: 8),
          Text('Start learning to track your progress', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyActivityChart(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildSubjectPerformance(),
          const SizedBox(height: 24),
          _buildWeaknessesAndStrengths(),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    _buildBarGroup(0, 30),
                    _buildBarGroup(1, 45),
                    _buildBarGroup(2, 60),
                    _buildBarGroup(3, 40),
                    _buildBarGroup(4, 75),
                    _buildBarGroup(5, 50),
                    _buildBarGroup(6, 35),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt()]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, int value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: AppTheme.primaryGreen,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Questions Asked', '156', Icons.help_outline, AppTheme.purple),
        _buildStatCard('Lessons Completed', '24', Icons.check_circle, AppTheme.primaryGreen),
        _buildStatCard('Quizzes Taken', '12', Icons.quiz, AppTheme.blue),
        _buildStatCard('Study Time', '48h', Icons.access_time, AppTheme.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Subject Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildSubjectProgress('Mathematics', 85, AppTheme.primaryGreen),
            const SizedBox(height: 12),
            _buildSubjectProgress('Physics', 72, AppTheme.blue),
            const SizedBox(height: 12),
            _buildSubjectProgress('Chemistry', 68, AppTheme.purple),
            const SizedBox(height: 12),
            _buildSubjectProgress('English', 90, AppTheme.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgress(String subject, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject),
            Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildWeaknessesAndStrengths() {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: AppTheme.lightPink,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Weak Topics', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(label: Text('Organic Chemistry')),
                      Chip(label: Text('Calculus')),
                      Chip(label: Text('Electromagnetism')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: AppTheme.lightGreen,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      const Text('Strong Topics', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(label: Text('Algebra')),
                      Chip(label: Text('Grammar')),
                      Chip(label: Text('Mechanics')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
