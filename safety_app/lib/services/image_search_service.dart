import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/image_search_result.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'search_service.dart' show InsufficientCreditsException;

/// Service for performing reverse image searches via TinEye API
///
/// **IMPORTANT**: Credit deduction handled by backend (single source of truth)
/// Backend manages all credit operations, refunds, and search history
///
/// Handles:
/// - Image upload to backend
/// - URL-based image search
/// - Error handling and user feedback
class ImageSearchService {
  // Production backend URL (same as name search)
  static const String _baseUrl = 'https://pink-flag-api.fly.dev/api';

  final _supabase = Supabase.instance.client;  // Only used for JWT token
  final _authService = AuthService();

  /// Search by image file (from camera or gallery)
  ///
  /// **IMPORTANT**: Credit deduction now handled by backend (single source of truth)
  /// Backend manages credit validation, deduction, refunds, and search history
  ///
  /// Uploads the image to the backend which then queries TinEye.
  /// Backend deducts credits automatically (4 credits per image search).
  Future<ImageSearchResult> searchByImage(File imageFile) async {
    // 1. Check authentication
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    try {
      // 2. Backend handles credit deduction automatically
      final searchResult = await _uploadAndSearch(imageFile);

      return searchResult;
    } catch (e) {
      // Backend handles refunds automatically
      if (e is InsufficientCreditsException) rethrow;
      if (e is ApiException) rethrow;
      if (e is NetworkException) rethrow;
      rethrow;
    }
  }

  /// Search by image URL
  ///
  /// **IMPORTANT**: Credit deduction now handled by backend (single source of truth)
  /// Backend manages credit validation, deduction, refunds, and search history
  ///
  /// Sends the URL to the backend which fetches and searches the image.
  /// Backend deducts credits automatically (4 credits per image search).
  Future<ImageSearchResult> searchByUrl(String imageUrl) async {
    // 1. Check authentication
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    try {
      // 2. Backend handles credit deduction automatically
      final searchResult = await _searchByUrlRequest(imageUrl);

      return searchResult;
    } catch (e) {
      // Backend handles refunds automatically
      if (e is InsufficientCreditsException) rethrow;
      if (e is ApiException) rethrow;
      if (e is NetworkException) rethrow;
      rethrow;
    }
  }

  /// Upload image file and perform search
  Future<ImageSearchResult> _uploadAndSearch(File imageFile) async {
    try {
      // Get JWT token from Supabase session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw ApiException('Not authenticated. Please sign in again.');
      }

      final uri = Uri.parse('$_baseUrl/image-search');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add authentication header
      request.headers['Authorization'] = 'Bearer ${session.accessToken}';

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
      // Get JWT token from Supabase session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw ApiException('Not authenticated. Please sign in again.');
      }

      final uri = Uri.parse('$_baseUrl/image-search');

      // Send as form data with URL
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'Bearer ${session.accessToken}',
            },
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
