import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/search_result.dart';

/// Search service with credit gating
/// Wraps ApiService and handles credit deduction via Supabase
class SearchService {
  final _supabase = Supabase.instance.client;
  final _apiService = ApiService();
  final _authService = AuthService();

  /// Perform search (deducts credit automatically)
  Future<SearchResult> searchByName({
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? zipCode,
    String? age,
    String? state,
  }) async {
    // 1. Check if user is authenticated
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    final userId = _authService.currentUser!.id;
    final query = lastName != null && lastName.isNotEmpty
        ? '$firstName $lastName'
        : firstName;

    // 2. Deduct credit via Supabase RPC function
    try {
      final response = await _supabase.rpc('deduct_credit_for_search', params: {
        'p_user_id': userId,
        'p_query': query,
        'p_results_count': 0, // Will update after search
      });

      // Check if deduction was successful
      if (response['success'] == false) {
        if (response['error'] == 'insufficient_credits') {
          throw InsufficientCreditsException(response['credits'] as int);
        }
        throw Exception('Failed to deduct credit: ${response['error']}');
      }

      // 3. Perform the actual search using existing API service
      final searchResult = await _apiService.searchByName(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        zipCode: zipCode,
        age: age,
        state: state,
      );

      // 4. Update the search record with actual results count
      // Note: This is a best-effort update, don't fail the search if it fails
      try {
        final searchId = response['search_id'];
        if (searchId != null) {
          await _supabase.from('searches').update({
            'results_count': searchResult.totalResults,
          }).eq('id', searchId);
        }
      } catch (e) {
        // Log but don't fail - this is just analytics
      }

      return searchResult;
    } on PostgrestException catch (e) {
      // Database error
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      // Re-throw known exceptions
      if (e is InsufficientCreditsException) rethrow;
      if (e is ApiException) rethrow;
      if (e is NetworkException) rethrow;
      if (e is ServerException) rethrow;
      rethrow;
    }
  }

  /// Get current user's credit balance
  Future<int> getCurrentCredits() async {
    return await _authService.getUserCredits();
  }

  /// Watch credit balance in real-time
  Stream<int> watchCredits() {
    return _authService.watchCredits();
  }
}

/// Exception thrown when user has insufficient credits
class InsufficientCreditsException implements Exception {
  final int currentCredits;

  InsufficientCreditsException(this.currentCredits);

  @override
  String toString() =>
      'Insufficient credits. You have $currentCredits credit${currentCredits == 1 ? '' : 's'} remaining.';
}
