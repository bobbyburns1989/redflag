import 'package:supabase_flutter/supabase_flutter.dart';

/// Service focused on user operations
/// Handles user information and profile management
class UserService {
  final SupabaseClient _supabase;

  UserService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current user as Future (for async contexts)
  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) {
      return null;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile data
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', currentUser!.id);

      return true;
    } catch (e) {
      return false;
    }
  }
}
