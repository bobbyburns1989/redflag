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

    // Extract search count from identifier
    int searchCount = 10; // Default
    if (package.identifier.contains('3')) searchCount = 3;
    if (package.identifier.contains('10')) searchCount = 10;
    if (package.identifier.contains('25')) searchCount = 25;

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
  static List<PurchasePackage> getMockPackages() {
    return [
      PurchasePackage.mock(
        id: '3_searches',
        title: '3 Searches',
        description: 'Perfect for quick lookups',
        price: '\$1.99',
        searchCount: 3,
      ),
      PurchasePackage.mock(
        id: '10_searches',
        title: '10 Searches',
        description: 'Best value - Most popular!',
        price: '\$4.99',
        searchCount: 10,
        isBestValue: true,
      ),
      PurchasePackage.mock(
        id: '25_searches',
        title: '25 Searches',
        description: 'Maximum searches for power users',
        price: '\$9.99',
        searchCount: 25,
      ),
    ];
  }
}
