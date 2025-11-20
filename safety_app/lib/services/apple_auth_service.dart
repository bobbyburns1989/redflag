import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'revenuecat_service.dart';

/// Service for handling Apple Sign-In with Supabase
///
/// This service generates secure nonces, handles the Apple credential flow,
/// and exchanges Apple tokens with Supabase for authentication.
///
/// Apple Sign-In is used as the primary auth method to prevent abuse
/// since Apple IDs are hard to create in bulk (require phone/payment method).
class AppleAuthService {
  final _supabase = Supabase.instance.client;

  /// Check if Apple Sign-In is available on this device
  ///
  /// Returns true on iOS 13+ and macOS 10.15+
  /// Always returns false on Android/Windows/Linux
  Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }

  /// Sign in with Apple
  ///
  /// Flow:
  /// 1. Generate secure nonce for replay attack prevention
  /// 2. Request Apple credentials via system dialog
  /// 3. Exchange Apple ID token with Supabase
  /// 4. Initialize RevenueCat with user ID
  /// 5. Return authenticated user
  ///
  /// Returns [AppleAuthResult] with success/failure status
  Future<AppleAuthResult> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('🍎 [APPLE] Starting Apple Sign-In flow');
      }

      // 1. Generate a secure random nonce
      // This prevents replay attacks by ensuring each auth request is unique
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      if (kDebugMode) {
        print('🍎 [APPLE] Generated nonce for security');
      }

      // 2. Request Apple credential
      // This shows the native Apple Sign-In dialog
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      if (kDebugMode) {
        print('🍎 [APPLE] Received Apple credential');
        print('🍎 [APPLE] User identifier: ${appleCredential.userIdentifier}');
        // Note: email and name may be null on subsequent sign-ins
        // Apple only provides them on first authorization
      }

      // 3. Get the identity token from Apple
      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        if (kDebugMode) {
          print('❌ [APPLE] No identity token received from Apple');
        }
        return AppleAuthResult.failed('No identity token received from Apple');
      }

      // 4. Exchange Apple token with Supabase
      // Supabase validates the token with Apple and creates/retrieves user
      if (kDebugMode) {
        print('🍎 [APPLE] Exchanging token with Supabase');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce, // Use raw nonce here, not hashed
      );

      if (response.user == null) {
        if (kDebugMode) {
          print('❌ [APPLE] Supabase returned no user');
        }
        return AppleAuthResult.failed('Sign in failed. Please try again.');
      }

      if (kDebugMode) {
        print('✅ [APPLE] Supabase auth successful');
        print('🍎 [APPLE] User ID: ${response.user!.id}');
        print('🍎 [APPLE] Email: ${response.user!.email}');
      }

      // 5. Wait for profile to be created by database trigger
      // This handles the race condition where Supabase returns before
      // the trigger creates the profile
      await _waitForProfile(response.user!.id);

      // 6. Initialize RevenueCat with the Supabase user ID
      // This links purchases to the authenticated user
      await RevenueCatService().initialize(response.user!.id);

      if (kDebugMode) {
        print('✅ [APPLE] Apple Sign-In complete');
      }

      return AppleAuthResult.success(response.user!);
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle specific Apple Sign-In errors
      if (kDebugMode) {
        print('❌ [APPLE] Authorization exception: ${e.code} - ${e.message}');
      }

      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return AppleAuthResult.cancelled();
        case AuthorizationErrorCode.failed:
          return AppleAuthResult.failed('Apple Sign-In failed. Please try again.');
        case AuthorizationErrorCode.invalidResponse:
          return AppleAuthResult.failed('Invalid response from Apple. Please try again.');
        case AuthorizationErrorCode.notHandled:
          return AppleAuthResult.failed('Request not handled. Please try again.');
        case AuthorizationErrorCode.notInteractive:
          return AppleAuthResult.failed('Interactive sign-in required.');
        default:
          return AppleAuthResult.failed('Apple Sign-In failed: ${e.message}');
      }
    } on AuthException catch (e) {
      // Handle Supabase auth errors
      if (kDebugMode) {
        print('❌ [APPLE] Supabase auth exception: ${e.message}');
      }
      return AppleAuthResult.failed(e.message);
    } catch (e) {
      // Handle unexpected errors
      if (kDebugMode) {
        print('❌ [APPLE] Unexpected error: $e');
      }
      return AppleAuthResult.failed('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Wait for profile to be created by database trigger
  ///
  /// When a user signs up, Supabase creates the auth user immediately,
  /// but our database trigger creates the profile asynchronously.
  /// This method polls until the profile exists (max 5 seconds).
  Future<void> _waitForProfile(String userId, {int maxAttempts = 10}) async {
    if (kDebugMode) {
      print('🔍 [APPLE] Waiting for profile creation for user: $userId');
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
            print('✅ [APPLE] Profile found! Credits: ${profile['credits']}');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [APPLE] Error checking profile (attempt ${i + 1}): $e');
        }
      }

      // Wait 500ms before next attempt
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (kDebugMode) {
      print('⚠️ [APPLE] Profile not found after ${maxAttempts * 500}ms - continuing anyway');
    }
  }

  /// Generate a cryptographically secure random nonce
  ///
  /// Used to prevent replay attacks. The raw nonce is sent to Supabase,
  /// while the hashed version is sent to Apple.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Hash a string using SHA256
  ///
  /// Apple requires the nonce to be hashed before sending.
  /// This creates a one-way hash that Apple can verify.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Result object for Apple authentication operations
///
/// Contains success/failure status, user object, and error message.
/// Also tracks if the user cancelled the operation (not an error).
class AppleAuthResult {
  final bool success;
  final bool cancelled;
  final User? user;
  final String? error;

  AppleAuthResult.success(this.user)
      : success = true,
        cancelled = false,
        error = null;

  AppleAuthResult.failed(this.error)
      : success = false,
        cancelled = false,
        user = null;

  AppleAuthResult.cancelled()
      : success = false,
        cancelled = true,
        user = null,
        error = 'Sign in was cancelled';
}
