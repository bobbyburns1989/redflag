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
    final isBestValue = package.identifier == 'ten_searches';

    // Extract credit count from identifier (10x multiplier from old search counts)
    int searchCount = 100; // Default (was 10 searches)
    if (package.identifier.contains('3')) searchCount = 30;  // 3 → 30 credits
    if (package.identifier.contains('10')) searchCount = 100; // 10 → 100 credits
    if (package.identifier.contains('25')) searchCount = 250; // 25 → 250 credits

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
