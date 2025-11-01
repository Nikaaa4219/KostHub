import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

/// Result of a login attempt. NOTE: this is a stubbed model used for
/// development; replace with your real API model when integrating backend.
class LoginResult {
  final Map<String, dynamic> user;
  final String token;

  LoginResult({required this.user, required this.token});
}

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  /// Simulate login, store token into secure storage and return LoginResult.
  /// NOTE: this method is a local stub. Replace with a real API call and
  /// proper error handling when you have a backend.
  Future<LoginResult?> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      if (email.contains('@') && password.length >= 6) {
        final token =
            'token_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';
        final user = {'email': email, 'name': email.split('@').first};
        // persist token securely
        await SecureStorageService.instance.write('auth_token', token);
        // optionally persist minimal user to shared prefs (JSON encoded)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_v1', jsonEncode(user));
        return LoginResult(user: user, token: token);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logout: remove token from secure storage and clear anything sensitive.
  Future<void> logout() async {
    try {
      await SecureStorageService.instance.delete('auth_token');
      await SecureStorageService.instance.deleteAll();
      // optionally remove any stored minimal user
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user_v1');
    } catch (_) {
      // let caller continue; logout should not crash the app
    }
  }

  /// Read token from secure storage
  Future<String?> getToken() async {
    return await SecureStorageService.instance.read('auth_token');
  }
}
