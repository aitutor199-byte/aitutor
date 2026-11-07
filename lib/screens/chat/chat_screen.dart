import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai_service.dart';
import '../../services/voice_service.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String? subject;

  const ChatScreen({
    super.key,
    this.conversationId,
    this.subject,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceService _voiceService = VoiceService();
  final AIService _aiService = AIService();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeVoice();
    _loadConversation();
  }

  Future<void> _initializeVoice() async {
    await _voiceService.init();
  }

  Future<void> _loadConversation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);

    if (widget.conversationId != null) {
      conversationProvider.setCurrentConversation(
        conversationProvider.conversations
            .firstWhere((c) => c.id == widget.conversationId),
      );
      await conversationProvider.loadMessages(widget.conversationId!);
    } else if (widget.subject != null) {
      final newConversation = await conversationProvider.createConversation(
        userId: authProvider.currentUser!.id,
        title: widget.subject!,
        subject: widget.subject,
      );
      if (newConversation != null) {
        await conversationProvider.loadMessages(newConversation.id);
      }
    }

    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    // Create conversation if needed
    if (conversationProvider.currentConversation == null) {
      await conversationProvider.createConversation(
        userId: authProvider.currentUser!.id,
        title: 'New Conversation',
      );
    }

    // Add user message
    await conversationProvider.addMessage(
      conversationId: conversationProvider.currentConversation!.id,
      userId: authProvider.currentUser!.id,
      role: 'user',
      content: message,
    );

    _messageController.clear();
    _scrollToBottom();

    // Get AI response
    try {
      final aiResponse = await _aiService.getAIResponse(
        message: message,
        conversationHistory: conversationProvider.currentMessages,
        educationLevel: authProvider.currentUser!.educationLevel,
        language: authProvider.currentUser!.preferredLanguage,
        subject: conversationProvider.currentConversation?.subject,
      );

      // Add AI message
      await conversationProvider.addMessage(
        conversationId: conversationProvider.currentConversation!.id,
        userId: authProvider.currentUser!.id,
        role: 'assistant',
        content: aiResponse,
      );

      _scrollToBottom();

      // Speak response if enabled
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.voiceEnabled) {
        await _speakResponse(aiResponse);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startListening() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    if (!settingsProvider.speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is disabled in settings'),
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
    });

    final result = await _voiceService.startListening(
      language: settingsProvider.voiceLanguage,
    );

    setState(() {
      _isListening = false;
    });

    if (result != null) {
      _messageController.text = result;
    }
  }

  Future<void> _speakResponse(String text) async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    setState(() {
      _isSpeaking = true;
    });

    await _voiceService.speak(
      text: text,
      language: settingsProvider.voiceLanguage,
      rate: settingsProvider.speechRate,
      pitch: settingsProvider.speechPitch,
    );

    setState(() {
      _isSpeaking = false;
    });
  }

  void _stopSpeaking() {
    _voiceService.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ConversationProvider>(
          builder: (context, conversationProvider, child) {
            return Text(
              conversationProvider.currentConversation?.title ??
                  'AI Tutor Chat',
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _messageController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ConversationProvider>(
              builder: (context, conversationProvider, child) {
                if (conversationProvider.currentMessages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: conversationProvider.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message =
                        conversationProvider.currentMessages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask your AI Tutor anything...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 16,
                  color: isUser ? Colors.white : AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  isUser ? 'You' : 'AI Tutor',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUser ? Colors.white70 : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUser ? Colors.white : AppTheme.mainText,
                  ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isSpeaking ? Icons.stop : Icons.volume_up,
                      size: 20,
                    ),
                    onPressed: _isSpeaking ? _stopSpeaking : () => _speakResponse(message.content),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      // Copy to clipboard
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : AppTheme.primaryGreen,
            ),
            onPressed: _isListening ? _voiceService.stop : _startListening,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your AI Tutor anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
