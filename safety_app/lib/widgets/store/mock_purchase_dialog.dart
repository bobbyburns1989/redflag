import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Dialog for confirming mock (test) purchase in development mode
///
/// Shows when USE_MOCK_PURCHASES is true in AppConfig.
/// Allows testing purchase flow without RevenueCat configuration.
///
/// Features:
/// - Shows price and credit count
/// - Warning that this is a test purchase
/// - Confirm/Cancel actions
///
/// Used in: StoreScreen mock purchase flow
class MockPurchaseDialog extends StatelessWidget {
  final String price;
  final int creditCount;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const MockPurchaseDialog({
    super.key,
    required this.price,
    required this.creditCount,
    required this.onConfirm,
    required this.onCancel,
  });

  /// Helper method to show dialog and get result
  ///
  /// Returns true if user confirmed, false if cancelled
  ///
  /// Example usage:
  /// ```dart
  /// final confirmed = await MockPurchaseDialog.show(
  ///   context,
  ///   price: '\$1.99',
  ///   creditCount: 30,
  /// );
  /// if (confirmed) {
  ///   // Process purchase
  /// }
  /// ```
  static Future<bool> show(
    BuildContext context, {
    required String price,
    required int creditCount,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MockPurchaseDialog(
        price: price,
        creditCount: creditCount,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Purchase Credits'),
      content: Text(
        'Add $creditCount credits to your account for $price?\n\n'
        'Note: This is a test purchase. Real payments require RevenueCat configuration.',
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            'Purchase',
            style: TextStyle(color: AppColors.primaryPink),
          ),
        ),
      ],
    );
  }
}
