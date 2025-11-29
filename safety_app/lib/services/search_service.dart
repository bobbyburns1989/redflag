import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/search_result.dart';
import '../models/fbi_wanted_result.dart';

/// Search service with credit gating
/// Wraps ApiService and handles credit deduction via Supabase
/// **ENHANCED**: Now checks FBI Most Wanted list automatically
class SearchService {
  final _supabase = Supabase.instance.client;
  final _apiService = ApiService();
  final _authService = AuthService();

  // FBI Wanted API endpoint (FREE government API, no auth required)
  static const String _fbiWantedApiBase = 'https://api.fbi.gov/wanted/v1';

  /// Perform search (deducts credit automatically)
  /// **NEW**: Refunds credit if API fails (500, timeout, network errors).
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

    String? searchId;
    bool creditDeducted = false;

    // 2. Deduct credit via Supabase RPC function
    try {
      final response = await _supabase.rpc(
        'deduct_credit_for_search',
        params: {
          'p_user_id': userId,
          'p_query': query,
          'p_results_count': 0, // Will update after search
        },
      );

      // Check if deduction was successful
      if (response['success'] == false) {
        if (response['error'] == 'insufficient_credits') {
          throw InsufficientCreditsException(response['credits'] as int);
        }
        throw Exception('Failed to deduct credit: ${response['error']}');
      }

      searchId = response['search_id'];
      creditDeducted = true;

      // 3. Perform BOTH searches in parallel for speed
      // Run FBI wanted check alongside sex offender search
      final results = await Future.wait([
        // Existing sex offender search
        _apiService.searchByName(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          zipCode: zipCode,
          age: age,
          state: state,
        ),
        // NEW: FBI wanted check (runs in parallel, FREE API)
        _checkFBIWanted(firstName, lastName),
      ]);

      final offenderResult = results[0] as SearchResult;
      final fbiResult = results[1] as FBIWantedResult;

      // 4. Merge FBI data into search result
      final enhancedResult = SearchResult(
        offenders: offenderResult.offenders,
        query: offenderResult.query,
        timestamp: offenderResult.timestamp,
        totalResults: offenderResult.totalResults,
        fbiWanted: fbiResult, // NEW: FBI wanted data
      );

      // 5. Update the search record with actual results count and FBI match
      // Note: This is a best-effort update, don't fail the search if it fails
      try {
        if (searchId != null) {
          await _supabase
              .from('searches')
              .update({
                'results_count': enhancedResult.totalResults,
                'fbi_match': fbiResult.isMatch, // NEW: track FBI matches
              })
              .eq('id', searchId);
        }
      } catch (e) {
        // Log but don't fail - this is just analytics
      }

      return enhancedResult;
    } on PostgrestException catch (e) {
      // Database error
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      // Refund credit if API call failed and credit was deducted
      if (creditDeducted && searchId != null && _shouldRefund(e)) {
        await _refundCredit(searchId, _getRefundReason(e));
      }

      // Re-throw known exceptions
      if (e is InsufficientCreditsException) rethrow;
      if (e is ApiException) rethrow;
      if (e is NetworkException) rethrow;
      if (e is ServerException) rethrow;
      rethrow;
    }
  }

  /// Check if error warrants a credit refund
  bool _shouldRefund(dynamic error) {
    // Refund for server errors
    if (error is ServerException) {
      return true;
    }

    // Refund for network errors
    if (error is NetworkException) {
      return true;
    }

    // Don't refund for client errors (bad input)
    if (error is ApiException) {
      final message = error.toString().toLowerCase();
      // Refund for 500+ errors, not for 400 errors
      return message.contains('500') ||
          message.contains('502') ||
          message.contains('503') ||
          message.contains('504') ||
          message.contains('server error') ||
          message.contains('timeout');
    }

    // Don't refund for insufficient credits
    if (error is InsufficientCreditsException) {
      return false;
    }

    return false;
  }

  /// Get refund reason code from error
  String _getRefundReason(dynamic error) {
    if (error is ServerException) {
      return 'server_error_500';
    }

    if (error is NetworkException) {
      return 'network_error';
    }

    if (error is ApiException) {
      final message = error.toString().toLowerCase();
      if (message.contains('503')) return 'api_maintenance_503';
      if (message.contains('500')) return 'server_error_500';
      if (message.contains('502')) return 'bad_gateway_502';
      if (message.contains('504')) return 'gateway_timeout_504';
      if (message.contains('timeout')) return 'request_timeout';
      return 'server_error_500';
    }

    return 'unknown_error';
  }

  /// Refund credit for failed search
  Future<void> _refundCredit(String searchId, String reason) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase.rpc(
        'refund_credit_for_failed_search',
        params: {
          'p_user_id': user.id,
          'p_search_id': searchId,
          'p_reason': reason,
        },
      );

      // Silently handle refund - best effort
      // No debug prints to keep name search service quiet
    } catch (e) {
      // Don't fail the original error - refund is best-effort
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

  /// Check FBI Most Wanted list
  /// Returns FBIWantedResult with match info or no-match result
  /// **GRACEFUL DEGRADATION**: FBI API errors don't fail the main search
  Future<FBIWantedResult> _checkFBIWanted(
    String firstName,
    String? lastName,
  ) async {
    try {
      final fullName = lastName != null && lastName.isNotEmpty
          ? '$firstName $lastName'
          : firstName;

      final uri = Uri.parse('$_fbiWantedApiBase/list').replace(
        queryParameters: {
          'title': fullName,
          'pageSize': '5', // Get top 5 matches
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException(
          'FBI API request timed out',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          // Filter out "located" persons (already caught) and "information" posters
          final activeWanted = items.where((item) {
            final status = item['status']?.toString().toLowerCase();
            final classification = item['poster_classification']?.toString().toLowerCase();

            // Skip if already located
            if (status == 'located') return false;

            // Skip "seeking information" posters (not actual wanted persons)
            if (classification == 'information') return false;

            return true;
          }).toList();

          if (activeWanted.isNotEmpty) {
            // Return first actively wanted match
            return FBIWantedResult.fromJson(activeWanted.first);
          }
        }
      } else if (response.statusCode >= 500) {
        // FBI API server error - don't fail entire search
        if (kDebugMode) {
          print('FBI API server error: ${response.statusCode}');
        }
      }

      // No match found or API error
      return FBIWantedResult.noMatch();
    } on SocketException {
      // Network error - don't fail entire search
      if (kDebugMode) {
        print('FBI API network error');
      }
      return FBIWantedResult.noMatch();
    } on TimeoutException {
      // Timeout - don't fail entire search
      if (kDebugMode) {
        print('FBI API timeout');
      }
      return FBIWantedResult.noMatch();
    } catch (e) {
      // Any other error - don't fail entire search
      if (kDebugMode) {
        print('FBI API error: $e');
      }
      return FBIWantedResult.noMatch();
    }
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
