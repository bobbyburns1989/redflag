import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Time-based greeting header for the search screen.
///
/// Displays a personalized greeting based on time of day:
/// - "Good morning" (before 12 PM)
/// - "Good afternoon" (12 PM - 5 PM)
/// - "Good evening" (after 5 PM)
///
/// Known limitations (acceptable for MVP):
/// - Greeting won't update if screen stays open across time boundaries
/// - No user name personalization (not available in current auth flow)
/// - English only (US-only app)
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  /// Returns time-appropriate greeting based on current hour.
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduced motion accessibility setting
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting!',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What would you like to search today?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
    );

    // Skip animation if reduced motion is enabled
    if (reduceMotion) return content;

    // Simple fade-in animation using TweenAnimationBuilder
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}
