import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../main.dart';
import '../../services/account_deletion_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_text_field.dart';

/// Delete Account Screen
///
/// Multi-step confirmation flow for permanently deleting a user's account.
/// Required for GDPR compliance.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _accountDeletionService = AccountDeletionService();
  final _deleteConfirmController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isDeleting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canDelete {
    return _deleteConfirmController.text.trim().toUpperCase() == 'DELETE' &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _deleteAccount() async {
    if (!_canDelete) return;

    // Final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Final Confirmation',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This action is PERMANENT and CANNOT be undone.\n\nAll your data will be permanently deleted.\n\nAre you absolutely sure?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Yes, Delete Forever',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          CustomSnackbar.showError(context, 'User not found');
        }
        return;
      }

      // Delete account
      final result = await _accountDeletionService.deleteAccount(
        userId: user.id,
        password: _passwordController.text,
      );

      if (result.success) {
        // Sign out
        await _accountDeletionService.signOut();

        // Navigate to onboarding
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Account deleted successfully',
          );

          // Navigate to onboarding and clear stack
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() => _isDeleting = false);
          CustomSnackbar.showError(
            context,
            result.error ?? 'Failed to delete account',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        CustomSnackbar.showError(
          context,
          'An error occurred while deleting your account',
        );
      }
      if (kDebugMode) {
        print('❌ [DELETE_SCREEN] Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Warning: This action is permanent and cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // What will be deleted
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What will be deleted:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDeletedItem(
                      icon: Icons.person,
                      title: 'Your account',
                      subtitle: 'Login credentials and profile',
                    ),
                    _buildDeletedItem(
                      icon: Icons.search,
                      title: 'Search history',
                      subtitle: 'All past searches',
                    ),
                    _buildDeletedItem(
                      icon: Icons.receipt,
                      title: 'Transaction history',
                      subtitle: 'Purchase records and credits',
                    ),
                    _buildDeletedItem(
                      icon: Icons.settings,
                      title: 'App settings',
                      subtitle: 'All preferences and configurations',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirmation section
            CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To confirm, please:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type DELETE confirmation
                    const Text(
                      '1. Type DELETE in the box below:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _deleteConfirmController,
                      hint: 'Type DELETE',
                      onChanged: (value) => setState(() {}),
                      textCapitalization: TextCapitalization.characters,
                    ),

                    const SizedBox(height: 20),

                    // Enter password
                    const Text(
                      '2. Enter your password:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _passwordController,
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      onChanged: (value) => setState(() {}),
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Delete button
            CustomButton(
              text: _isDeleting ? 'Deleting...' : 'Delete My Account',
              onPressed: _canDelete && !_isDeleting ? _deleteAccount : null,
              customGradient: const LinearGradient(
                colors: [Colors.red, Color(0xFFD32F2F)],
              ),
              isLoading: _isDeleting,
            ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: _isDeleting ? null : () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Legal notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'By deleting your account, you acknowledge that:\n\n'
                '• All your data will be permanently deleted\n'
                '• This action cannot be undone or reversed\n'
                '• You will be immediately signed out\n'
                '• You will need to create a new account to use Pink Flag again',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.close,
            color: Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
