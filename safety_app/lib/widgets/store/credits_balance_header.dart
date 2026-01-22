import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Widget displaying the user's current credit balance
///
/// Features:
/// - Large credit count display
/// - Gradient background for visual prominence
/// - Centered layout optimized for store screen
///
/// Used in:
/// - StoreScreen (purchase flow)
/// - Can be reused in Settings or other screens showing credit balance
class CreditsBalanceHeader extends StatelessWidget {
  final int currentCredits;

  const CreditsBalanceHeader({
    super.key,
    required this.currentCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.softPink.withValues(alpha: 0.3),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Credits',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentCredits',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'credits available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
