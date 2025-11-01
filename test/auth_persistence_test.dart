import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/providers/auth_provider.dart';
import 'package:flutter_application_2/models/user.dart';

void main() {
  test(
    'AuthProvider persists user profile to SharedPreferences and clears it',
    () async {
      SharedPreferences.setMockInitialValues({});

      final provider = await AuthProvider.loadSavedAuth();

      final user = User(name: 'alice', email: 'alice@example.com');

      // Call setUser without token to avoid touching secure storage in this unit test.
      await provider.setUser(user);

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('auth_user_v1');
      expect(stored, isNotNull);

      final decoded = jsonDecode(stored!) as Map<String, dynamic>;
      expect(decoded['email'], 'alice@example.com');

      // Clear and ensure removed
      await provider.clearUser();
      final after = prefs.getString('auth_user_v1');
      expect(after, isNull);
    },
  );
}
