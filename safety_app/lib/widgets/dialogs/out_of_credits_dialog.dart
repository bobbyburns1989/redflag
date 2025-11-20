import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable dialog shown when user has insufficient credits for a search.
///
/// Usage:
/// ```dart
/// showOutOfCreditsDialog(context, currentCredits);
/// ```
class OutOfCreditsDialog extends StatelessWidget {
  final int currentCredits;

  const OutOfCreditsDialog({
    super.key,
    required this.currentCredits,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.toll, color: AppColors.primaryPink),
          const SizedBox(width: 12),
          const Text(
            'Out of Credits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have $currentCredits credit${currentCredits == 1 ? '' : 's'} remaining.',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase more credits to continue searching.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.mediumText),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/store');
          },
          icon: const Icon(Icons.shopping_cart_outlined, size: 18),
          label: const Text('Get Credits'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper function to show the out of credits dialog.
///
/// Returns when the dialog is dismissed.
Future<void> showOutOfCreditsDialog(BuildContext context, int currentCredits) {
  return showDialog(
    context: context,
    builder: (context) => OutOfCreditsDialog(currentCredits: currentCredits),
  );
}
