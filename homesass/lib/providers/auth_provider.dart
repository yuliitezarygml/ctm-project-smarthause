import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _authToken;
  String? _userId;
  String? _userName;
  String? _userEmail;
  bool _isAuthenticated = false;

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In real app, this would be an actual API call
    if (username.isNotEmpty && password.isNotEmpty) {
      _authToken = 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
      _userId = 'user_${username.hashCode}';
      _userName = username;
      _userEmail = '${username.toLowerCase()}@example.com';
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _authToken = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    // Simulate checking stored credentials
    await Future.delayed(const Duration(seconds: 1));

    // Set default user data if not authenticated
    if (!_isAuthenticated) {
      _userName = 'User';
      _userEmail = 'user@example.com';
    }

    return _isAuthenticated;
  }
}
