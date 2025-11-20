import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_widgets.dart';

/// Sign up screen with Apple Sign-In as the only option
///
/// Apple Sign-In is used to prevent abuse where users create
/// multiple email accounts to get free searches. Apple IDs are
/// much harder to create in bulk since they require phone
/// verification or payment methods.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isAppleAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkAppleAvailability();
  }

  /// Check if Apple Sign-In is available on this device
  /// Should always be true on iOS 13+
  Future<void> _checkAppleAvailability() async {
    final available = await _authService.isAppleSignInAvailable();
    if (mounted) {
      setState(() => _isAppleAvailable = available);
    }
  }

  /// Handle Apple Sign-In button press
  Future<void> _handleAppleSignIn() async {
    if (!_isAppleAvailable) {
      CustomSnackbar.showError(
        context,
        'Apple Sign-In is not available on this device',
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.signInWithApple();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      CustomSnackbar.showSuccess(
        context,
        'Account created! You received 1 free search.',
      );
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Don't show error for cancelled sign-in
      if (result.error != 'Sign in was cancelled') {
        CustomSnackbar.showError(context, result.error ?? 'Sign up failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.softPink.withValues(alpha: 0.3),
              Colors.white,
            ],
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
                  Icon(
                    Icons.flag,
                    size: 80,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Create Account',
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
                    'Get 1 free search to start',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Apple Sign-In button or loading indicator
                  if (_isLoading)
                    LoadingWidgets.centered()
                  else
                    _buildAppleSignInButton(),
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
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login link for existing users
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Log In',
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

  /// Build the Apple Sign-In button
  ///
  /// Uses the official SignInWithAppleButton widget which follows
  /// Apple's Human Interface Guidelines for the button appearance.
  Widget _buildAppleSignInButton() {
    if (!_isAppleAvailable) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Apple Sign-In is not available on this device',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SignInWithAppleButton(
      onPressed: _handleAppleSignIn,
      style: SignInWithAppleButtonStyle.black,
      borderRadius: BorderRadius.circular(12),
      height: 50,
    );
  }
}
