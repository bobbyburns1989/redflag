import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_colors.dart';

/// Widget displayed when RevenueCat offerings cannot be loaded
///
/// Shows:
/// - Empty state icon and message
/// - Retry button to reload offerings
/// - Debug info banner (only in debug mode)
///
/// Used in: StoreScreen when offerings are null or empty
class NoOfferingsMessage extends StatelessWidget {
  final VoidCallback onRetry;
  final bool showDebugInfo;

  const NoOfferingsMessage({
    super.key,
    required this.onRetry,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'RevenueCat offerings could not be loaded.\nPlease check your configuration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Retry button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
              ),
            ),

            // Debug info (only shows when DEBUG_PURCHASES is true)
            if (showDebugInfo && AppConfig.DEBUG_PURCHASES) ...[
              const SizedBox(height: 16),
              _buildDebugInfoBanner(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Debug Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Set USE_MOCK_PURCHASES = true in AppConfig\n'
            'to test without RevenueCat configuration.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[900],
            ),
          ),
        ],
      ),
    );
  }
}
