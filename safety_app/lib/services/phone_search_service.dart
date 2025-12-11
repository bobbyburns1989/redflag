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
/// via the backend (Twilio Lookup API v2). Backend is the single source
/// of truth for credit deduction (2 credits) and refunds.
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
  /// Required by Twilio Lookup API. Always formats as US number (+1).
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
  /// 2. Ensures user is authenticated
  /// 3. Calls backend API (deducts 2 credits + logs search + refunds on failure)
  /// 4. Returns the result
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

    // Step 2: Backend handles credit deduction (2 credits per lookup)
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw PhoneSearchException('User not authenticated');
    }

    try {
      // Step 3: Call backend API (deducts credits + logs history)
      final result = await _lookupPhone(e164);

      if (kDebugMode) {
        print(
          '✅ [PHONE] Phone lookup complete: ${result.callerName ?? "Unknown"}',
        );
      }

      return result;
    } catch (e) {
      if (e is PhoneSearchException || e is InsufficientCreditsException) {
        rethrow;
      }
      if (kDebugMode) {
        print('❌ [PHONE] Search error: $e');
      }
      throw PhoneSearchException('Phone lookup failed: ${e.toString()}');
    }
  }

  /// Call backend API for phone lookup
  ///
  /// Private method that makes the actual API call to our secure backend.
  /// The backend handles Twilio Lookup API integration server-side.
  Future<PhoneSearchResult> _lookupPhone(String e164Phone) async {
    if (kDebugMode) {
      print('📞 [PHONE] Calling backend phone lookup API...');
    }

    try {
      // Get auth token for backend authentication
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw PhoneSearchException('Authentication required');
      }

      // Build API URL
      final uri = Uri.parse('${AppConfig.API_BASE_URL}/phone/lookup');

      // Make POST request to backend with auth token
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${session.accessToken}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'phone_number': e164Phone,
            }),
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
        // Backend passes through Twilio response data in metadata field
        // Use Twilio parser to handle the response structure
        return PhoneSearchResult.fromTwilioResponse(
          jsonData['metadata'] ?? jsonData,
          e164Phone,
        );
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
