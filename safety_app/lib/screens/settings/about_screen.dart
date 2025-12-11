import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _version = '1.1.8';
        _buildNumber = '14';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Pink Flag'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softPink.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo & Name Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.palePink,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Pink Flag Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.softPink.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      size: 50,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pink Flag',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay Safe, Stay Aware',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.mediumText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Version $_version (Build $_buildNumber)',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Description Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Pink Flag',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pink Flag is a women\'s safety app that provides anonymous access to public sex offender registry information. We empower you with awareness while emphasizing ethical use and personal safety.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.mediumText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Key Features
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.person_search,
                    title: 'Name Search',
                    description:
                        'Search public registries by name with optional filters',
                  ),
                  _buildFeatureItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone Lookup',
                    description:
                        'Reverse phone number lookup with caller information',
                  ),
                  _buildFeatureItem(
                    icon: Icons.image_search,
                    title: 'Image Search',
                    description: 'Reverse image search to detect fake profiles',
                  ),
                  _buildFeatureItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy First',
                    description:
                        'Anonymous searches with Apple Sign-In security',
                  ),
                  _buildFeatureItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Ethical Design',
                    description:
                        'Clear disclaimers and guidance on proper use',
                  ),
                  _buildFeatureItem(
                    icon: Icons.emergency_outlined,
                    title: 'Emergency Resources',
                    description: 'Quick access to crisis hotlines and support',
                  ),
                  const SizedBox(height: 32),

                  // Mission Statement
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.palePink,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.softPink,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_outline,
                              color: AppColors.primaryPink,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Our Mission',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'To empower women with access to public safety information while promoting responsible use and preventing misuse. We believe awareness is a tool for personal safety, not harassment.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.mediumText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Important Notice
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Important Notice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This app provides access to PUBLIC RECORDS ONLY. Data may be incomplete, outdated, or contain errors. Always verify independently through official channels. Use for awareness, not harassment.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Contact & Support
                  Text(
                    'Contact & Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLinkItem(
                    icon: Icons.language,
                    title: 'Website',
                    subtitle: 'www.customapps.us',
                    onTap: () => _launchUrl('https://www.customapps.us/pinkflag'),
                  ),
                  _buildLinkItem(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@customapps.us',
                    onTap: () => _launchUrl('mailto:support@customapps.us'),
                  ),
                  _buildLinkItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    onTap: () => _launchUrl(
                        'https://www.customapps.us/pinkflag/privacy'),
                  ),
                  _buildLinkItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    onTap: () =>
                        _launchUrl('https://www.customapps.us/pinkflag/terms'),
                  ),
                  const SizedBox(height: 32),

                  // Credits & Acknowledgments
                  Text(
                    'Credits & Acknowledgments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCreditItem(
                    'Data Sources',
                    'Offenders.io • TinEye • Twilio Lookup',
                  ),
                  _buildCreditItem(
                    'Framework',
                    'Built with Flutter & FastAPI',
                  ),
                  _buildCreditItem(
                    'Design',
                    'Material Design 3',
                  ),
                  _buildCreditItem(
                    'Icons',
                    'Material Icons by Google',
                  ),
                  _buildCreditItem(
                    'Emergency Resources',
                    'National crisis organizations',
                  ),
                  const SizedBox(height: 32),

                  // License
                  Text(
                    'License',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Copyright © 2025 Pink Flag App',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This application is licensed under the MIT License. This software is provided "as is" without warranty of any kind.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.mediumText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Made with ❤️ for personal safety',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'and community awareness',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryPink,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mediumText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.softPink.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryPink,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: AppColors.mediumText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
