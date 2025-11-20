import 'package:flutter/material.dart';
import '../models/purchase_package.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widgets.dart';

/// Reusable widget for displaying purchase packages in the store
/// Handles both RevenueCat packages and mock packages with a unified interface
class StorePackageCard extends StatelessWidget {
  final PurchasePackage package;
  final VoidCallback onPurchase;
  final bool isPurchasing;

  const StorePackageCard({
    super.key,
    required this.package,
    required this.onPurchase,
    this.isPurchasing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: package.isBestValue
            ? Border.all(color: AppColors.primaryPink, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Best Value badge
          if (package.isBestValue) _buildBestValueBadge(),

          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildPurchaseButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestValueBadge() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryPink, AppColors.deepPink],
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
          ),
        ),
        child: const Text(
          'BEST VALUE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryPink.withValues(alpha: 0.2),
                AppColors.softPink.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.search,
            color: AppColors.primaryPink,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                package.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                package.price,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      child: isPurchasing
          ? LoadingWidgets.centered()
          : CustomButton(
              text: 'Purchase',
              onPressed: onPurchase,
            ),
    );
  }
}
