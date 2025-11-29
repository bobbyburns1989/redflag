import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.changePassword(
      currentPassword: _currentController.text.trim(),
      newPassword: _newController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      CustomSnackbar.showSuccess(
        context,
        'Password changed successfully',
      );
      Navigator.pop(context);
    } else {
      CustomSnackbar.showError(
        context,
        result.error ?? 'Failed to change password',
      );
    }
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a new password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (value == _currentController.text.trim()) {
      return 'New password must be different';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keep your account secure',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your current password and a new password. Make it unique and hard to guess.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _currentController,
                label: 'Current Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newController,
                label: 'New Password',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmController,
                label: 'Confirm New Password',
                prefixIcon: Icons.verified_user_outlined,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your new password';
                  }
                  if (value != _newController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Updating...' : 'Update Password',
                onPressed: _isLoading ? null : _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
