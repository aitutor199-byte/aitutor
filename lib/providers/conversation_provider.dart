import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String? _errorMessage;

  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      _conversations = (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load conversations error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('timestamp', ascending: true);

      _currentMessages = (response as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load messages error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Conversation?> createConversation({
    required String userId,
    required String title,
    String? subject,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.from('conversations').insert({
        'user_id': userId,
        'title': title,
        'subject': subject,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      final conversation = Conversation.fromJson(response);
      _currentConversation = conversation;
      _conversations.insert(0, conversation);
      return conversation;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Create conversation error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMessage({
    required String conversationId,
    required String userId,
    required String role,
    required String content,
  }) async {
    try {
      final response = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'user_id': userId,
        'role': role,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      }).select().single();

      final message = Message.fromJson(response);
      _currentMessages.add(message);

      // Update conversation timestamp
      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Add message error: $e');
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete messages first
      await _supabase
          .from('messages')
          .delete()
          .eq('conversation_id', conversationId);

      // Delete conversation
      await _supabase
          .from('conversations')
          .delete()
          .eq('id', conversationId);

      _conversations.removeWhere((c) => c.id == conversationId);
      if (_currentConversation?.id == conversationId) {
        _currentConversation = null;
        _currentMessages = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Delete conversation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentConversation(Conversation? conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
