import 'package:purchases_flutter/purchases_flutter.dart';

/// Unified model for both RevenueCat packages and mock packages
class PurchasePackage {
  final String id;
  final String title;
  final String description;
  final String price;
  final int searchCount;
  final bool isBestValue;
  final Package? revenueCatPackage;
  final bool isMock;

  PurchasePackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.searchCount,
    this.isBestValue = false,
    this.revenueCatPackage,
    this.isMock = false,
  });

  /// Create from RevenueCat Package
  factory PurchasePackage.fromRevenueCat(Package package) {
    final product = package.storeProduct;

    // Explicit mapping for credit amounts (v1.2.0+ variable credit system)
    // Product IDs must match App Store Connect and webhook configuration
    const creditMap = {
      'pink_flag_3_searches': 30,   // $1.99 - Starter package
      'pink_flag_10_searches': 100, // $4.99 - Popular package (best value)
      'pink_flag_25_searches': 250, // $9.99 - Power user package
      // Legacy identifiers (if they exist)
      '3_searches': 30,
      '10_searches': 100,
      '25_searches': 250,
      'ten_searches': 100, // RevenueCat default identifier
    };

    // Get credit count from map, default to 100 if unknown
    final searchCount = creditMap[package.identifier] ?? 100;

    // Best value is the 100-credit package
    final isBestValue = package.identifier == 'pink_flag_10_searches' ||
                        package.identifier == 'ten_searches' ||
                        package.identifier == '10_searches';

    return PurchasePackage(
      id: package.identifier,
      title: product.title,
      description: product.description,
      price: product.priceString,
      searchCount: searchCount,
      isBestValue: isBestValue,
      revenueCatPackage: package,
      isMock: false,
    );
  }

  /// Create mock package for testing
  factory PurchasePackage.mock({
    required String id,
    required String title,
    required String description,
    required String price,
    required int searchCount,
    bool isBestValue = false,
  }) {
    return PurchasePackage(
      id: id,
      title: title,
      description: description,
      price: price,
      searchCount: searchCount,
      isBestValue: isBestValue,
      isMock: true,
    );
  }

  /// Default mock packages for development
  /// Note: 10x credit multiplier applied (3 → 30, 10 → 100, 25 → 250)
  static List<PurchasePackage> getMockPackages() {
    return [
      PurchasePackage.mock(
        id: '3_searches',
        title: '30 Credits',
        description: '3-15 searches depending on type',
        price: '\$1.99',
        searchCount: 30,
      ),
      PurchasePackage.mock(
        id: '10_searches',
        title: '100 Credits',
        description: 'Best value - Most popular!',
        price: '\$4.99',
        searchCount: 100,
        isBestValue: true,
      ),
      PurchasePackage.mock(
        id: '25_searches',
        title: '250 Credits',
        description: 'Maximum credits for power users',
        price: '\$9.99',
        searchCount: 250,
      ),
    ];
  }
}
