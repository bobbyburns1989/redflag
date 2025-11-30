import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/search_result.dart';

class ApiService {
  final _supabase = Supabase.instance.client;

  // Production backend URL (deployed on Fly.io)
  // For local development, change to 'http://localhost:8000/api'
  static const String _baseUrl = 'https://pink-flag-api.fly.dev/api';

  /// Search for offenders by name
  Future<SearchResult> searchByName({
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? zipCode,
    String? age,
    String? state,
  }) async {
    try {
      // Get JWT token from Supabase session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw ApiException('Not authenticated. Please sign in again.');
      }

      final uri = Uri.parse('$_baseUrl/search/name');

      final requestBody = {
        'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
        if (zipCode != null && zipCode.isNotEmpty) 'zipCode': zipCode,
        if (age != null && age.isNotEmpty) 'age': age,
        if (state != null && state.isNotEmpty) 'state': state,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.accessToken}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              '⏱️ Request Timed Out\n\nThe search service didn\'t respond in time. Don\'t worry - your credit was automatically refunded!\n\nPlease check your internet connection and try again.',
            ),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final searchQuery = lastName != null
            ? '$firstName $lastName'
            : firstName;

        return SearchResult.fromResponse(jsonList, searchQuery);
      } else if (response.statusCode == 404) {
        // No results found
        return SearchResult(
          offenders: [],
          query: firstName,
          timestamp: DateTime.now(),
          totalResults: 0,
        );
      } else if (response.statusCode == 503) {
        throw ServerException(
          '🔧 Service Under Maintenance\n\nThe search service is temporarily down for maintenance. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few minutes.',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(
          '⚠️ Server Error\n\nThe search service is experiencing technical difficulties. Don\'t worry - your credit was automatically refunded!\n\nPlease try again in a few moments.',
        );
      } else {
        throw ApiException(
          'Search failed. Please check your connection and try again.',
        );
      }
    } on SocketException {
      throw NetworkException(
        '📡 No Internet Connection\n\nCouldn\'t connect to the search service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } on TimeoutException {
      rethrow;
    } on ServerException {
      rethrow;
    } on http.ClientException {
      throw NetworkException(
        '📡 Connection Failed\n\nCouldn\'t connect to the search service. No credit was charged.\n\nPlease check your network and try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred. Please try again.');
    }
  }

  /// Test API connectivity
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/search/test');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('https://pink-flag-api.fly.dev/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Network connectivity exception
class NetworkException extends ApiException {
  NetworkException(super.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Server error exception
class ServerException extends ApiException {
  ServerException(super.message);

  @override
  String toString() => 'ServerException: $message';
}

/// Timeout exception
class TimeoutException extends ApiException {
  TimeoutException(super.message);

  @override
  String toString() => 'TimeoutException: $message';
}
