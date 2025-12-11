import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/revenuecat_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_widgets.dart';
import 'settings/about_screen.dart';
import 'settings/change_password_screen.dart';
import 'settings/delete_account_screen.dart';
import 'settings/privacy_policy_screen.dart';
import 'settings/search_history_screen.dart';
import 'settings/terms_screen.dart';
import 'settings/transaction_history_screen.dart';

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
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
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
            CircularProgressIndicator(color: AppColors.primaryPink),
            const SizedBox(width: 20),
            const Expanded(child: Text('Restoring purchases...')),
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
              colors: [
                AppColors.deepPink,
                AppColors.primaryPink.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: AppColors.softPink.withValues(alpha: 0.04),
        child: _isLoading
            ? LoadingWidgets.centered()
            : RefreshIndicator(
                onRefresh: _loadUserData,
                color: AppColors.primaryPink,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                      subtitle: 'Purchase credits for searches',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TransactionHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // History Section
                    _buildSectionHeader('History'),
                    _buildSettingsTile(
                      icon: Icons.manage_search_outlined,
                      title: 'Search History',
                      subtitle: 'View and clear your searches',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchHistoryScreen(),
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
                      subtitle: 'Version, credits, and more',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 1.1,
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
              child: Icon(Icons.person, color: AppColors.primaryPink),
            ),
            title: Text(
              _userEmail ?? 'Not signed in',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              'Account email',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppColors.primaryPink),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
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
            AppColors.primaryPink.withValues(alpha: 0.18),
            AppColors.softPink.withValues(alpha: 0.32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.softPink.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diamond, color: AppColors.primaryPink, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_credits',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  Text(
                    'credits available',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pull to refresh to update balance',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
    bool comingSoon = false,
  }) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Icon(
          icon,
          color: comingSoon ? Colors.grey[500] : AppColors.primaryPink,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: comingSoon ? Colors.grey[700] : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle ?? (comingSoon ? 'Coming soon' : ''),
          style: TextStyle(
            fontSize: 13,
            color: comingSoon ? Colors.grey[600] : Colors.grey[700],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: comingSoon ? Colors.grey[500] : Colors.grey[700],
        ),
        splashColor: AppColors.primaryPink.withValues(alpha: 0.08),
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
          color: Colors.red.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          'Permanently delete your account and data',
          style: TextStyle(fontSize: 12, color: Colors.redAccent),
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
