import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';
import '../models/search_result.dart';
import '../models/fbi_wanted_result.dart';

/// Search service with credit gating
/// **IMPORTANT**: Credit deduction now handled by backend (single source of truth)
/// **ENHANCED**: Now checks FBI Most Wanted list automatically
class SearchService {
  final _apiService = ApiService();
  final _authService = AuthService();

  // FBI Wanted API endpoint (FREE government API, no auth required)
  static const String _fbiWantedApiBase = 'https://api.fbi.gov/wanted/v1';

  /// Perform search
  /// **IMPORTANT**: Credit deduction now handled by backend (single source of truth)
  /// Backend manages credit validation, deduction, refunds, and search history
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

    try {
      // 2. Perform BOTH searches in parallel for speed
      // Backend handles credit deduction automatically
      // Run FBI wanted check alongside sex offender search
      final results = await Future.wait([
        // Backend sex offender search (handles credit deduction)
        _apiService.searchByName(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          zipCode: zipCode,
          age: age,
          state: state,
        ),
        // FBI wanted check (runs in parallel, FREE API)
        _checkFBIWanted(firstName, lastName),
      ]);

      final offenderResult = results[0] as SearchResult;
      final fbiResult = results[1] as FBIWantedResult;

      // 3. Merge FBI data into search result
      final enhancedResult = SearchResult(
        offenders: offenderResult.offenders,
        query: offenderResult.query,
        timestamp: offenderResult.timestamp,
        totalResults: offenderResult.totalResults,
        fbiWanted: fbiResult, // FBI wanted data
      );

      return enhancedResult;
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
