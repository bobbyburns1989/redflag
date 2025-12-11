import 'package:flutter/material.dart';
import '../models/purchase_package.dart';
import '../services/purchase_handler.dart';
import '../services/revenuecat_service.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../widgets/store_package_card.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/custom_snackbar.dart';

/// Store screen for purchasing search credits
/// Refactored to use PurchaseHandler and StorePackageCard
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _revenueCatService = RevenueCatService();
  final _authService = AuthService();
  final _purchaseHandler = PurchaseHandler();

  List<PurchasePackage> _packages = [];
  int _currentCredits = 0;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load packages based on mode (mock or real)
    final packages = await _loadPackages();
    final credits = await _authService.getUserCredits();

    setState(() {
      _packages = packages;
      _currentCredits = credits;
      _isLoading = false;
    });
  }

  /// Load packages from RevenueCat or use mock data
  Future<List<PurchasePackage>> _loadPackages() async {
    if (AppConfig.USE_MOCK_PURCHASES) {
      return PurchasePackage.getMockPackages();
    }

    final offerings = await _revenueCatService.getOfferings();
    if (offerings?.current == null) {
      return [];
    }

    return offerings!.current!.availablePackages
        .map((pkg) => PurchasePackage.fromRevenueCat(pkg))
        .toList();
  }

  /// Handle package purchase with automatic credit refresh
  Future<void> _handlePurchase(PurchasePackage package) async {
    setState(() => _isPurchasing = true);

    // Show processing message for real purchases
    if (!package.isMock && mounted) {
      CustomSnackbar.showInfo(context, 'Processing purchase...');
    }

    final result = await _purchaseHandler.purchasePackage(package);

    setState(() => _isPurchasing = false);

    if (!mounted) return;

    // Handle result
    if (result.success) {
      if (result.newCredits != null) {
        setState(() => _currentCredits = result.newCredits!);
        CustomSnackbar.showSuccess(context, 'Credits added successfully!');
      } else {
        // Purchase succeeded but credits delayed
        CustomSnackbar.showInfo(
          context,
          'Purchase completed! Credits will appear shortly. '
          'If they don\'t appear, use "Restore" button.',
        );
      }
    } else if (result.cancelled) {
      CustomSnackbar.showInfo(context, 'Purchase cancelled');
    } else if (result.pending) {
      CustomSnackbar.showInfo(context, 'Purchase pending...');
    } else {
      CustomSnackbar.showError(
        context,
        result.error ?? 'Purchase failed',
      );
    }
  }

  /// Restore previous purchases
  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);

    final result = await _purchaseHandler.restorePurchases();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      if (result.newCredits != null) {
        setState(() => _currentCredits = result.newCredits!);
      }
      CustomSnackbar.showSuccess(context, 'Purchases restored!');
    } else {
      CustomSnackbar.showError(
        context,
        result.error ?? 'Failed to restore',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? LoadingWidgets.centered() : _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
          onPressed: _isLoading ? null : _handleRestore,
          icon: const Icon(Icons.restore, color: Colors.white),
          label: const Text(
            'Restore',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCreditsHeader(),
        Expanded(
          child: _packages.isEmpty
              ? _buildNoPackagesMessage()
              : _buildPackagesList(),
        ),
      ],
    );
  }

  Widget _buildCreditsHeader() {
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
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
            'credits available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        return StorePackageCard(
          package: package,
          onPurchase: () => _handlePurchase(package),
          isPurchasing: _isPurchasing,
        );
      },
    );
  }

  Widget _buildNoPackagesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          ],
        ),
      ),
    );
  }
}
