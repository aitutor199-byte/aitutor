import 'package:flutter/material.dart';
import '../../config/theme.dart';

class UniversityDashboardScreen extends StatefulWidget {
  const UniversityDashboardScreen({super.key});

  @override
  State<UniversityDashboardScreen> createState() => _UniversityDashboardScreenState();
}

class _UniversityDashboardScreenState extends State<UniversityDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital University'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 24),
            _buildDepartments(),
            const SizedBox(height: 24),
            _buildPopularCourses(),
            const SizedBox(height: 24),
            _buildAcademicPrograms(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Digital University',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn from AI professors. Earn certificates.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Explore Courses', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Academic Departments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDepartmentChip('Computer Science', Icons.computer),
            _buildDepartmentChip('Mathematics', Icons.calculate),
            _buildDepartmentChip('Sciences', Icons.science),
            _buildDepartmentChip('Business', Icons.business),
            _buildDepartmentChip('Engineering', Icons.engineering),
            _buildDepartmentChip('Languages', Icons.translate),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 20),
      label: Text(label),
      backgroundColor: AppTheme.lightGreen,
    );
  }

  Widget _buildPopularCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Popular Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.book, color: AppTheme.primaryGreen),
            title: const Text('Introduction to Computer Science'),
            subtitle: const Text('12 weeks • Free'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.book, color: AppTheme.purple),
            title: const Text('Calculus Fundamentals'),
            subtitle: const Text('8 weeks • Free'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.book, color: AppTheme.blue),
            title: const Text('Physics for Beginners'),
            subtitle: const Text('10 weeks • Free'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicPrograms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Academic Programs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.school, size: 32, color: AppTheme.orange),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Professional Development', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Enhance your career skills', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
