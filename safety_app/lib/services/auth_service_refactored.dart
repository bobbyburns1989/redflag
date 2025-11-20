import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/authentication_service.dart';
import 'auth/credits_service.dart';
import 'auth/user_service.dart';

/// Facade service that maintains backward compatibility
/// Delegates to specialized services: AuthenticationService, CreditsService, UserService
///
/// This refactored version provides the same API as the original auth_service.dart
/// but with better separation of concerns and testability.
class AuthService {
  final AuthenticationService _authService;
  final CreditsService _creditsService;
  final UserService _userService;

  AuthService({
    AuthenticationService? authService,
    CreditsService? creditsService,
    UserService? userService,
  })  : _authService = authService ?? AuthenticationService(),
        _creditsService = creditsService ?? CreditsService(),
        _userService = userService ?? UserService();

  // ===== Authentication Operations (delegate to AuthenticationService) =====

  /// Sign up with email/password
  Future<AuthResult> signUp(String email, String password) async {
    return await _authService.signUp(email, password);
  }

  /// Sign in with email/password
  Future<AuthResult> signIn(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  // ===== User Operations (delegate to UserService) =====

  /// Get current user
  User? get currentUser => _userService.currentUser;

  /// Get current user as Future (for async contexts)
  Future<User?> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  /// Check if authenticated
  bool get isAuthenticated => _userService.isAuthenticated;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _userService.authStateChanges;

  // ===== Credit Operations (delegate to CreditsService) =====

  /// Get user credits from database (with retry for race condition)
  Future<int> getUserCredits({int maxAttempts = 3}) async {
    return await _creditsService.getUserCredits(maxAttempts: maxAttempts);
  }

  /// Listen to credit changes in real-time
  Stream<int> watchCredits() {
    return _creditsService.watchCredits();
  }

  /// Add credits to user account
  /// Note: In production, this should only be called by RevenueCat webhook
  /// This method is for testing/mock purchases only
  Future<void> addCredits(int amount) async {
    await _creditsService.addCredits(amount);
  }

  /// Deduct one credit from user account (for search operations)
  /// Returns true if successful, false if insufficient credits
  Future<bool> deductCredit() async {
    return await _creditsService.deductCredit();
  }
}
