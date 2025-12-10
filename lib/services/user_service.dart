// Auto-generated — manual review required
// File: lib/services/user_service.dart
// Service for user-related operations (profile update etc.).
// By default this file provides a local stubbed implementation but also
// supports making a real HTTP call when `updateEndpoint` is configured.
// Auto-generated — manual review required
// File: lib/services/user_service.dart
// Service for user-related operations (profile update etc.).
// By default this file provides a local stubbed implementation but also
// supports making a real HTTP call when `updateEndpoint` is configured.

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'storage.dart';

/// Optional endpoint for profile update. If empty, the service uses a local
/// delayed stub (suitable for offline/dev). Set this to an API URL to enable
/// real network calls (e.g. in production or during manual testing).
String updateEndpoint = '';

class UserService {
  UserService._();

  /// Update user profile.
  ///
  /// If [updateEndpoint] is configured (non-empty), this will POST JSON to
  /// that endpoint and attempt to parse an updated user from the response.
  /// Otherwise it falls back to a simulated delay and returns the passed user.
  static Future<User> updateProfile(User user) async {
    if (updateEndpoint.isEmpty) {
      // Local stub: simulate latency and return the user unchanged.
      await Future.delayed(const Duration(milliseconds: 700));
      return user;
    }

    final uri = Uri.parse(updateEndpoint);
    // Try to include Authorization header if token is stored in secure storage.
    const storage = FlutterSecureStorageAdapter();
    String? token;
    try {
      final s = await storage.read(UserService._storageKey);
      if (s != null) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        token = m['token']?.toString();
      }
    } catch (_) {
      token = null;
    }

    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(user.toMap()),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      try {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        return User.fromMap(decoded);
      } catch (e) {
        throw Exception('Failed to parse update response: $e');
      }
    }

    throw Exception('Update failed: ${resp.statusCode} ${resp.body}');
  }

  /// Fetch profile for a token. If `updateEndpoint` is empty, return a
  /// simulated user. Real implementation should call a profile endpoint.
  static Future<User> fetchProfile(String token) async {
    if (updateEndpoint.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
      return User(name: 'User', email: 'user@example.com');
    }

    // If an endpoint is configured, attempt a GET with Authorization header.
    final uri = Uri.parse(updateEndpoint);
    const storage = FlutterSecureStorageAdapter();
    String? saved;
    try {
      saved = await storage.read(_storageKey);
    } catch (_) {
      saved = null;
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    final tokenHeader = token.isNotEmpty ? token : (saved ?? '');
    if (tokenHeader.isNotEmpty) {
      headers['Authorization'] = 'Bearer $tokenHeader';
    }

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      return User.fromMap(decoded);
    }

    throw Exception('Fetch profile failed: ${resp.statusCode}');
  }

  static const String _storageKey = 'auth_user_v1';
}

/// Top-level function pointer to allow tests to override the implementation.
/// By default it points to [UserService.updateProfile]. Tests can replace this
/// with a mock function.
Future<User> Function(User) updateProfileFn = UserService.updateProfile;
