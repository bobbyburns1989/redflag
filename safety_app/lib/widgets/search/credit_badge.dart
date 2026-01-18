import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Credit balance badge shown in the AppBar.
///
/// Displays the user's current credit count in a refined pill design.
/// Used in the search screen to show real-time credit updates.
///
/// Use [CreditBadge.onDark] for dark/gradient backgrounds (e.g., gradient AppBar).
class CreditBadge extends StatelessWidget {
  final int credits;
  final bool onDarkBackground;

  const CreditBadge({
    super.key,
    required this.credits,
    this.onDarkBackground = false,
  });

  /// Named constructor for use on dark/gradient backgrounds.
  /// Provides better contrast with semi-transparent white styling.
  const CreditBadge.onDark({
    super.key,
    required this.credits,
  }) : onDarkBackground = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: onDarkBackground
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.lightPink,
        borderRadius: BorderRadius.circular(20),
        border: onDarkBackground
            ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.toll,
            size: 16,
            color: onDarkBackground ? Colors.white : AppColors.primaryPink,
          ),
          const SizedBox(width: 6),
          Text(
            '$credits',
            style: TextStyle(
              color: onDarkBackground ? Colors.white : AppColors.primaryPink,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
