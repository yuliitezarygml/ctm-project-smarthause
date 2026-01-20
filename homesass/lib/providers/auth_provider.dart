import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _userName = username.contains('@') ? username.split('@')[0] : username; // Extract name from email if needed
      _userEmail = username.contains('@') ? username : '$username@example.com';
      _isAuthenticated = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', _userName!);
      await prefs.setString('userEmail', _userEmail!);
      await prefs.setString('userId', _userId!);
      await prefs.setString('authToken', _authToken!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _authToken = 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
      _userId = 'user_${email.hashCode}';
      _userName = name;
      _userEmail = email;
      _isAuthenticated = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', _userName!);
      await prefs.setString('userEmail', _userEmail!);
      await prefs.setString('userId', _userId!);
      await prefs.setString('authToken', _authToken!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateProfile(String name, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (name.isNotEmpty && email.isNotEmpty) {
      _userName = name;
      _userEmail = email;
      
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userName!);
      await prefs.setString('userEmail', _userEmail!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, verify currentPassword matches backend
    if (newPassword.length >= 6) {
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

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Or remove specific keys
    
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('isLoggedIn')) {
      return false;
    }

    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    
    if (_isAuthenticated) {
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      _userId = prefs.getString('userId');
      _authToken = prefs.getString('authToken');
    }
    
    notifyListeners();
    return _isAuthenticated;
  }
}

