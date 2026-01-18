import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/resources/emergency_banner.dart';
import '../widgets/resources/resource_card.dart';
import '../widgets/resources/additional_resources_section.dart';
import '../widgets/resources/safety_tips_section.dart';

/// Screen displaying emergency resources, hotlines, and safety tips.
///
/// Features:
/// - Pulsing 911 emergency banner
/// - Hotline cards with tap-to-call functionality
/// - Expandable additional resources section
/// - Expandable safety tips section
class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _safetyTipsExpanded = false;
  bool _additionalResourcesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Pulsing animation for 911 banner
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Launches the phone dialer with the given number.
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showError('Could not launch phone dialer');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  /// Shows an error snackbar with the given message.
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.deepPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'resources_title',
          child: Material(
            color: Colors.transparent,
            child: const Text('Emergency Resources'),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: AppSpacing.screenPaddingAll,
        children: [
          // Emergency 911 banner with pulsing animation
          EmergencyBanner(pulseController: _pulseController),
          AppSpacing.verticalSpaceLg,

          // Emergency Services (911)
          ResourceCard(
            icon: Icons.local_police,
            title: 'Emergency Services',
            subtitle: 'Immediate danger or crime in progress',
            phoneNumber: '911',
            color: AppColors.deepPink,
            onCall: _makePhoneCall,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // National Domestic Violence Hotline
          ResourceCard(
            icon: Icons.support_agent,
            title: 'National Domestic Violence Hotline',
            subtitle: '24/7 confidential support for domestic violence',
            phoneNumber: '1-800-799-7233',
            color: AppColors.primaryPink,
            additionalInfo: 'Text START to 88788',
            onCall: _makePhoneCall,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // National Sexual Assault Hotline (RAINN)
          ResourceCard(
            icon: Icons.healing,
            title: 'National Sexual Assault Hotline (RAINN)',
            subtitle: '24/7 confidential crisis support',
            phoneNumber: '1-800-656-4673',
            color: AppColors.rose,
            additionalInfo: 'Free and confidential',
            onCall: _makePhoneCall,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // National Suicide Prevention Lifeline
          ResourceCard(
            icon: Icons.favorite,
            title: 'National Suicide Prevention Lifeline',
            subtitle: '24/7 crisis support and suicide prevention',
            phoneNumber: '988',
            color: AppColors.primaryPink,
            onCall: _makePhoneCall,
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // Crisis Text Line (no phone number, text only)
          ResourceCard(
            icon: Icons.message,
            title: 'Crisis Text Line',
            subtitle: 'Text-based crisis support',
            phoneNumber: null,
            color: AppColors.deepPink,
            additionalInfo: 'Text HOME to 741741',
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceLg,

          // Additional Resources (expandable)
          AdditionalResourcesSection(
            isExpanded: _additionalResourcesExpanded,
            onExpansionChanged: (expanded) {
              setState(() => _additionalResourcesExpanded = expanded);
            },
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceLg,

          // Safety Tips (expandable)
          SafetyTipsSection(
            isExpanded: _safetyTipsExpanded,
            onExpansionChanged: (expanded) {
              setState(() => _safetyTipsExpanded = expanded);
            },
          ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }
}
