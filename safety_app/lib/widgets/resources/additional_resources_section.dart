import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';

/// Expandable section displaying additional emergency helplines.
///
/// Contains resources like Missing Children hotline, Child Abuse hotline,
/// and Human Trafficking hotline.
class AdditionalResourcesSection extends StatelessWidget {
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const AdditionalResourcesSection({
    super.key,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: AppColors.softPink, width: 1),
        boxShadow: AppColors.subtleShadow,
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
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
          'Tap to ${isExpanded ? 'hide' : 'show'} more helplines',
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
    );
  }

  /// Builds a single info item with title and contact info.
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
}
