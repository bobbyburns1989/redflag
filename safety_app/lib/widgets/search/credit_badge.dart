import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Credit balance badge shown in the AppBar
///
/// Displays the user's current credit count in a refined pill design.
/// Used in the search screen to show real-time credit updates.
class CreditBadge extends StatelessWidget {
  final int credits;

  const CreditBadge({
    super.key,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.toll, size: 16, color: AppColors.primaryPink),
          const SizedBox(width: 6),
          Text(
            '$credits',
            style: TextStyle(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
