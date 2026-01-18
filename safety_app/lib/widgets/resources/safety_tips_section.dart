import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_dimensions.dart';

/// Expandable section displaying safety tips for users.
///
/// Contains actionable safety guidelines for personal safety
/// when meeting new people or in potentially dangerous situations.
class SafetyTipsSection extends StatelessWidget {
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const SafetyTipsSection({
    super.key,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  /// List of safety tips to display.
  static const List<String> _safetyTips = [
    'Trust your instincts - if something feels wrong, it probably is',
    'Share your location with trusted contacts when meeting someone new',
    'Always meet new people in public, well-lit places',
    'Keep your phone charged and accessible at all times',
    'Know your exits and stay aware of your surroundings',
    'Have a code word with friends for emergency situations',
    'Research the person before meeting using public records',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: AppColors.softPink, width: 1),
        boxShadow: AppColors.subtleShadow,
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
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
          'Tap to ${isExpanded ? 'hide' : 'show'} safety guidelines',
          style: AppTextStyles.caption,
        ),
        children: [
          Padding(
            padding: AppSpacing.cardPaddingAll,
            child: Column(
              children: _safetyTips.map(_buildSafetyTip).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single safety tip row with checkmark icon.
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
