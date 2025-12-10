import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

// -- FIREBASE IMPORTS --
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginResult {
  final Map<String, dynamic> user;
  final String token;

  LoginResult({required this.user, required this.token});
}

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// FUNGSI BARU: Login menggunakan Akun Google
  Future<LoginResult?> loginWithGoogle() async {
    try {
      // 1. Pemicu Popup Google di HP User
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Batal

      // 2. Ambil token otentikasi dari akun Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Buat kredensial untuk dikirim ke Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Masuk ke Firebase menggunakan kredensial tersebut
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 5. Sukses! Ambil data user
        final token = await firebaseUser.getIdToken() ?? 'firebase_token';

        // Ambil nama & foto asli dari akun Google
        final userMap = {
          'email': firebaseUser.email ?? '',
          'name': firebaseUser.displayName ?? 'User',
          'photoUrl': firebaseUser.photoURL,
        };

        // Simpan ke storage lokal agar aplikasi tahu kita sudah login
        await SecureStorageService.instance.write('auth_token', token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_v1', jsonEncode(userMap));

        return LoginResult(user: userMap, token: token);
      }
      return null;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  /// Login Manual (Tetap ada sebagai cadangan)
  Future<LoginResult?> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      if (email.contains('@') && password.length >= 6) {
        final token = 'token_dummy_${email.hashCode}';
        final user = {'email': email, 'name': email.split('@').first};

        await SecureStorageService.instance.write('auth_token', token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_v1', jsonEncode(user));
        return LoginResult(user: user, token: token);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logout: Keluar dari Firebase & Google
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      await SecureStorageService.instance.delete('auth_token');
      await SecureStorageService.instance.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user_v1');
    } catch (_) {}
  }

  Future<String?> getToken() async {
    return await SecureStorageService.instance.read('auth_token');
  }
}
