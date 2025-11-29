import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/image_search_result.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'search_service.dart' show InsufficientCreditsException;

/// Service for performing reverse image searches via TinEye API
///
/// Handles:
/// - Image upload to backend
/// - URL-based image search
/// - Credit deduction via Supabase
/// - Error handling and user feedback
class ImageSearchService {
  // Production backend URL (same as name search)
  static const String _baseUrl = 'https://pink-flag-api.fly.dev/api';

  final _supabase = Supabase.instance.client;
  final _authService = AuthService();

  /// Search by image file (from camera or gallery)
  ///
  /// Uploads the image to the backend which then queries TinEye.
  /// Deducts 1 credit from user's balance.
  /// **NEW**: Refunds credit if API fails (500, timeout, network errors).
  Future<ImageSearchResult> searchByImage(File imageFile) async {
    // 1. Check authentication
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    final userId = _authService.currentUser!.id;
    final fileName = imageFile.path.split('/').last;
    final query = 'IMAGE_SEARCH: $fileName';

    String? searchId;
    bool creditDeducted = false;

    // 2. Deduct credit via Supabase RPC
    try {
      final response = await _supabase.rpc(
        'deduct_credit_for_search',
        params: {'p_user_id': userId, 'p_query': query, 'p_results_count': 0},
      );

      if (response['success'] == false) {
        if (response['error'] == 'insufficient_credits') {
          throw InsufficientCreditsException(response['credits'] as int);
        }
        throw Exception('Failed to deduct credit: ${response['error']}');
      }

      searchId = response['search_id'];
      creditDeducted = true;

      // 3. Perform the image search
      final searchResult = await _uploadAndSearch(imageFile);

      // 4. Update search record with results count (best effort)
      try {
        if (searchId != null) {
          await _supabase
              .from('searches')
              .update({'results_count': searchResult.totalMatches})
              .eq('id', searchId);
        }
      } catch (e) {
        // Log but don't fail
        if (kDebugMode) {
          print('Failed to update search record: $e');
        }
      }

      return searchResult;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      // Refund credit if API call failed and credit was deducted
      if (creditDeducted && searchId != null && _shouldRefund(e)) {
        await _refundCredit(searchId, _getRefundReason(e));
      }

      // Re-throw the original error
      if (e is InsufficientCreditsException) rethrow;
      if (e is ApiException) rethrow;
      if (e is NetworkException) rethrow;
      rethrow;
    }
  }

  /// Search by image URL
  ///
  /// Sends the URL to the backend which fetches and searches the image.
  /// Deducts 1 credit from user's balance.
  /// **NEW**: Refunds credit if API fails (500, timeout, network errors).
  Future<ImageSearchResult> searchByUrl(String imageUrl) async {
    // 1. Check authentication
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    final userId = _authService.currentUser!.id;
    final query = 'IMAGE_SEARCH: $imageUrl';

    String? searchId;
    bool creditDeducted = false;

    // 2. Deduct credit via Supabase RPC
    try {
      final response = await _supabase.rpc(
        'deduct_credit_for_search',
        params: {'p_user_id': userId, 'p_query': query, 'p_results_count': 0},
      );

      if (response['success'] == false) {
        if (response['error'] == 'insufficient_credits') {
          throw InsufficientCreditsException(response['credits'] as int);
        }
        throw Exception('Failed to deduct credit: ${response['error']}');
      }

      searchId = response['search_id'];
      creditDeducted = true;

      // 3. Perform the URL search
      final searchResult = await _searchByUrlRequest(imageUrl);

      // 4. Update search record with results count
      try {
        if (searchId != null) {
          await _supabase
              .from('searches')
              .update({'results_count': searchResult.totalMatches})
              .eq('id', searchId);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to update search record: $e');
        }
      }

      return searchResult;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      // Refund credit if API call failed and credit was deducted
      if (creditDeducted && searchId != null && _shouldRefund(e)) {
        await _refundCredit(searchId, _getRefundReason(e));
      }

      // Re-throw the original error
      if (e is InsufficientCreditsException) rethrow;
      if (e is ApiException) rethrow;
      if (e is NetworkException) rethrow;
      rethrow;
    }
  }

  /// Upload image file and perform search
  Future<ImageSearchResult> _uploadAndSearch(File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/image-search');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Determine content type from file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      final contentType = switch (extension) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg', // Default to jpeg
      };

      // Add the image file with explicit content type
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Image upload may take longer
        onTimeout: () => throw TimeoutException(
          '⏱️ Request Timed Out\n\nThe image search service didn\'t respond in time. Don\'t worry - your credit was automatically refunded!\n\nPlease check your internet connection and try again.',
        ),
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ImageSearchResult.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ApiException(error['detail'] ?? 'Invalid image');
      } else if (response.statusCode == 503) {
        throw ServerException(
          '🔧 Service Under Maintenance\n\nThe image search service is temporarily down for maintenance. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few minutes.',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(
          '⚠️ Server Error\n\nThe image search service is experiencing technical difficulties. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few moments.',
        );
      } else {
        throw ApiException('Image search failed. Please try again.');
      }
    } on SocketException {
      throw NetworkException(
        '📡 No Internet Connection\n\nCouldn\'t connect to the image search service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } on TimeoutException {
      rethrow;
    } on ServerException {
      rethrow;
    } on http.ClientException {
      throw NetworkException(
        '📡 Connection Failed\n\nCouldn\'t connect to the image search service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred. Please try again.');
    }
  }

  /// Search by URL request
  Future<ImageSearchResult> _searchByUrlRequest(String imageUrl) async {
    try {
      final uri = Uri.parse('$_baseUrl/image-search');

      // Send as form data with URL
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'image_url': imageUrl},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              '⏱️ Request Timed Out\n\nThe image search service didn\'t respond in time. Don\'t worry - your credit was automatically refunded!\n\nPlease check your internet connection and try again.',
            ),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ImageSearchResult.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ApiException(error['detail'] ?? 'Invalid image URL');
      } else if (response.statusCode == 503) {
        throw ServerException(
          '🔧 Service Under Maintenance\n\nThe image search service is temporarily down for maintenance. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few minutes.',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(
          '⚠️ Server Error\n\nThe image search service is experiencing technical difficulties. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few moments.',
        );
      } else {
        throw ApiException('Image search failed. Please try again.');
      }
    } on SocketException {
      throw NetworkException(
        '📡 No Internet Connection\n\nCouldn\'t connect to the image search service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } on TimeoutException {
      rethrow;
    } on ServerException {
      rethrow;
    } on http.ClientException {
      throw NetworkException(
        '📡 Connection Failed\n\nCouldn\'t connect to the image search service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred. Please try again.');
    }
  }

  /// Check if error warrants a credit refund
  ///
  /// Returns true for server errors, timeouts, and network issues.
  /// Returns false for client errors like invalid input (400).
  bool _shouldRefund(dynamic error) {
    // Refund for server errors
    if (error is ServerException) {
      return true;
    }

    // Refund for network errors
    if (error is NetworkException) {
      return true;
    }

    // Refund for timeouts
    if (error is TimeoutException) {
      return true;
    }

    // Refund for HTTP client exceptions
    if (error is SocketException || error is http.ClientException) {
      return true;
    }

    // Don't refund for client errors (bad image, invalid URL)
    if (error is ApiException) {
      final message = error.toString().toLowerCase();
      // Refund for 500+ errors, not for 400 errors
      return message.contains('500') ||
          message.contains('502') ||
          message.contains('503') ||
          message.contains('504') ||
          message.contains('server error');
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
      final message = error.toString().toLowerCase();
      if (message.contains('no internet') || message.contains('connection')) {
        return 'network_error';
      }
      return 'network_error';
    }

    if (error is TimeoutException) {
      return 'request_timeout';
    }

    if (error is SocketException) {
      return 'network_error';
    }

    if (error is http.ClientException) {
      return 'network_error';
    }

    if (error is ApiException) {
      final message = error.toString().toLowerCase();
      if (message.contains('503')) return 'api_maintenance_503';
      if (message.contains('500')) return 'server_error_500';
      if (message.contains('502')) return 'bad_gateway_502';
      if (message.contains('504')) return 'gateway_timeout_504';
      return 'server_error_500';
    }

    return 'unknown_error';
  }

  /// Refund credit for failed search
  Future<void> _refundCredit(String searchId, String reason) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      if (kDebugMode) {
        print('🔄 [IMAGE] Refunding credit. Reason: $reason');
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
            '✅ [IMAGE] Credit refunded. New balance: ${response['credits']}',
          );
        } else {
          print('❌ [IMAGE] Refund failed: ${response['error']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [IMAGE] Refund request failed: $e');
      }
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
}

// InsufficientCreditsException is imported from search_service.dart
