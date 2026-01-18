import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// RevenueCat service for managing in-app purchases
///
/// CRITICAL: This service handles user identity for purchase attribution.
/// - Always call initialize() on app start with the current user ID
/// - Call logIn() when user signs in
/// - Call logOut() when user signs out
///
/// Without proper user identification, purchases are attributed to
/// anonymous/wrong users and won't appear in RevenueCat dashboard.
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isConfigured = false;
  String? _currentUserId;

  /// Initialize or re-identify RevenueCat with user ID
  ///
  /// This method handles both initial configuration and user identity changes.
  /// - First call: Configures RevenueCat SDK with user ID
  /// - Subsequent calls: Uses logIn() to update user identity
  ///
  /// Always call this on app start for existing sessions and after sign-in.
  Future<void> initialize(String userId) async {
    if (kDebugMode) {
      print('🛒 [RC] initialize called with userId: $userId');
      print('🛒 [RC] Current state: configured=$_isConfigured, currentUser=$_currentUserId');
    }

    // If already configured with same user, skip
    if (_isConfigured && _currentUserId == userId) {
      if (kDebugMode) {
        print('🛒 [RC] Already configured with same user, skipping');
      }
      return;
    }

    try {
      if (!_isConfigured) {
        // First-time configuration
        if (kDebugMode) {
          print('🛒 [RC] First-time configuration with user: $userId');
        }
        await Purchases.configure(
          PurchasesConfiguration('appl_IRhHyHobKGcoteGnlLRWUFgnIos')
            ..appUserID = userId,
        );
        _isConfigured = true;
        _currentUserId = userId;
        if (kDebugMode) {
          print('✅ [RC] Configured successfully');
        }
      } else {
        // Already configured but different user - use logIn to switch
        if (kDebugMode) {
          print('🛒 [RC] Switching user from $_currentUserId to $userId');
        }
        await logIn(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RC] Error in initialize: $e');
      }
      rethrow;
    }
  }

  /// Log in a user to RevenueCat
  ///
  /// Call this when a user signs in to ensure purchases are attributed correctly.
  /// This updates the user identity in RevenueCat without re-configuring the SDK.
  Future<void> logIn(String userId) async {
    if (!_isConfigured) {
      if (kDebugMode) {
        print('⚠️ [RC] logIn called but SDK not configured, calling initialize');
      }
      await initialize(userId);
      return;
    }

    if (_currentUserId == userId) {
      if (kDebugMode) {
        print('🛒 [RC] logIn called with same user, skipping');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🛒 [RC] Logging in user: $userId');
      }
      final result = await Purchases.logIn(userId);
      _currentUserId = userId;
      if (kDebugMode) {
        print('✅ [RC] User logged in successfully');
        print('🛒 [RC] CustomerInfo: ${result.customerInfo.originalAppUserId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RC] Error in logIn: $e');
      }
      rethrow;
    }
  }

  /// Log out the current user from RevenueCat
  ///
  /// Call this when a user signs out. This resets to an anonymous user.
  /// The next sign-in should call logIn() to identify the new user.
  Future<void> logOut() async {
    if (!_isConfigured) {
      if (kDebugMode) {
        print('⚠️ [RC] logOut called but SDK not configured, skipping');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🛒 [RC] Logging out user: $_currentUserId');
      }
      await Purchases.logOut();
      _currentUserId = null;
      if (kDebugMode) {
        print('✅ [RC] User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RC] Error in logOut: $e');
      }
      // Don't rethrow - logout errors shouldn't block sign-out flow
    }
  }

  /// Get the currently identified user ID
  String? get currentUserId => _currentUserId;

  /// Check if RevenueCat is configured
  bool get isConfigured => _isConfigured;

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
