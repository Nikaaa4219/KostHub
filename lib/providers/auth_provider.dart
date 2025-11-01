// AuthProvider: manages in-memory auth state and persistence.
// Persists non-sensitive user profile in SharedPreferences and stores token
// securely using SecureStorageService.
// Generated to ensure token is loaded before app start and writes are awaited.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/secure_storage_service.dart';
import '../services/migration_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _kUserKey = 'auth_user_v1';
  static const String _kTokenKey = 'auth_token';

  User? _user;
  String? _token;

  AuthProvider._();

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Persist a user and optional token. User profile is stored in
  /// SharedPreferences (non-sensitive). Token is stored in secure storage.
  Future<void> setUser(User user, {String? token}) async {
    _user = user;
    if (token != null) {
      _token = token;
      await SecureStorageService.instance.write(_kTokenKey, token);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserKey, jsonEncode(user.toMap()));
    } catch (_) {
      // ignore write failures but keep in-memory state
    }
    notifyListeners();
  }

  /// Clear user and token from storage and memory
  Future<void> clearUser() async {
    _user = null;
    _token = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kUserKey);
    } catch (_) {}
    try {
      await SecureStorageService.instance.delete(_kTokenKey);
    } catch (_) {}
  }

  /// Load saved auth state. Runs migration first. Returns an instance
  /// of AuthProvider with state loaded (may be logged out if no token found).
  static Future<AuthProvider> loadSavedAuth() async {
    final provider = AuthProvider._();
    try {
      // migrate legacy token if any
      await MigrationService.migrateAuthTokenIfNeeded();

      final token = await SecureStorageService.instance.read(_kTokenKey);
      if (token == null) {
        return provider; // not logged in
      }
      provider._token = token;

      // try to load cached user profile
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_kUserKey);
        if (raw != null) {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          provider._user = User.fromMap(m);
        } else {
          // Try to retrieve profile from backend if token exists.
          try {
            final fetchedMap = await _fetchProfileForToken(token);
            if (fetchedMap != null) {
              provider._user = User.fromMap(fetchedMap);
            }
          } catch (_) {
            // leave user null; token exists but fetch failed
          }
        }
      } catch (_) {
        // ignore, leave user null
      }
    } catch (_) {
      // any failure results in logged-out provider
    }
    return provider;
  }
}

/// Helper used to fetch profile map for a token. Separated to avoid import
/// ordering issues in the main loadSavedAuth flow.
Future<Map<String, dynamic>?> _fetchProfileForToken(String token) async {
  try {
    final u = await UserService.fetchProfile(token);
    return u.toMap();
  } catch (_) {
    return null;
  }
}
