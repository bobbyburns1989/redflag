import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../models/purchase_package.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/store/credits_balance_header.dart';
import '../widgets/store/store_package_card.dart';
import '../widgets/store/purchase_delayed_dialog.dart';
import '../widgets/store/mock_purchase_dialog.dart';
import '../widgets/store/no_offerings_message.dart';

/// Store screen for purchasing credits via RevenueCat or mock purchases
///
/// Features:
/// - Credits balance display
/// - Package cards (30, 100, 250 credits)
/// - Mock purchases (when USE_MOCK_PURCHASES = true)
/// - Real purchases via RevenueCat (when USE_MOCK_PURCHASES = false)
/// - Webhook polling for credit fulfillment
/// - Restore purchases button
///
/// Refactored: January 2026
/// - Extracted 5 widgets (credits header, package card, 2 dialogs, empty state)
/// - Reduced from 768 lines to ~350 lines (54% reduction)
/// - Eliminated 256 lines of code duplication
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _revenueCatService = RevenueCatService();
  final _authService = AuthService();

  Offerings? _offerings;
  int _currentCredits = 0;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load offerings and current credit balance
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load offerings only if using real RevenueCat purchases
    Offerings? offerings;
    if (!AppConfig.USE_MOCK_PURCHASES) {
      offerings = await _revenueCatService.getOfferings();
      if (kDebugMode && AppConfig.DEBUG_PURCHASES) {
        print('🛒 [STORE] RevenueCat offerings loaded: ${offerings?.current?.identifier}');
      }
    } else {
      if (kDebugMode && AppConfig.DEBUG_PURCHASES) {
        print('🛒 [STORE] Using mock purchases mode - skipping RevenueCat offerings');
      }
    }

    final credits = await _authService.getUserCredits();

    setState(() {
      _offerings = offerings;
      _currentCredits = credits;
      _isLoading = false;
    });
  }

  /// Handle RevenueCat package purchase
  ///
  /// Flow:
  /// 1. Purchase via RevenueCat
  /// 2. Poll for webhook to add credits (12 attempts, ~78 seconds)
  /// 3. Show success or delayed dialog
  Future<void> _purchasePackage(Package package) async {
    setState(() => _isPurchasing = true);

    final result = await _revenueCatService.purchasePackage(package);

    if (!mounted) return;

    if (result.success) {
      await _handleSuccessfulPurchase();
    } else if (result.cancelled) {
      setState(() => _isPurchasing = false);
      if (mounted) {
        CustomSnackbar.showInfo(context, 'Purchase cancelled');
      }
    } else if (result.pending) {
      setState(() => _isPurchasing = false);
      if (mounted) {
        CustomSnackbar.showInfo(context, 'Purchase pending...');
      }
    } else {
      setState(() => _isPurchasing = false);
      if (mounted) {
        CustomSnackbar.showError(context, result.error ?? 'Purchase failed');
      }
    }
  }

  /// Handle successful purchase - poll for webhook credits
  Future<void> _handleSuccessfulPurchase() async {
    if (mounted) {
      CustomSnackbar.showInfo(
        context,
        'Payment successful! Adding credits...',
      );
    }

    // Retry credit refresh with delays (webhook needs time to process)
    bool creditsAdded = false;
    final initialCredits = _currentCredits;

    // Extended timeout: 12 attempts = ~78 seconds total
    // Progressive delays: 2s, 3s, 4s, 5s, 6s, 7s, 8s, 9s, 10s, 11s, 12s, 13s
    for (int attempt = 0; attempt < 12; attempt++) {
      await Future.delayed(Duration(seconds: attempt + 2));

      if (!mounted) return;

      // Show progress feedback every 3rd attempt
      if (attempt > 0 && attempt % 3 == 0 && mounted) {
        CustomSnackbar.showInfo(
          context,
          'Still processing... (${attempt + 1}/12)',
        );
      }

      final newCredits = await _authService.getUserCredits();

      if (newCredits > initialCredits) {
        // Credits were added!
        final addedCredits = newCredits - initialCredits;
        setState(() {
          _currentCredits = newCredits;
          _isPurchasing = false;
        });
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Success! $addedCredits credits added! 🎉',
          );
        }
        creditsAdded = true;

        if (kDebugMode) {
          print('✅ [STORE] Credits added after ${attempt + 1} attempts');
          print('✅ [STORE] $initialCredits → $newCredits (+$addedCredits)');
        }
        break;
      }

      if (kDebugMode) {
        print('🔄 [STORE] Attempt ${attempt + 1}/12: Waiting for webhook...');
      }
    }

    if (!creditsAdded) {
      // Webhook took too long or failed - show delayed dialog
      setState(() => _isPurchasing = false);

      if (kDebugMode) {
        print('⚠️ [STORE] Webhook timeout after 78 seconds');
        print('⚠️ [STORE] Purchase successful but credits not added yet');
        print('⚠️ [STORE] User should restore purchases or wait');
      }

      if (mounted) {
        await PurchaseDelayedDialog.show(
          context,
          onRestore: _restorePurchases,
        );
      }
    }
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    final result = await _revenueCatService.restorePurchases();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      CustomSnackbar.showSuccess(context, 'Purchases restored!');
      final newCredits = await _authService.getUserCredits();
      setState(() => _currentCredits = newCredits);
    } else {
      CustomSnackbar.showError(context, result.error ?? 'Failed to restore');
    }
  }

  /// Handle mock package purchase (for development/testing)
  ///
  /// Flow:
  /// 1. Show confirmation dialog
  /// 2. Directly add credits to database (bypass RevenueCat)
  /// 3. Refresh credit balance
  Future<void> _purchaseMockPackage(PurchasePackage package) async {
    // Show confirmation dialog
    final confirmed = await MockPurchaseDialog.show(
      context,
      price: package.price,
      creditCount: package.searchCount,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isPurchasing = true);

    try {
      // Simulate purchase delay
      await Future.delayed(const Duration(seconds: 1));

      // Add credits to database
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      // Manually add credits via database (for testing)
      // In production, this would be handled by RevenueCat webhook
      await _authService.addCredits(package.searchCount);

      // Reload credits
      final newCredits = await _authService.getUserCredits();

      setState(() {
        _currentCredits = newCredits;
        _isPurchasing = false;
      });

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Successfully added ${package.searchCount} credits!',
        );
      }
    } catch (e) {
      setState(() => _isPurchasing = false);
      if (mounted) {
        CustomSnackbar.showError(context, 'Purchase failed: ${e.toString()}');
      }
      if (kDebugMode) {
        print('❌ [STORE] Mock purchase error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Credits'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.deepPink, AppColors.primaryPink],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _restorePurchases,
            icon: const Icon(Icons.restore, color: Colors.white),
            label: const Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? LoadingWidgets.centered()
          : Column(
              children: [
                // Credits balance header (REFACTORED: Extracted widget)
                CreditsBalanceHeader(currentCredits: _currentCredits),

                // Package list
                Expanded(child: _buildPackagesList()),
              ],
            ),
    );
  }

  /// Build packages list based on mock or real mode
  Widget _buildPackagesList() {
    if (AppConfig.USE_MOCK_PURCHASES) {
      // Mock packages for development/testing
      return _buildMockPackagesList();
    }

    if (_offerings == null || _offerings!.current == null) {
      // No offerings available - show empty state
      return NoOfferingsMessage(
        onRetry: _loadData,
        showDebugInfo: AppConfig.DEBUG_PURCHASES,
      );
    }

    // Real RevenueCat packages
    return _buildRevenueCatPackagesList();
  }

  /// Build list of mock packages
  Widget _buildMockPackagesList() {
    final mockPackages = PurchasePackage.getMockPackages();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockPackages.length,
      itemBuilder: (context, index) {
        final package = mockPackages[index];
        return StorePackageCard(
          package: package,
          onPurchase: () => _purchaseMockPackage(package),
          isPurchasing: _isPurchasing,
        );
      },
    );
  }

  /// Build list of RevenueCat packages
  Widget _buildRevenueCatPackagesList() {
    final packages = _offerings!.current!.availablePackages;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final rcPackage = packages[index];
        final package = PurchasePackage.fromRevenueCat(rcPackage);
        return StorePackageCard(
          package: package,
          onPurchase: () => _purchasePackage(rcPackage),
          isPurchasing: _isPurchasing,
        );
      },
    );
  }
}
