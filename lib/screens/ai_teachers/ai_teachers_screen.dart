import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/ai_teaching_agent.dart';

class AITeachersScreen extends StatefulWidget {
  const AITeachersScreen({super.key});

  @override
  State<AITeachersScreen> createState() => _AITeachersScreenState();
}

class _AITeachersScreenState extends State<AITeachersScreen> {
  List<AITeachingAgent> _agents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  void _loadAgents() {
    setState(() {
      _isLoading = false;
      _agents = [
        AITeachingAgent(
          id: '1',
          name: 'Math AI Teacher',
          specialization: 'mathematics',
          description: 'Specialized mathematics teaching agent',
          capabilities: {'algebra': true, 'geometry': true, 'calculus': true},
          systemPrompt: 'You are a mathematics teacher...',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        AITeachingAgent(
          id: '2',
          name: 'Science AI Teacher',
          specialization: 'science',
          description: 'Physics, chemistry, and biology expert',
          capabilities: {'physics': true, 'chemistry': true, 'biology': true},
          systemPrompt: 'You are a science teacher...',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        AITeachingAgent(
          id: '3',
          name: 'English AI Teacher',
          specialization: 'english',
          description: 'English language and literature specialist',
          capabilities: {'grammar': true, 'vocabulary': true, 'writing': true},
          systemPrompt: 'You are an English teacher...',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        AITeachingAgent(
          id: '4',
          name: 'Programming AI Teacher',
          specialization: 'programming',
          description: 'Computer science and programming expert',
          capabilities: {'programming': true, 'debugging': true, 'algorithms': true},
          systemPrompt: 'You are a programming teacher...',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        AITeachingAgent(
          id: '5',
          name: 'General AI Teacher',
          specialization: 'general',
          description: 'General academic subjects and homework help',
          capabilities: {'general': true, 'homework': true, 'study': true},
          systemPrompt: 'You are a general education teacher...',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Teachers'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _agents.length,
              itemBuilder: (context, index) {
                final agent = _agents[index];
                return Card(
                  child: InkWell(
                    onTap: () => _startChatWithAgent(agent),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: _getAgentColor(agent.specialization),
                            child: Icon(
                              _getAgentIcon(agent.specialization),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            agent.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            agent.specialization,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getAgentColor(String specialization) {
    switch (specialization) {
      case 'mathematics':
        return AppTheme.primaryGreen;
      case 'science':
        return AppTheme.blue;
      case 'english':
        return AppTheme.purple;
      case 'programming':
        return AppTheme.teal;
      default:
        return AppTheme.orange;
    }
  }

  IconData _getAgentIcon(String specialization) {
    switch (specialization) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.translate;
      case 'programming':
        return Icons.code;
      default:
        return Icons.school;
    }
  }

  void _startChatWithAgent(AITeachingAgent agent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AgentChatScreen(agent: agent),
      ),
    );
  }
}

class _AgentChatScreen extends StatefulWidget {
  final AITeachingAgent agent;

  const _AgentChatScreen({super.key, required this.agent});

  @override
  State<_AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<_AgentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agent.name),
        backgroundColor: _getAgentColor(widget.agent.specialization),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getAgentIcon(widget.agent.specialization),
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Start learning with ${widget.agent.name}'),
                        const SizedBox(height: 8),
                        Text('Ask questions about ${widget.agent.specialization}',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primaryGreen : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['message'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAgentColor(String specialization) {
    switch (specialization) {
      case 'mathematics':
        return AppTheme.primaryGreen;
      case 'science':
        return AppTheme.blue;
      case 'english':
        return AppTheme.purple;
      case 'programming':
        return AppTheme.teal;
      default:
        return AppTheme.orange;
    }
  }

  IconData _getAgentIcon(String specialization) {
    switch (specialization) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.translate;
      case 'programming':
        return Icons.code;
      default:
        return Icons.school;
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': _messageController.text});
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'sender': 'agent',
          'message': 'I would help you with that. This is a simulated response from ${widget.agent.name}.'
        });
      });
    });

    _messageController.clear();
  }
}
