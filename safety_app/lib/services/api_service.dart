import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offender.dart';
import '../models/search_result.dart';

class ApiService {
  // Default to localhost for development
  // In production, this should be loaded from environment variables
  static const String _baseUrl = 'http://localhost:8000/api';

  /// Search for offenders by name
  Future<SearchResult> searchByName({
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? zipCode,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/search/name');

      final requestBody = {
        'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
        if (zipCode != null && zipCode.isNotEmpty) 'zipCode': zipCode,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw ApiException('Request timed out'),
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
      } else {
        throw ApiException(
          'Search failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Test API connectivity
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/search/test');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('http://localhost:8000/health');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5));

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
