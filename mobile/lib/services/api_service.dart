import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  final http.Client _client = http.Client();

  Map<String, String> _getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // 1. Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'Flutter Mobile App',
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Login successful',
          data: body['data'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Invalid email or password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: $e\nEnsure the backend server is running.',
        statusCode: 500,
      );
    }
  }

  // 2. Register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String role = 'customer',
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'role': role,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Registration successful',
          data: body['data'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Validation error during registration',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
        statusCode: 500,
      );
    }
  }

  // 3. Get Current User (/auth/me)
  Future<ApiResponse<UserModel>> getCurrentUser(String token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meEndpoint}');
      final response = await _client.get(
        url,
        headers: _getHeaders(token),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Profile retrieved',
          data: UserModel.fromJson(body['data']['user']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Session expired',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
        statusCode: 500,
      );
    }
  }

  // 4. Logout
  Future<void> logout(String token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}');
      await _client.post(
        url,
        headers: _getHeaders(token),
      );
    } catch (_) {}
  }

  // 5. Get General System Settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.settingsEndpoint}');
      final response = await _client.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'] ?? {};
        }
      }
    } catch (_) {}
    return {};
  }
}
