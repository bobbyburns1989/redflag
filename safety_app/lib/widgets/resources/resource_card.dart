import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';
import '../custom_button.dart';

/// A card displaying an emergency resource with optional phone number and info.
///
/// Used for hotlines like 911, domestic violence hotline, RAINN, etc.
/// Supports tap-to-call functionality via the [onCall] callback.
class ResourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? phoneNumber;
  final Color color;
  final String? additionalInfo;

  /// Callback when user taps "Call Now" button.
  /// Receives the phone number to dial.
  final void Function(String phoneNumber)? onCall;

  const ResourceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.phoneNumber,
    this.additionalInfo,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header row with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
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

          // Divider if there's phone or additional info
          if (phoneNumber != null || additionalInfo != null) ...[
            AppSpacing.verticalSpaceSm,
            const Divider(),
            AppSpacing.verticalSpaceXs,
          ],

          // Phone number and call button
          if (phoneNumber != null) ...[
            Row(
              children: [
                Icon(Icons.phone, color: color, size: 20),
                AppSpacing.horizontalSpaceXs,
                Text(
                  phoneNumber!,
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
                onCall?.call(phoneNumber!);
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
              icon: Icons.phone_in_talk,
            ),
          ],

          // Additional info badge
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
                      additionalInfo!,
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
}
