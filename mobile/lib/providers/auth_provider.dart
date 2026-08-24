import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _systemSettings = {};

  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get systemSettings => _systemSettings;

  // Initialize and check persisted token
  Future<bool> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    final userJson = prefs.getString('user_data');

    // Fetch system branding settings (app name, logo)
    _systemSettings = await _apiService.getSettings();

    if (_token != null && userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        notifyListeners();
        return true;
      } catch (_) {
        await logout();
      }
    }
    notifyListeners();
    return false;
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiService.login(email: email, password: password);
    _isLoading = false;

    if (response.success && response.data != null) {
      _token = response.data!['access_token'];
      _currentUser = UserModel.fromJson(response.data!['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _token!);
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String role = 'customer',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
      role: role,
    );
    _isLoading = false;

    if (response.success && response.data != null) {
      _token = response.data!['access_token'];
      _currentUser = UserModel.fromJson(response.data!['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _token!);
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    if (_token != null) {
      await _apiService.logout(_token!);
    }
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
