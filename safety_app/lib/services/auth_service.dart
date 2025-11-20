import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'revenuecat_service.dart';
import 'apple_auth_service.dart';

/// Authentication service using Supabase Auth
class AuthService {
  final _supabase = Supabase.instance.client;
  final _appleAuthService = AppleAuthService();

  /// Sign up with email/password
  Future<AuthResult> signUp(String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 [AUTH] Starting signup for: $email');
        print(
          '🔐 [AUTH] Before signup - Current user: ${_supabase.auth.currentUser?.id}',
        );
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('🔐 [AUTH] Signup response received');
        print('🔐 [AUTH] Response user: ${response.user?.id}');
        print(
          '🔐 [AUTH] Current user immediately after: ${_supabase.auth.currentUser?.id}',
        );
      }

      if (response.user == null) {
        if (kDebugMode) {
          print('❌ [AUTH] Signup failed - no user in response');
        }
        return AuthResult.failed('Sign up failed. Please try again.');
      }

      // Wait for profile to be created by database trigger (prevents race condition)
      await _waitForProfile(response.user!.id);
      if (kDebugMode) {
        print(
          '🔐 [AUTH] After waitForProfile - Current user: ${_supabase.auth.currentUser?.id}',
        );
      }

      // Force refresh session to ensure auth state persists
      if (kDebugMode) {
        print('🔄 [AUTH] Attempting to refresh session...');
      }
      try {
        final sessionResponse = await _supabase.auth.refreshSession();
        if (kDebugMode) {
          print('✅ [AUTH] Session refreshed successfully');
          print(
            '🔐 [AUTH] Session user after refresh: ${sessionResponse.session?.user.id}',
          );
          print(
            '🔐 [AUTH] Current user after refresh: ${_supabase.auth.currentUser?.id}',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [AUTH] Session refresh failed: $e');
        }
        // Continue anyway - might still work
      }

      // Wait for auth state to propagate
      int attempts = 0;
      while (_supabase.auth.currentUser == null && attempts < 10) {
        if (kDebugMode) {
          print(
            '⏳ [AUTH] Waiting for auth state to propagate... attempt ${attempts + 1}/10',
          );
        }
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      }

      if (_supabase.auth.currentUser != null) {
        if (kDebugMode) {
          print(
            '✅ [AUTH] Auth state confirmed: ${_supabase.auth.currentUser!.id}',
          );
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [AUTH] Auth state still null after $attempts attempts');
        }
      }

      // Initialize RevenueCat with Supabase user ID
      await RevenueCatService().initialize(response.user!.id);
      if (kDebugMode) {
        print(
          '🔐 [AUTH] After RevenueCat init - Current user: ${_supabase.auth.currentUser?.id}',
        );
      }

      // Verify user is still authenticated before returning
      if (_supabase.auth.currentUser == null) {
        if (kDebugMode) {
          print('⚠️ [AUTH] WARNING: Auth state lost after signup process!');
        }
        return AuthResult.failed(
          'Authentication state lost. Please try logging in.',
        );
      }

      if (kDebugMode) {
        print(
          '✅ [AUTH] Signup complete - User authenticated: ${_supabase.auth.currentUser!.id}',
        );
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

  /// Wait for profile to be created by trigger (max 5 seconds)
  Future<void> _waitForProfile(String userId, {int maxAttempts = 10}) async {
    if (kDebugMode) {
      print('🔍 [AUTH] Waiting for profile to be created for user: $userId');
    }

    for (int i = 0; i < maxAttempts; i++) {
      if (kDebugMode) {
        print('🔍 [AUTH] Attempt ${i + 1}/$maxAttempts to find profile...');
      }

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
        } else {
          if (kDebugMode) {
            print('⏳ [AUTH] Profile not found yet, waiting 500ms...');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [AUTH] Error checking profile (attempt ${i + 1}): $e');
        }
      }

      // Wait 500ms before next attempt
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (kDebugMode) {
      print(
        '⚠️ [AUTH] Profile still doesn\'t exist after 5 seconds - continuing anyway',
      );
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

  /// Sign in with Apple
  ///
  /// Primary authentication method to prevent abuse.
  /// Apple IDs are difficult to create in bulk, making this
  /// more secure than email/password for free credit distribution.
  Future<AuthResult> signInWithApple() async {
    final result = await _appleAuthService.signInWithApple();

    if (result.success && result.user != null) {
      return AuthResult.success(result.user!);
    } else if (result.cancelled) {
      return AuthResult.failed('Sign in was cancelled');
    } else {
      return AuthResult.failed(result.error ?? 'Apple Sign-In failed');
    }
  }

  /// Check if Apple Sign-In is available on this device
  Future<bool> isAppleSignInAvailable() async {
    return await _appleAuthService.isAvailable();
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user credits from database (with retry for race condition)
  Future<int> getUserCredits({int maxAttempts = 3}) async {
    if (!isAuthenticated) {
      if (kDebugMode) {
        print('⚠️ [AUTH] getUserCredits: User not authenticated');
      }
      return 0;
    }

    if (kDebugMode) {
      print(
        '🔍 [AUTH] getUserCredits: Fetching credits for user ${currentUser!.id}',
      );
    }

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (kDebugMode) {
        print('🔍 [AUTH] getUserCredits: Attempt ${attempt + 1}/$maxAttempts');
      }

      try {
        final response = await _supabase
            .from('profiles')
            .select('credits')
            .eq('id', currentUser!.id)
            .single();

        final credits = response['credits'] as int;
        if (kDebugMode) {
          print('✅ [AUTH] getUserCredits: Found $credits credits');
        }
        return credits;
      } catch (e) {
        if (kDebugMode) {
          print('❌ [AUTH] getUserCredits: Error on attempt ${attempt + 1}: $e');
        }

        // If not last attempt, wait and retry
        if (attempt < maxAttempts - 1) {
          final delay = 300 * (attempt + 1);
          if (kDebugMode) {
            print('⏳ [AUTH] getUserCredits: Retrying in ${delay}ms...');
          }
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }
        // Last attempt failed, return 0
        if (kDebugMode) {
          print('⚠️ [AUTH] getUserCredits: All attempts failed, returning 0');
        }
        return 0;
      }
    }

    return 0;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Listen to credit changes in real-time
  Stream<int> watchCredits() {
    if (!isAuthenticated) {
      return Stream.value(0);
    }

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', currentUser!.id)
        .map((data) {
          if (data.isEmpty) return 0;
          return data.first['credits'] as int;
        });
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

  /// Get current user as Future (for async contexts)
  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }

  /// Add credits to user account
  /// Note: In production, this should only be called by RevenueCat webhook
  /// This method is for testing/mock purchases only
  Future<void> addCredits(int amount) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    if (kDebugMode) {
      print('💎 [AUTH] Adding $amount credits to user ${currentUser!.id}');
    }

    try {
      // Get current credits
      final currentCredits = await getUserCredits();
      final newCredits = currentCredits + amount;

      // Update credits in database
      await _supabase
          .from('profiles')
          .update({'credits': newCredits})
          .eq('id', currentUser!.id);

      if (kDebugMode) {
        print('✅ [AUTH] Credits updated: $currentCredits → $newCredits');
      }

      // Also record the transaction
      await _supabase.from('credit_transactions').insert({
        'user_id': currentUser!.id,
        'transaction_type': 'purchase',
        'credits': amount,
        // Note: 'amount' column may not exist in older schema versions
        // In production, amount is recorded via RevenueCat webhook
        'provider': 'mock',
        'provider_transaction_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
      });

      if (kDebugMode) {
        print('✅ [AUTH] Transaction recorded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AUTH] Error adding credits: $e');
      }
      rethrow;
    }
  }
}

/// Result object for authentication operations
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult.success(this.user) : success = true, error = null;

  AuthResult.failed(this.error) : success = false, user = null;
}
