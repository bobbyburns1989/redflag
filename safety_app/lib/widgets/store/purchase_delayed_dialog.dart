import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Dialog shown when purchase completes but webhook takes too long to add credits
///
/// This dialog appears after ~78 seconds of waiting for RevenueCat webhook
/// to process the purchase and add credits to the user's account.
///
/// Provides two options:
/// - Wait: User dismisses and waits for credits to appear
/// - Restore Now: Immediately triggers restore purchases flow
///
/// Used in: StoreScreen after successful purchase but webhook timeout
class PurchaseDelayedDialog extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onWait;

  const PurchaseDelayedDialog({
    super.key,
    required this.onRestore,
    required this.onWait,
  });

  /// Helper method to show the dialog
  ///
  /// Example usage:
  /// ```dart
  /// await PurchaseDelayedDialog.show(
  ///   context,
  ///   onRestore: () => _restorePurchases(),
  /// );
  /// ```
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRestore,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PurchaseDelayedDialog(
        onRestore: onRestore,
        onWait: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryPink),
          const SizedBox(width: 8),
          const Text('Purchase Completed'),
        ],
      ),
      content: const Text(
        'Your payment was successful! ✅\n\n'
        'Credits are still being processed by Apple. This usually takes just a few moments.\n\n'
        'What to do:\n'
        '• Wait 1 minute and tap "Restore Now" below\n'
        '• OR close the app and reopen - credits will appear\n'
        '• If credits don\'t appear within 5 minutes, use the "Restore Purchases" button in Settings',
      ),
      actions: [
        TextButton(
          onPressed: onWait,
          child: const Text('I\'ll Wait'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onRestore();
          },
          child: Text(
            'Restore Now',
            style: TextStyle(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
