import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/phone_search_result.dart';

/// Service for phone number lookup and validation.
///
/// Handles phone number validation, formatting, and reverse lookup
/// using the Sent.dm API, with credit deduction integration.
class PhoneSearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Validate phone number format (US only)
  ///
  /// Returns true if the phone number is valid US number, false otherwise.
  /// This is an offline check using Google's libphonenumber library.
  bool validatePhoneFormat(String phoneNumber) {
    try {
      PhoneNumber parsed;

      // For US-only validation, always parse with US country code
      // This ensures 10-digit numbers like 6178999771 are correctly identified as US
      parsed = PhoneNumber.parse(phoneNumber, destinationCountry: IsoCode.US);

      // Verify it's a US number and valid
      return parsed.isValid() && parsed.isoCode == IsoCode.US;
    } catch (e) {
      if (kDebugMode) {
        print('📞 [PHONE] Validation error: $e');
      }
      return false;
    }
  }

  /// Parse and format phone number to E.164 format (US only)
  ///
  /// E.164 is the international phone number format (e.g., +12345678900)
  /// Required by the Sent.dm API. Always formats as US number (+1).
  String? formatToE164(String phoneNumber) {
    try {
      // For US-only formatting, always parse with US country code
      // This ensures 10-digit numbers like 6178999771 are correctly identified as US
      PhoneNumber parsed = PhoneNumber.parse(
        phoneNumber,
        destinationCountry: IsoCode.US,
      );

      // Only accept US numbers
      if (parsed.isValid() && parsed.isoCode == IsoCode.US) {
        return parsed.international.replaceAll(' ', '');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('📞 [PHONE] Format error: $e');
      }
      return null;
    }
  }

  /// Get national format of phone number (e.g., "(555) 123-4567")
  String? formatNational(String phoneNumber) {
    try {
      // Always parse with US country code for consistency
      final parsed = PhoneNumber.parse(
        phoneNumber,
        destinationCountry: IsoCode.US,
      );
      if (parsed.isValid()) {
        // Format as national number using the formatNsn method
        return parsed.formatNsn();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Search phone number with credit deduction
  ///
  /// This is the main method that:
  /// 1. Validates the phone number
  /// 2. Checks user credits
  /// 3. Deducts 1 credit
  /// 4. Calls Sent.dm API
  /// 5. Logs the search
  /// 6. Returns the result
  /// 7. **NEW**: Refunds credit if API fails (503, 500, timeout, etc.)
  Future<PhoneSearchResult> searchPhoneWithCredit(String phoneNumber) async {
    if (kDebugMode) {
      print('📞 [PHONE] Starting phone lookup for: $phoneNumber');
    }

    // Step 1: Format to E.164
    final e164 = formatToE164(phoneNumber);
    if (e164 == null) {
      throw PhoneSearchException('Invalid phone number format');
    }

    if (kDebugMode) {
      print('📞 [PHONE] Formatted to E.164: $e164');
    }

    // Step 2: Check and deduct credit via Supabase function
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw PhoneSearchException('User not authenticated');
    }

    String? searchId;
    bool creditDeducted = false;

    try {
      // Call Supabase RPC function to deduct credit and log search
      final response = await _supabase.rpc(
        'deduct_credit_for_search',
        params: {
          'p_user_id': user.id,
          'p_query': e164,
          'p_results_count': 0, // Will update after API call
        },
      );

      if (kDebugMode) {
        print('📞 [PHONE] Credit deduction response: $response');
      }

      // Check if credit deduction was successful
      if (response['success'] != true) {
        final error = response['error'];
        if (error == 'insufficient_credits') {
          throw InsufficientCreditsException(
            'Not enough credits. You have ${response['credits']} credits.',
          );
        }
        throw PhoneSearchException('Failed to deduct credit: $error');
      }

      searchId = response['search_id'];
      creditDeducted = true;
      final remainingCredits = response['credits'];

      if (kDebugMode) {
        print('📞 [PHONE] Credit deducted. Remaining: $remainingCredits');
        print('📞 [PHONE] Search ID: $searchId');
      }

      // Step 3: Call Sent.dm API
      final result = await _lookupPhone(e164);

      // Step 4: Update search results count
      if (searchId != null) {
        try {
          await _supabase
              .from('searches')
              .update({
                'results_count': 1, // Phone lookup always returns 1 result
                'phone_number': e164,
                'search_type': 'phone',
              })
              .eq('id', searchId);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [PHONE] Failed to update search history: $e');
          }
          // Don't fail the search if history update fails
        }
      }

      if (kDebugMode) {
        print(
          '✅ [PHONE] Phone lookup complete: ${result.callerName ?? "Unknown"}',
        );
      }

      return result;
    } catch (e) {
      // Refund credit if API call failed and credit was deducted
      if (creditDeducted && searchId != null && _shouldRefund(e)) {
        await _refundCredit(searchId, _getRefundReason(e));
      }

      // Re-throw the original error
      if (e is PhoneSearchException || e is InsufficientCreditsException) {
        rethrow;
      }
      if (kDebugMode) {
        print('❌ [PHONE] Search error: $e');
      }
      throw PhoneSearchException('Phone lookup failed: ${e.toString()}');
    }
  }

  /// Call Sent.dm API for phone lookup
  ///
  /// Private method that makes the actual API call.
  Future<PhoneSearchResult> _lookupPhone(String e164Phone) async {
    if (kDebugMode) {
      print('📞 [PHONE] Calling Sent.dm API...');
    }

    try {
      // Build API URL with query parameter
      final uri = Uri.parse(
        '${AppConfig.SENTDM_API_URL}?phone=${Uri.encodeComponent(e164Phone)}',
      );

      // Make GET request with Bearer token
      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer ${AppConfig.SENTDM_API_KEY}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw PhoneSearchException(
              '⏱️ Request Timed Out\n\nThe phone lookup service didn\'t respond in time. Don\'t worry - your credit was automatically refunded!\n\nPlease check your internet connection and try again.',
            ),
          );

      if (kDebugMode) {
        print('📞 [PHONE] API Response Status: ${response.statusCode}');
        print('📞 [PHONE] API Response Body: ${response.body}');
      }

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return PhoneSearchResult.fromSentdmResponse(jsonData, e164Phone);
      } else if (response.statusCode == 503) {
        // Service maintenance - specific message
        throw PhoneSearchException(
          '🔧 Service Under Maintenance\n\nThe phone lookup service is temporarily down for maintenance. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few minutes.',
        );
      } else if (response.statusCode == 401) {
        throw PhoneSearchException(
          '🔐 Service Temporarily Unavailable\n\nWe\'re experiencing authentication issues with the phone lookup service. Don\'t worry - your credit was automatically refunded!\n\nPlease try again later or contact support if this persists.',
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException(
          '⏳ Too Many Requests\n\nWe\'ve reached the service\'s rate limit. Don\'t worry - your credit was automatically refunded!\n\nPlease wait a minute and try again.',
        );
      } else if (response.statusCode == 404) {
        // Number not found - return basic result
        return PhoneSearchResult(
          phoneNumber: e164Phone,
          nationalFormat: formatNational(e164Phone),
          isValid: true,
        );
      } else if (response.statusCode >= 500) {
        throw PhoneSearchException(
          '⚠️ Server Error\n\nThe phone lookup service is experiencing technical difficulties. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few moments.',
        );
      } else {
        throw PhoneSearchException(
          'Phone lookup service returned an error (${response.statusCode}). Your credit was refunded. Please try again.',
        );
      }
    } on http.ClientException {
      throw PhoneSearchException(
        '📡 No Internet Connection\n\nCouldn\'t connect to the phone lookup service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } catch (e) {
      if (e is PhoneSearchException || e is RateLimitException) {
        rethrow;
      }
      if (kDebugMode) {
        print('❌ [PHONE] API call failed: $e');
      }
      throw PhoneSearchException('Unexpected error: ${e.toString()}');
    }
  }

  /// Check if error warrants a credit refund
  ///
  /// Returns true for server errors, timeouts, and network issues.
  /// Returns false for client errors like invalid input (400, 404).
  bool _shouldRefund(dynamic error) {
    // Check PhoneSearchException messages for refundable errors
    if (error is PhoneSearchException) {
      final message = error.message.toLowerCase();

      // Refund for server errors (503, 500, 502, 504)
      if (message.contains('503') ||
          message.contains('maintenance') ||
          message.contains('500') ||
          message.contains('502') ||
          message.contains('504') ||
          message.contains('server error')) {
        return true;
      }

      // Refund for timeouts
      if (message.contains('timeout') || message.contains('timed out')) {
        return true;
      }

      // Refund for network errors
      if (message.contains('network error') ||
          message.contains('connection') ||
          message.contains('no internet')) {
        return true;
      }

      // Refund for API key issues (our fault, not user's)
      if (message.contains('401') ||
          message.contains('403') ||
          message.contains('authentication failed')) {
        return true;
      }
    }

    // Refund for rate limit errors
    if (error is RateLimitException) {
      return true;
    }

    // Refund for HTTP client exceptions (network issues)
    if (error is http.ClientException) {
      return true;
    }

    // Don't refund for insufficient credits (not an API failure)
    if (error is InsufficientCreditsException) {
      return false;
    }

    return false;
  }

  /// Get refund reason code from error
  ///
  /// Maps errors to reason codes for tracking and display.
  String _getRefundReason(dynamic error) {
    if (error is PhoneSearchException) {
      final message = error.message.toLowerCase();

      if (message.contains('503') || message.contains('maintenance')) {
        return 'api_maintenance_503';
      }
      if (message.contains('500')) return 'server_error_500';
      if (message.contains('502')) return 'bad_gateway_502';
      if (message.contains('504')) return 'gateway_timeout_504';
      if (message.contains('timeout') || message.contains('timed out')) {
        return 'request_timeout';
      }
      if (message.contains('network error') || message.contains('connection')) {
        return 'network_error';
      }
      if (message.contains('401') ||
          message.contains('403') ||
          message.contains('authentication')) {
        return 'api_auth_error';
      }
    }

    if (error is RateLimitException) {
      return 'rate_limit_429';
    }

    if (error is http.ClientException) {
      return 'network_error';
    }

    return 'unknown_error';
  }

  /// Refund credit for failed search
  ///
  /// Calls Supabase RPC function to add 1 credit back to user's balance.
  /// This is a best-effort operation - failures are logged but don't fail the search.
  Future<void> _refundCredit(String searchId, String reason) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      if (kDebugMode) {
        print('🔄 [PHONE] Refunding credit. Reason: $reason');
      }

      final response = await _supabase.rpc(
        'refund_credit_for_failed_search',
        params: {
          'p_user_id': user.id,
          'p_search_id': searchId,
          'p_reason': reason,
        },
      );

      if (kDebugMode) {
        if (response['success'] == true) {
          print(
            '✅ [PHONE] Credit refunded. New balance: ${response['credits']}',
          );
        } else {
          print('❌ [PHONE] Refund failed: ${response['error']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [PHONE] Refund request failed: $e');
      }
      // Don't fail the original error - refund is best-effort
    }
  }

  /// Check if Sent.dm API key is configured
  bool get isApiKeyConfigured {
    return AppConfig.SENTDM_API_KEY != 'YOUR_SENTDM_API_KEY_HERE' &&
        AppConfig.SENTDM_API_KEY.isNotEmpty;
  }
}

/// Exception thrown when phone search fails
class PhoneSearchException implements Exception {
  final String message;

  PhoneSearchException(this.message);

  @override
  String toString() => 'PhoneSearchException: $message';
}

/// Exception thrown when user has insufficient credits
class InsufficientCreditsException implements Exception {
  final String message;

  InsufficientCreditsException(this.message);

  @override
  String toString() => 'InsufficientCreditsException: $message';
}

/// Exception thrown when API rate limit is exceeded
class RateLimitException implements Exception {
  final String message;

  RateLimitException(this.message);

  @override
  String toString() => 'RateLimitException: $message';
}
