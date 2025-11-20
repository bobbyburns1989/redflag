import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service focused on credit management operations only
/// Handles fetching, adding, watching, and deducting credits
class CreditsService {
  final SupabaseClient _supabase;

  CreditsService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get _isAuthenticated => _currentUserId != null;

  /// Get user credits from database (with retry for race condition)
  Future<int> getUserCredits({int maxAttempts = 3}) async {
    if (!_isAuthenticated) {
      if (kDebugMode) {
        print('⚠️ [CREDITS] getUserCredits: User not authenticated');
      }
      return 0;
    }

    if (kDebugMode) {
      print('🔍 [CREDITS] getUserCredits: Fetching credits for user $_currentUserId');
    }

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (kDebugMode) {
        print('🔍 [CREDITS] getUserCredits: Attempt ${attempt + 1}/$maxAttempts');
      }

      try {
        final response = await _supabase
            .from('profiles')
            .select('credits')
            .eq('id', _currentUserId!)
            .single();

        final credits = response['credits'] as int;
        if (kDebugMode) {
          print('✅ [CREDITS] getUserCredits: Found $credits credits');
        }
        return credits;
      } catch (e) {
        if (kDebugMode) {
          print('❌ [CREDITS] getUserCredits: Error on attempt ${attempt + 1}: $e');
        }

        // If not last attempt, wait and retry
        if (attempt < maxAttempts - 1) {
          final delay = 300 * (attempt + 1);
          if (kDebugMode) {
            print('⏳ [CREDITS] getUserCredits: Retrying in ${delay}ms...');
          }
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }
        // Last attempt failed, return 0
        if (kDebugMode) {
          print('⚠️ [CREDITS] getUserCredits: All attempts failed, returning 0');
        }
        return 0;
      }
    }

    return 0;
  }

  /// Listen to credit changes in real-time
  Stream<int> watchCredits() {
    if (!_isAuthenticated) {
      return Stream.value(0);
    }

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', _currentUserId!)
        .map((data) {
          if (data.isEmpty) return 0;
          return data.first['credits'] as int;
        });
  }

  /// Add credits to user account
  /// Note: In production, this should only be called by RevenueCat webhook
  /// This method is for testing/mock purchases only
  Future<void> addCredits(int amount) async {
    if (!_isAuthenticated) {
      throw Exception('User not authenticated');
    }

    if (kDebugMode) {
      print('💎 [CREDITS] Adding $amount credits to user $_currentUserId');
    }

    try {
      // Get current credits
      final currentCredits = await getUserCredits();
      final newCredits = currentCredits + amount;

      // Update credits in database
      await _supabase
          .from('profiles')
          .update({'credits': newCredits})
          .eq('id', _currentUserId!);

      if (kDebugMode) {
        print('✅ [CREDITS] Credits updated: $currentCredits → $newCredits');
      }

      // Also record the transaction
      await _supabase.from('credit_transactions').insert({
        'user_id': _currentUserId!,
        'transaction_type': 'purchase',
        'credits': amount,
        // Note: 'amount' column may not exist in older schema versions
        // In production, amount is recorded via RevenueCat webhook
        'provider': 'mock',
        'provider_transaction_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
      });

      if (kDebugMode) {
        print('✅ [CREDITS] Transaction recorded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CREDITS] Error adding credits: $e');
      }
      rethrow;
    }
  }

  /// Deduct one credit from user account
  /// Returns true if successful, false if insufficient credits
  Future<bool> deductCredit() async {
    if (!_isAuthenticated) {
      if (kDebugMode) {
        print('⚠️ [CREDITS] deductCredit: User not authenticated');
      }
      return false;
    }

    try {
      final currentCredits = await getUserCredits();

      if (currentCredits <= 0) {
        if (kDebugMode) {
          print('⚠️ [CREDITS] Insufficient credits: $currentCredits');
        }
        return false;
      }

      // Deduct credit
      final newCredits = currentCredits - 1;
      await _supabase
          .from('profiles')
          .update({'credits': newCredits})
          .eq('id', _currentUserId!);

      if (kDebugMode) {
        print('✅ [CREDITS] Credit deducted: $currentCredits → $newCredits');
      }

      // Record transaction
      await _supabase.from('credit_transactions').insert({
        'user_id': _currentUserId!,
        'transaction_type': 'search',
        'credits': -1,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CREDITS] Error deducting credit: $e');
      }
      return false;
    }
  }
}
