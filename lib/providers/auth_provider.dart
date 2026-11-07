import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadUserProfile(session.user.id);
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = User.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String educationLevel,
    required String preferredLanguage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Create user profile
        await _supabase.from('users').insert({
          'id': authResponse.user!.id,
          'display_name': displayName,
          'email': email,
          'education_level': educationLevel,
          'preferred_language': preferredLanguage,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _loadUserProfile(authResponse.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        await _loadUserProfile(authResponse.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Reset password error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? educationLevel,
    String? preferredLanguage,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['display_name'] = displayName;
      if (educationLevel != null) updateData['education_level'] = educationLevel;
      if (preferredLanguage != null) updateData['preferred_language'] = preferredLanguage;

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', _currentUser!.id);

      await _loadUserProfile(_currentUser!.id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
