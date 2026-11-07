import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/classroom.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  List<Classroom> _classrooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  void _loadClassrooms() {
    setState(() {
      _isLoading = false;
      _classrooms = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Classrooms'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classrooms.isEmpty
              ? _buildEmptyState()
              : _buildClassroomList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No classrooms yet'),
          const SizedBox(height: 8),
          Text('Create or join a classroom', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _showJoinDialog,
                icon: const Icon(Icons.login),
                label: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classrooms.length,
      itemBuilder: (context, index) {
        final classroom = _classrooms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Text(classroom.name[0].toUpperCase()),
            ),
            title: Text(classroom.name),
            subtitle: Text('${classroom.subject ?? 'General'} • ${classroom.gradeLevel ?? 'All Levels'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Classroom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Classroom Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Grade Level'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Classroom created')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Classroom'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Invitation Code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joining classroom...')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
