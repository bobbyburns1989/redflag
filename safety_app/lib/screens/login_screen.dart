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

  /// Handle Apple Sign-In with enhanced error handling
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
      // Enhanced error handling with context-specific messages
      String errorMessage = result.error ?? 'Sign in failed';
      String? actionLabel;
      VoidCallback? action;

      // Don't show error for cancelled sign-in
      if (errorMessage.contains('cancelled')) {
        return;
      }

      // Provide specific guidance based on error type
      if (errorMessage.toLowerCase().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
        actionLabel = 'Retry';
        action = _handleAppleSignIn;
      } else if (errorMessage.toLowerCase().contains('unavailable')) {
        errorMessage = 'Apple Sign-In requires iOS 13+. Please update your device.';
        actionLabel = 'Help';
        action = () {
          // Could launch help page or email support
        };
      } else {
        errorMessage = 'Sign in failed. Please try again or contact support.';
        actionLabel = 'Retry';
        action = _handleAppleSignIn;
      }

      CustomSnackbar.showError(
        context,
        errorMessage,
        actionLabel: actionLabel,
        onAction: action,
        duration: const Duration(seconds: 6),
      );
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

  /// Build a bullet point for the info box
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: AppColors.darkText),
      ),
    );
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
                  // Pink Flag Logo (branded)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPink,
                          AppColors.deepPink,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.flag,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

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

                  // Apple Sign-In button with inline loading
                  if (_isAppleAvailable)
                    SizedBox(
                      height: 50,
                      child: Stack(
                        children: [
                          // Apple Sign-In button
                          SignInWithAppleButton(
                            onPressed: _isAppleLoading
                                ? () {}
                                : () => _handleAppleSignIn(),
                            style: SignInWithAppleButtonStyle.black,
                            borderRadius: BorderRadius.circular(12),
                            height: 50,
                          ),
                          // Loading overlay (only shown when loading)
                          if (_isAppleLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  // Fallback UI for unsupported devices
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Apple Sign-In Unavailable',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Apple Sign-In requires iOS 13+ and an Apple ID.\n\n'
                                'Please update your device or contact support for assistance.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            // Launch support email
                            CustomSnackbar.showInfo(
                              context,
                              'Contact support at support@pinkflagapp.com',
                              duration: const Duration(seconds: 5),
                            );
                          },
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Contact Support'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // DEV ONLY: Bypass button for testing (only visible in debug mode)
                  if (!const bool.fromEnvironment('dart.vm.product'))
                    _buildDevBypassButton(),
                  const SizedBox(height: 24),

                  // Why Apple Sign-In? (Enhanced info box)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPink.withValues(alpha: 0.1),
                          AppColors.softPink.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryPink.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.security,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Why Apple Sign-In?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint(
                            '🔒 Maximum privacy - we never see your email'),
                        _buildBulletPoint(
                            '⚡ One-tap login - no passwords to remember'),
                        _buildBulletPoint('🛡️ Prevents abuse of free credits'),
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
