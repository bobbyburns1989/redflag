import 'package:flutter/foundation.dart';
import '../models/purchase_package.dart';
import '../services/revenuecat_service.dart';
import '../services/auth_service.dart';

/// Result of a purchase operation
class PurchaseResult {
  final bool success;
  final bool cancelled;
  final bool pending;
  final int? newCredits;
  final String? error;

  PurchaseResult({
    this.success = false,
    this.cancelled = false,
    this.pending = false,
    this.newCredits,
    this.error,
  });

  factory PurchaseResult.success({int? newCredits}) {
    return PurchaseResult(success: true, newCredits: newCredits);
  }

  factory PurchaseResult.cancelled() {
    return PurchaseResult(cancelled: true);
  }

  factory PurchaseResult.pending() {
    return PurchaseResult(pending: true);
  }

  factory PurchaseResult.error(String message) {
    return PurchaseResult(error: message);
  }
}

/// Handles all purchase-related operations with retry logic
class PurchaseHandler {
  final RevenueCatService _revenueCatService;
  final AuthService _authService;

  PurchaseHandler({
    RevenueCatService? revenueCatService,
    AuthService? authService,
  })  : _revenueCatService = revenueCatService ?? RevenueCatService(),
        _authService = authService ?? AuthService();

  /// Purchase a package and wait for credits to be added
  /// Implements retry logic to handle webhook processing delays
  Future<PurchaseResult> purchasePackage(
    PurchasePackage package, {
    int maxRetries = 6,
    int Function(int)? delayGenerator,
  }) async {
    // Use RevenueCat for real packages, mock for test packages
    if (package.isMock) {
      return await _purchaseMockPackage(package);
    }

    if (package.revenueCatPackage == null) {
      return PurchaseResult.error('Invalid package: missing RevenueCat data');
    }

    // Initiate purchase through RevenueCat
    final result = await _revenueCatService.purchasePackage(
      package.revenueCatPackage!,
    );

    if (!result.success) {
      if (result.cancelled) return PurchaseResult.cancelled();
      if (result.pending) return PurchaseResult.pending();
      return PurchaseResult.error(result.error ?? 'Purchase failed');
    }

    // Purchase successful! Wait for webhook to add credits
    final newCredits = await _waitForCreditsWithRetry(
      maxRetries: maxRetries,
      delayGenerator: delayGenerator,
    );

    if (newCredits != null) {
      return PurchaseResult.success(newCredits: newCredits);
    }

    // Credits didn't appear, but purchase succeeded
    return PurchaseResult.success();
  }

  /// Wait for webhook to process and add credits
  /// Returns new credit count if successful, null if timeout
  Future<int?> _waitForCreditsWithRetry({
    int maxRetries = 6,
    int Function(int)? delayGenerator,
  }) async {
    final initialCredits = await _authService.getUserCredits();

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      // Wait before checking (1s, 2s, 3s, 4s, 5s, 6s by default)
      final delay = delayGenerator?.call(attempt) ?? (attempt + 1);
      await Future.delayed(Duration(seconds: delay));

      final newCredits = await _authService.getUserCredits();

      if (newCredits > initialCredits) {
        // Credits were added!
        if (kDebugMode) {
          print('✅ [PURCHASE] Credits added after ${attempt + 1} attempts');
        }
        return newCredits;
      }

      if (kDebugMode) {
        print('🔄 [PURCHASE] Attempt ${attempt + 1}/$maxRetries: Waiting for webhook...');
      }
    }

    // Timeout - credits didn't appear
    if (kDebugMode) {
      print('⏰ [PURCHASE] Timeout: Webhook took longer than expected');
    }
    return null;
  }

  /// Purchase a mock package (for testing/development)
  Future<PurchaseResult> _purchaseMockPackage(PurchasePackage package) async {
    try {
      // Simulate purchase delay
      await Future.delayed(const Duration(seconds: 1));

      // Get current user
      final user = await _authService.getCurrentUser();
      if (user == null) {
        return PurchaseResult.error('User not found');
      }

      // Add credits directly (simulating webhook)
      await _authService.addCredits(package.searchCount);

      // Get new credits
      final newCredits = await _authService.getUserCredits();

      if (kDebugMode) {
        print('✅ [PURCHASE] Mock purchase successful: +${package.searchCount} credits');
      }

      return PurchaseResult.success(newCredits: newCredits);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PURCHASE] Mock purchase error: $e');
      }
      return PurchaseResult.error(e.toString());
    }
  }

  /// Restore previous purchases
  Future<PurchaseResult> restorePurchases() async {
    final result = await _revenueCatService.restorePurchases();

    if (result.success) {
      final newCredits = await _authService.getUserCredits();
      return PurchaseResult.success(newCredits: newCredits);
    }

    return PurchaseResult.error(result.error ?? 'Failed to restore');
  }
}
