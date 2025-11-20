import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/revenuecat_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_widgets.dart';
import 'settings/delete_account_screen.dart';
import 'settings/privacy_policy_screen.dart';
import 'settings/terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  String? _userEmail;
  int _credits = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      final credits = await _authService.getUserCredits();

      setState(() {
        _userEmail = user?.email;
        _credits = credits;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SETTINGS] Error loading user data: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryPink,
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Text('Restoring purchases...'),
            ),
          ],
        ),
      ),
    );

    try {
      // Call RevenueCat restore purchases
      final result = await RevenueCatService().restorePurchases();

      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result.success) {
        // Refresh credit balance from database
        await _loadUserData();

        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Purchases restored successfully!',
          );
        }
      } else {
        // Show error message
        if (mounted) {
          CustomSnackbar.showError(
            context,
            result.error ?? 'Failed to restore purchases',
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'An error occurred while restoring purchases',
        );
      }
      if (kDebugMode) {
        print('❌ [SETTINGS] Error restoring purchases: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.deepPink, AppColors.primaryPink],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? LoadingWidgets.centered()
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: AppColors.primaryPink,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Account Section
                  _buildSectionHeader('Account'),
                  _buildAccountSection(),
                  const SizedBox(height: 24),

                  // Credits Section
                  _buildSectionHeader('Credits & Purchases'),
                  _buildCreditsCard(),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Buy More Credits',
                    subtitle: 'Purchase search credits',
                    onTap: () => Navigator.pushNamed(context, '/store'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.restore,
                    title: 'Restore Purchases',
                    subtitle: 'Restore previous purchases',
                    onTap: _restorePurchases,
                  ),
                  _buildSettingsTile(
                    icon: Icons.history,
                    title: 'Transaction History',
                    subtitle: 'View purchase history',
                    onTap: () {
                      // TODO: Navigate to transaction history
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction history - Coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Legal & Support Section
                  _buildSectionHeader('Legal & Support'),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Pink Flag',
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      // TODO: Show about screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('About Pink Flag - Coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Danger Zone
                  _buildSectionHeader('Danger Zone'),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return CustomCard(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.softPink,
              child: Icon(
                Icons.person,
                color: AppColors.primaryPink,
              ),
            ),
            title: Text(
              _userEmail ?? 'Not signed in',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text('Account Email'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppColors.primaryPink),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change password - Coming soon'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.primaryPink),
            title: const Text('Sign Out'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPink.withValues(alpha: 0.1),
            AppColors.softPink.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.softPink,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.diamond,
                color: AppColors.primaryPink,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_credits',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  Text(
                    'searches remaining',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryPink),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Permanently delete your account and data',
          style: TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeleteAccountScreen(),
            ),
          );
        },
      ),
    );
  }
}
