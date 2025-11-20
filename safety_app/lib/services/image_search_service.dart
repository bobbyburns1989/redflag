import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  Future<ImageSearchResult> searchByImage(File imageFile) async {
    // 1. Check authentication
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    final userId = _authService.currentUser!.id;
    final fileName = imageFile.path.split('/').last;
    final query = 'IMAGE_SEARCH: $fileName';

    // 2. Deduct credit via Supabase RPC
    try {
      final response = await _supabase.rpc('deduct_credit_for_search', params: {
        'p_user_id': userId,
        'p_query': query,
        'p_results_count': 0,
      });

      if (response['success'] == false) {
        if (response['error'] == 'insufficient_credits') {
          throw InsufficientCreditsException(response['credits'] as int);
        }
        throw Exception('Failed to deduct credit: ${response['error']}');
      }

      // 3. Perform the image search
      final searchResult = await _uploadAndSearch(imageFile);

      // 4. Update search record with results count (best effort)
      try {
        final searchId = response['search_id'];
        if (searchId != null) {
          await _supabase.from('searches').update({
            'results_count': searchResult.totalMatches,
          }).eq('id', searchId);
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
  Future<ImageSearchResult> searchByUrl(String imageUrl) async {
    // 1. Check authentication
    if (!_authService.isAuthenticated) {
      throw Exception('You must be logged in to search');
    }

    final userId = _authService.currentUser!.id;
    final query = 'IMAGE_SEARCH: $imageUrl';

    // 2. Deduct credit via Supabase RPC
    try {
      final response = await _supabase.rpc('deduct_credit_for_search', params: {
        'p_user_id': userId,
        'p_query': query,
        'p_results_count': 0,
      });

      if (response['success'] == false) {
        if (response['error'] == 'insufficient_credits') {
          throw InsufficientCreditsException(response['credits'] as int);
        }
        throw Exception('Failed to deduct credit: ${response['error']}');
      }

      // 3. Perform the URL search
      final searchResult = await _searchByUrlRequest(imageUrl);

      // 4. Update search record with results count
      try {
        final searchId = response['search_id'];
        if (searchId != null) {
          await _supabase.from('searches').update({
            'results_count': searchResult.totalMatches,
          }).eq('id', searchId);
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

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Image upload may take longer
        onTimeout: () => throw TimeoutException(
          'Image search timed out. Please try again.',
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
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error. Please try again later.');
      } else {
        throw ApiException('Image search failed. Please try again.');
      }
    } on SocketException {
      throw NetworkException(
        'No internet connection. Please check your network settings.',
      );
    } on TimeoutException {
      rethrow;
    } on ServerException {
      rethrow;
    } on http.ClientException catch (e) {
      throw NetworkException('Connection failed: ${e.message}');
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
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'image_url': imageUrl},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'Image search timed out. Please try again.',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ImageSearchResult.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ApiException(error['detail'] ?? 'Invalid image URL');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error. Please try again later.');
      } else {
        throw ApiException('Image search failed. Please try again.');
      }
    } on SocketException {
      throw NetworkException(
        'No internet connection. Please check your network settings.',
      );
    } on TimeoutException {
      rethrow;
    } on ServerException {
      rethrow;
    } on http.ClientException catch (e) {
      throw NetworkException('Connection failed: ${e.message}');
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
