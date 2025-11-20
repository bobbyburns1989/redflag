import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../revenuecat_service.dart';

/// Result object for authentication operations
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult.success(this.user)
      : success = true,
        error = null;

  AuthResult.failed(this.error)
      : success = false,
        user = null;
}

/// Service focused on authentication operations only
/// Handles sign up, sign in, sign out, password reset
class AuthenticationService {
  final SupabaseClient _supabase;

  AuthenticationService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Sign up with email/password
  Future<AuthResult> signUp(String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 [AUTH] Starting signup for: $email');
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        if (kDebugMode) {
          print('❌ [AUTH] Signup failed - no user in response');
        }
        return AuthResult.failed('Sign up failed. Please try again.');
      }

      // Wait for profile to be created by database trigger
      await _waitForProfile(response.user!.id);

      // Force refresh session to ensure auth state persists
      await _refreshSession();

      // Wait for auth state to propagate
      await _waitForAuthState();

      // Initialize RevenueCat with Supabase user ID
      await RevenueCatService().initialize(response.user!.id);

      // Verify user is still authenticated
      if (_supabase.auth.currentUser == null) {
        if (kDebugMode) {
          print('⚠️ [AUTH] WARNING: Auth state lost after signup process!');
        }
        return AuthResult.failed(
          'Authentication state lost. Please try logging in.',
        );
      }

      if (kDebugMode) {
        print('✅ [AUTH] Signup complete - User: ${response.user!.id}');
      }

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ [AUTH] Auth exception during signup: ${e.message}');
      }
      return AuthResult.failed(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AUTH] Unexpected error during signup: $e');
      }
      return AuthResult.failed('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email/password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failed('Sign in failed. Please try again.');
      }

      // Initialize RevenueCat with Supabase user ID
      await RevenueCatService().initialize(response.user!.id);

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.failed(e.message);
    } catch (e) {
      return AuthResult.failed('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failed(e.message);
    } catch (e) {
      return AuthResult.failed('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ===== Private Helper Methods =====

  /// Wait for profile to be created by trigger (max 5 seconds)
  Future<void> _waitForProfile(String userId, {int maxAttempts = 10}) async {
    if (kDebugMode) {
      print('🔍 [AUTH] Waiting for profile to be created for user: $userId');
    }

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final profile = await _supabase
            .from('profiles')
            .select('id, credits')
            .eq('id', userId)
            .maybeSingle();

        if (profile != null) {
          if (kDebugMode) {
            print('✅ [AUTH] Profile found! Credits: ${profile['credits']}');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [AUTH] Error checking profile (attempt ${i + 1}): $e');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (kDebugMode) {
      print('⚠️ [AUTH] Profile not found after 5 seconds - continuing anyway');
    }
  }

  /// Refresh session to ensure auth state persists
  Future<void> _refreshSession() async {
    if (kDebugMode) {
      print('🔄 [AUTH] Refreshing session...');
    }

    try {
      await _supabase.auth.refreshSession();
      if (kDebugMode) {
        print('✅ [AUTH] Session refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AUTH] Session refresh failed: $e');
      }
      // Continue anyway - might still work
    }
  }

  /// Wait for auth state to propagate
  Future<void> _waitForAuthState({int maxAttempts = 10}) async {
    int attempts = 0;
    while (_supabase.auth.currentUser == null && attempts < maxAttempts) {
      if (kDebugMode) {
        print('⏳ [AUTH] Waiting for auth state... attempt ${attempts + 1}/$maxAttempts');
      }
      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
    }

    if (_supabase.auth.currentUser != null) {
      if (kDebugMode) {
        print('✅ [AUTH] Auth state confirmed');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ [AUTH] Auth state still null after $attempts attempts');
      }
    }
  }
}
