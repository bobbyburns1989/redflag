import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_widgets.dart';

/// Login screen with Apple Sign-In as the ONLY option
///
/// Apple Sign-In is enforced to prevent credit abuse. Users cannot create
/// multiple email accounts to get free credits since Apple IDs require
/// phone verification or payment methods.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  bool _isAppleLoading = false;
  bool _isAppleAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkAppleAvailability();
  }

  /// Check if Apple Sign-In is available
  Future<void> _checkAppleAvailability() async {
    final available = await _authService.isAppleSignInAvailable();
    if (mounted) {
      setState(() => _isAppleAvailable = available);
    }
  }

  /// Handle Apple Sign-In
  Future<void> _handleAppleSignIn() async {
    if (!_isAppleAvailable) {
      CustomSnackbar.showError(
        context,
        'Apple Sign-In is not available on this device',
      );
      return;
    }

    setState(() => _isAppleLoading = true);

    final result = await _authService.signInWithApple();

    setState(() => _isAppleLoading = false);

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Don't show error for cancelled sign-in
      if (result.error != 'Sign in was cancelled') {
        CustomSnackbar.showError(context, result.error ?? 'Sign in failed');
      }
    }
  }

  /// DEV ONLY: Bypass Apple Sign-In for testing
  ///
  /// This button only appears in debug mode and uses email/password auth
  /// with test credentials (1@1.com / 111111).
  ///
  /// IMPORTANT: This will be automatically removed in production builds
  /// since it's wrapped in a !dart.vm.product check.
  Future<void> _handleDevBypass() async {
    setState(() => _isAppleLoading = true);

    final result = await _authService.signIn('1@1.com', '111111');

    setState(() => _isAppleLoading = false);

    if (!mounted) return;

    if (result.success) {
      CustomSnackbar.showSuccess(context, 'Dev login successful');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      CustomSnackbar.showError(
        context,
        'Dev login failed: ${result.error}\n\nMake sure test account exists in Supabase',
      );
    }
  }

  /// Build the dev bypass button (only visible in debug builds)
  Widget _buildDevBypassButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.warning, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'DEVELOPMENT MODE ONLY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Bypass button
          TextButton.icon(
            onPressed: _handleDevBypass,
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            label: const Text(
              'Test Login (1@1.com)',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.softPink.withValues(alpha: 0.3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(Icons.flag, size: 80, color: AppColors.primaryPink),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Log in to continue',
                    style: TextStyle(fontSize: 16, color: AppColors.mediumText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Apple Sign-In button (only option)
                  if (_isAppleLoading)
                    LoadingWidgets.centered()
                  else if (_isAppleAvailable)
                    SignInWithAppleButton(
                      onPressed: _handleAppleSignIn,
                      style: SignInWithAppleButtonStyle.black,
                      borderRadius: BorderRadius.circular(12),
                      height: 50,
                    ),
                  const SizedBox(height: 16),

                  // DEV ONLY: Bypass button for testing (only visible in debug mode)
                  if (!const bool.fromEnvironment('dart.vm.product'))
                    _buildDevBypassButton(),
                  const SizedBox(height: 24),

                  // Info text about Apple Sign-In
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightPink.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppColors.primaryPink,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sign in with Apple keeps your information private and secure.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: AppColors.mediumText),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
