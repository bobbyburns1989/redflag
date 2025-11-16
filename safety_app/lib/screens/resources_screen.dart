import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_dimensions.dart';
import '../widgets/custom_button.dart';

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

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not launch phone dialer'),
              backgroundColor: AppColors.deepPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.deepPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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
          // Emergency banner with pulsing animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.03),
                child: Container(
                  padding: AppSpacing.cardPaddingAll,
                  decoration: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    borderRadius: AppDimensions.borderRadiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(
                          alpha: 0.3 + (_pulseController.value * 0.2),
                        ),
                        blurRadius: 16 + (_pulseController.value * 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.white, size: 32)
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMERGENCY',
                              style: AppTextStyles.overline.copyWith(
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            AppSpacing.verticalSpaceXs,
                            Text(
                              'If you are in immediate danger, call 911',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          AppSpacing.verticalSpaceLg,

          // Emergency services
          _buildResourceCard(
                context: context,
                icon: Icons.local_police,
                title: 'Emergency Services',
                subtitle: 'Immediate danger or crime in progress',
                phoneNumber: '911',
                color: AppColors.deepPink,
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // National Domestic Violence Hotline
          _buildResourceCard(
                context: context,
                icon: Icons.support_agent,
                title: 'National Domestic Violence Hotline',
                subtitle: '24/7 confidential support for domestic violence',
                phoneNumber: '1-800-799-7233',
                color: AppColors.primaryPink,
                additionalInfo: 'Text START to 88788',
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // National Sexual Assault Hotline
          _buildResourceCard(
                context: context,
                icon: Icons.healing,
                title: 'National Sexual Assault Hotline (RAINN)',
                subtitle: '24/7 confidential crisis support',
                phoneNumber: '1-800-656-4673',
                color: AppColors.rose,
                additionalInfo: 'Free and confidential',
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // National Suicide Prevention Lifeline
          _buildResourceCard(
                context: context,
                icon: Icons.favorite,
                title: 'National Suicide Prevention Lifeline',
                subtitle: '24/7 crisis support and suicide prevention',
                phoneNumber: '988',
                color: AppColors.primaryPink,
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceMd,

          // Crisis Text Line
          _buildResourceCard(
                context: context,
                icon: Icons.message,
                title: 'Crisis Text Line',
                subtitle: 'Text-based crisis support',
                phoneNumber: null,
                color: AppColors.deepPink,
                additionalInfo: 'Text HOME to 741741',
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceLg,

          // Additional resources section - Expandable
          Container(
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: AppDimensions.borderRadiusLg,
                  border: Border.all(color: AppColors.softPink, width: 1),
                  boxShadow: AppColors.subtleShadow,
                ),
                child: ExpansionTile(
                  initiallyExpanded: _additionalResourcesExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _additionalResourcesExpanded = expanded;
                    });
                  },
                  leading: Icon(
                    Icons.info_outline,
                    color: AppColors.primaryPink,
                    size: 28,
                  ),
                  title: Text(
                    'Additional Resources',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primaryPink,
                    ),
                  ),
                  subtitle: Text(
                    'Tap to ${_additionalResourcesExpanded ? 'hide' : 'show'} more helplines',
                    style: AppTextStyles.caption,
                  ),
                  children: [
                    Padding(
                      padding: AppSpacing.cardPaddingAll,
                      child: Column(
                        children: [
                          _buildInfoItem(
                            'National Center for Missing & Exploited Children',
                            '1-800-843-5678',
                          ),
                          const Divider(height: 24),
                          _buildInfoItem(
                            'Childhelp National Child Abuse Hotline',
                            '1-800-422-4453',
                          ),
                          const Divider(height: 24),
                          _buildInfoItem(
                            'National Human Trafficking Hotline',
                            '1-888-373-7888 or text 233733',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 600.ms)
              .slideX(begin: -0.2, end: 0),
          AppSpacing.verticalSpaceLg,

          // Safety tips - Expandable
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: AppDimensions.borderRadiusLg,
              border: Border.all(color: AppColors.softPink, width: 1),
              boxShadow: AppColors.subtleShadow,
            ),
            child: ExpansionTile(
              initiallyExpanded: _safetyTipsExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _safetyTipsExpanded = expanded;
                });
              },
              leading: Icon(
                Icons.lightbulb_outline,
                color: AppColors.deepPink,
                size: 28,
              ),
              title: Text(
                'Safety Tips',
                style: AppTextStyles.h4.copyWith(color: AppColors.deepPink),
              ),
              subtitle: Text(
                'Tap to ${_safetyTipsExpanded ? 'hide' : 'show'} safety guidelines',
                style: AppTextStyles.caption,
              ),
              children: [
                Padding(
                  padding: AppSpacing.cardPaddingAll,
                  child: Column(
                    children: [
                      _buildSafetyTip(
                        'Trust your instincts - if something feels wrong, it probably is',
                      ),
                      _buildSafetyTip(
                        'Share your location with trusted contacts when meeting someone new',
                      ),
                      _buildSafetyTip(
                        'Always meet new people in public, well-lit places',
                      ),
                      _buildSafetyTip(
                        'Keep your phone charged and accessible at all times',
                      ),
                      _buildSafetyTip(
                        'Know your exits and stay aware of your surroundings',
                      ),
                      _buildSafetyTip(
                        'Have a code word with friends for emergency situations',
                      ),
                      _buildSafetyTip(
                        'Research the person before meeting using public records',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String? phoneNumber,
    required Color color,
    String? additionalInfo,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: AppColors.softPink, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4.copyWith(color: color)),
                    AppSpacing.verticalSpaceXs,
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (phoneNumber != null || additionalInfo != null) ...[
            AppSpacing.verticalSpaceSm,
            const Divider(),
            AppSpacing.verticalSpaceXs,
          ],
          if (phoneNumber != null) ...[
            Row(
              children: [
                Icon(Icons.phone, color: color, size: 20),
                AppSpacing.horizontalSpaceXs,
                Text(
                  phoneNumber,
                  style: AppTextStyles.h3.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceSm,
            CustomButton(
              text: 'Call Now',
              onPressed: () {
                HapticFeedback.mediumImpact();
                _makePhoneCall(phoneNumber, context);
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
              icon: Icons.phone_in_talk,
            ),
          ],
          if (additionalInfo != null) ...[
            AppSpacing.verticalSpaceXs,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: color, size: 16),
                  AppSpacing.horizontalSpaceXs,
                  Expanded(
                    child: Text(
                      additionalInfo,
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.verticalSpaceXs,
        Row(
          children: [
            Icon(Icons.phone, color: AppColors.primaryPink, size: 16),
            AppSpacing.horizontalSpaceXs,
            Expanded(
              child: Text(
                contact,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: AppColors.deepPink),
          AppSpacing.horizontalSpaceSm,
          Expanded(child: Text(tip, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
