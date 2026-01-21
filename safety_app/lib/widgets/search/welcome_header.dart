import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Condensed single-line greeting header for the search screen.
///
/// Displays a time-based greeting in a compact format:
/// - "Good morning! What would you like to search?"
/// - "Good afternoon! What would you like to search?"
/// - "Good evening! What would you like to search?"
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$_greeting! What would you like to search?',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
