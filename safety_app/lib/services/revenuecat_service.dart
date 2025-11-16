import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';

/// RevenueCat service for managing in-app purchases
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize RevenueCat with user ID
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      // Configure RevenueCat
      await Purchases.configure(
        PurchasesConfiguration('appl_IRhHyHobKGcoteGnlLRWUFgnIos')
          ..appUserID = userId,
      );

      _isInitialized = true;
    } catch (e) {
      // Error initializing RevenueCat
      rethrow;
    }
  }

  /// Get available offerings (products to purchase)
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      // Error getting offerings
      return null;
    }
  }

  /// Purchase a package
  Future<AppPurchaseResult> purchasePackage(Package package) async {
    try {
      // Use new purchase API with PurchaseParams
      final params = PurchaseParams.package(package);
      final result = await Purchases.purchase(params);

      // Success - result contains customerInfo and storeTransaction
      return AppPurchaseResult.success(result.customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return AppPurchaseResult.cancelled();
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return AppPurchaseResult.pending();
      } else {
        return AppPurchaseResult.failed(e.message ?? 'Purchase failed');
      }
    } catch (e) {
      return AppPurchaseResult.failed('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Restore purchases
  Future<RestoreResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return RestoreResult.success(customerInfo);
    } catch (e) {
      return RestoreResult.failed('Failed to restore purchases: ${e.toString()}');
    }
  }

  /// Get customer info (current entitlements and subscription status)
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      // Error getting customer info
      return null;
    }
  }
}

/// Result object for purchase operations (renamed to avoid conflict with RevenueCat's PurchaseResult)
class AppPurchaseResult {
  final bool success;
  final bool cancelled;
  final bool pending;
  final CustomerInfo? customerInfo;
  final String? error;

  AppPurchaseResult.success(this.customerInfo)
      : success = true,
        cancelled = false,
        pending = false,
        error = null;

  AppPurchaseResult.cancelled()
      : success = false,
        cancelled = true,
        pending = false,
        customerInfo = null,
        error = 'Purchase was cancelled';

  AppPurchaseResult.pending()
      : success = false,
        cancelled = false,
        pending = true,
        customerInfo = null,
        error = 'Purchase is pending';

  AppPurchaseResult.failed(this.error)
      : success = false,
        cancelled = false,
        pending = false,
        customerInfo = null;
}

/// Result object for restore operations
class RestoreResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  RestoreResult.success(this.customerInfo)
      : success = true,
        error = null;

  RestoreResult.failed(this.error)
      : success = false,
        customerInfo = null;
}
