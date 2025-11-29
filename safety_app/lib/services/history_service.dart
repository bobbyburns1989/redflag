import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/credit_transaction.dart';
import '../models/search_history_entry.dart';

/// Service for fetching and managing user history data (transactions and searches).
class HistoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch recent credit transactions for the current user.
  Future<List<CreditTransaction>> fetchTransactions({int limit = 50}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('credit_transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((row) => CreditTransaction.fromMap(row)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HISTORY] Failed to fetch transactions: $e');
      }
      rethrow;
    }
  }

  /// Fetch recent search history entries for the current user.
  Future<List<SearchHistoryEntry>> fetchSearchHistory({int limit = 50}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('searches')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((row) => SearchHistoryEntry.fromMap(row)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HISTORY] Failed to fetch search history: $e');
      }
      rethrow;
    }
  }

  /// Clear all search history for the current user.
  Future<void> clearSearchHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase.from('searches').delete().eq('user_id', user.id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HISTORY] Failed to clear search history: $e');
      }
      rethrow;
    }
  }
}
