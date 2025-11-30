import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling account deletion
///
/// This service manages the complete deletion of a user's account
/// including all associated data across multiple tables.
/// Required for GDPR compliance and Apple App Store requirements.
class AccountDeletionService {
  /// Delete user account using Edge Function (server-side)
  ///
  /// Supports both email/password and Apple Sign-In users.
  /// For Apple users, re-authentication with Apple is required.
  /// For email users, password verification is required.
  ///
  /// The server-side Edge Function handles:
  /// 1. JWT token validation
  /// 2. Deletion of searches
  /// 3. Deletion of credit_transactions
  /// 4. Deletion of user record
  /// 5. Deletion of auth.users record (with admin privileges)
  Future<DeletionResult> deleteAccount({
    String? password,
    AuthorizationCredentialAppleID? appleCredential,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return DeletionResult.failed('User not found');
      }

      if (kDebugMode) {
        print('🔒 [DELETE] Starting account deletion for user: ${user.id}');
      }

      // Determine authentication method
      final isAppleUser = user.appMetadata['provider'] == 'apple';

      // Step 1: Re-authenticate user before deletion
      if (isAppleUser) {
        // Apple Sign-In re-authentication
        if (appleCredential == null) {
          return DeletionResult.failed(
            'Apple re-authentication required',
            needsAppleAuth: true,
          );
        }

        if (kDebugMode) {
          print('🍎 [DELETE] Re-authenticating with Apple');
        }

        try {
          // Re-authenticate with Apple
          await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.apple,
            idToken: appleCredential.identityToken!,
            accessToken: appleCredential.authorizationCode,
          );

          if (kDebugMode) {
            print('✅ [DELETE] Apple re-authentication successful');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ [DELETE] Apple re-authentication failed: $e');
          }
          return DeletionResult.failed('Apple authentication failed');
        }
      } else {
        // Email/password re-authentication
        if (password == null || password.isEmpty) {
          return DeletionResult.failed('Password required');
        }

        if (kDebugMode) {
          print('🔒 [DELETE] Verifying password');
        }

        if (user.email == null) {
          return DeletionResult.failed('Email not found');
        }

        try {
          await supabase.auth.signInWithPassword(
            email: user.email!,
            password: password,
          );

          if (kDebugMode) {
            print('✅ [DELETE] Password verified');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ [DELETE] Password verification failed: $e');
          }
          return DeletionResult.failed('Incorrect password');
        }
      }

      // Step 2: Call server-side Edge Function to delete account
      if (kDebugMode) {
        print('🗑️ [DELETE] Calling delete-account Edge Function');
      }

      final session = supabase.auth.currentSession;
      if (session == null) {
        return DeletionResult.failed('No active session');
      }

      final response = await supabase.functions.invoke(
        'delete-account',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (kDebugMode) {
        print('📥 [DELETE] Edge Function response: ${response.data}');
      }

      // Check response
      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          if (kDebugMode) {
            print('✅ [DELETE] Account deletion complete');
          }
          return DeletionResult.success();
        } else {
          final error = data['error'] ?? 'Unknown error';
          if (kDebugMode) {
            print('❌ [DELETE] Edge Function returned error: $error');
          }
          return DeletionResult.failed(error);
        }
      } else {
        final error = response.data?['error'] ?? 'Server error';
        if (kDebugMode) {
          print('❌ [DELETE] Edge Function failed with status ${response.status}: $error');
        }
        return DeletionResult.failed(error);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DELETE] Error deleting account: $e');
      }
      return DeletionResult.failed('Failed to delete account: ${e.toString()}');
    }
  }

  /// Sign out the user after account deletion
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      if (kDebugMode) {
        print('✅ [DELETE] User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DELETE] Error signing out: $e');
      }
      // Continue anyway since account is deleted
    }
  }
}

/// Result of account deletion operation
class DeletionResult {
  final bool success;
  final String? error;
  final bool needsAppleAuth;

  DeletionResult.success()
      : success = true,
        error = null,
        needsAppleAuth = false;

  DeletionResult.failed(this.error, {this.needsAppleAuth = false})
      : success = false;
}
