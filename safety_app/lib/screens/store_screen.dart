import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/custom_snackbar.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

// Mock package data for development/screenshots when RevenueCat not configured
class MockPackage {
  final String id;
  final String title;
  final String description;
  final String price;
  final int searchCount;

  MockPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.searchCount,
  });
}

class _StoreScreenState extends State<StoreScreen> {
  final _revenueCatService = RevenueCatService();
  final _authService = AuthService();

  Offerings? _offerings;
  int _currentCredits = 0;
  bool _isLoading = true;
  bool _isPurchasing = false;

  // Mock packages for preview when RevenueCat not configured
  final List<MockPackage> _mockPackages = [
    MockPackage(
      id: '3_searches',
      title: '3 Searches',
      description: 'Perfect for quick lookups',
      price: '\$1.99',
      searchCount: 3,
    ),
    MockPackage(
      id: '10_searches',
      title: '10 Searches',
      description: 'Best value - Most popular!',
      price: '\$4.99',
      searchCount: 10,
    ),
    MockPackage(
      id: '25_searches',
      title: '25 Searches',
      description: 'Maximum searches for power users',
      price: '\$9.99',
      searchCount: 25,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isPurchasing = true);

    final result = await _revenueCatService.purchasePackage(package);

    if (!mounted) return;

    if (result.success) {
      // Purchase successful! Now wait for webhook to add credits
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
        // Webhook took too long or failed
        setState(() => _isPurchasing = false);

        if (kDebugMode) {
          print('⚠️ [STORE] Webhook timeout after 78 seconds');
          print('⚠️ [STORE] Purchase successful but credits not added yet');
          print('⚠️ [STORE] User should restore purchases or wait');
        }

        if (mounted) {
          // Show dialog with options
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('I\'ll Wait'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _restorePurchases();
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
            ),
          );
        }
      }
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

  Future<void> _purchaseMockPackage(MockPackage mockPackage) async {
    // Show info that this is mock mode
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Credits'),
        content: Text(
          'Add ${mockPackage.searchCount} search credits to your account for ${mockPackage.price}?\n\n'
          'Note: This is a test purchase. Real payments require RevenueCat configuration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Purchase',
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

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
      await _authService.addCredits(mockPackage.searchCount);

      // Reload credits
      final newCredits = await _authService.getUserCredits();

      setState(() {
        _currentCredits = newCredits;
        _isPurchasing = false;
      });

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Successfully added ${mockPackage.searchCount} credits!',
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
                // Credits balance
                Container(
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
                        '$_currentCredits',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'searches remaining',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Packages
                Expanded(
                  child: AppConfig.USE_MOCK_PURCHASES
                      ? _buildMockPackagesList()
                      : (_offerings == null || _offerings!.current == null
                          ? _buildNoOfferingsMessage()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _offerings!.current!.availablePackages.length,
                              itemBuilder: (context, index) {
                                final package = _offerings!.current!.availablePackages[index];
                                return _buildPackageCard(package);
                              },
                            )),
                ),
              ],
            ),
    );
  }

  Widget _buildMockPackagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockPackages.length,
      itemBuilder: (context, index) {
        final mockPackage = _mockPackages[index];
        return _buildMockPackageCard(mockPackage);
      },
    );
  }

  Widget _buildMockPackageCard(MockPackage mockPackage) {
    final isBestValue = mockPackage.id == '10_searches';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isBestValue
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
          if (isBestValue)
            Positioned(
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
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            mockPackage.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mockPackage.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mockPackage.price,
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
                ),
                const SizedBox(height: 16),

                // Purchase button
                SizedBox(
                  width: double.infinity,
                  child: _isPurchasing
                      ? LoadingWidgets.centered()
                      : CustomButton(
                          text: 'Purchase',
                          onPressed: () => _purchaseMockPackage(mockPackage),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final product = package.storeProduct;
    final isBestValue = package.identifier == 'ten_searches';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isBestValue
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
          if (isBestValue)
            Positioned(
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
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            product.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.priceString,
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
                ),
                const SizedBox(height: 16),

                // Purchase button
                SizedBox(
                  width: double.infinity,
                  child: _isPurchasing
                      ? LoadingWidgets.centered()
                      : CustomButton(
                          text: 'Purchase',
                          onPressed: () => _purchasePackage(package),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOfferingsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'RevenueCat offerings could not be loaded.\nPlease check your configuration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
              ),
            ),
            if (AppConfig.DEBUG_PURCHASES) ...[
              const SizedBox(height: 16),
              Container(
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}

