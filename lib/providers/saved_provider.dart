// File: lib/providers/saved_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedProvider extends ChangeNotifier {
  // Key default jika user belum login
  String _currentKey = 'saved_room_ids_guest';
  final Set<String> _saved = {};

  Set<String> get savedIds => Set.unmodifiable(_saved);

  bool isSaved(String id) => _saved.contains(id);

  /// PENTING: Panggil ini saat User Login/Logout
  /// Agar data tersimpan terpisah berdasarkan email user.
  Future<void> updateUser(String? userEmail) async {
    if (userEmail != null && userEmail.isNotEmpty) {
      _currentKey = 'saved_rooms_$userEmail'; // Kunci Unik per Email
    } else {
      _currentKey = 'saved_room_ids_guest';
      _saved.clear(); // Bersihkan jika logout
    }
    await loadSaved(); // Muat ulang data sesuai user baru
  }

  Future<void> loadSaved() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_currentKey);
      _saved.clear();

      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          _saved.add(e.toString());
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleSaved(String id) async {
    try {
      if (_saved.contains(id)) {
        _saved.remove(id);
      } else {
        _saved.add(id);
      }

      final sp = await SharedPreferences.getInstance();
      await sp.setString(_currentKey, jsonEncode(_saved.toList()));
      notifyListeners();
    } catch (_) {}
  }
}
