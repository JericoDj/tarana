import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

/// REST API service for Cloud Functions communication
class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl})
    : baseUrl = baseUrl ?? AppConstants.functionsBaseUrl;

  /// Get auth token for authenticated requests
  Future<String?> _getAuthToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  /// Build headers with auth token
  Future<Map<String, String>> _headers() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final error = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {'message': 'Request failed'};

    throw ApiException(
      statusCode: response.statusCode,
      message: error['message'] ?? 'Unknown error',
    );
  }
}

/// Custom API exception
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
