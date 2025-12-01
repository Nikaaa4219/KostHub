// File: lib/providers/notification_provider.dart
// Deskripsi: Provider stub untuk jumlah notifikasi belum dibaca.
// See TODOs.md for steps to wire real notification sources (push, polling, etc.)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking_record.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  final List<Map<String, dynamic>> _items = []; // persisted notifications

  int get unreadCount => _unreadCount;

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  Future<void> _persist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(kNotificationsKey, jsonEncode(_items));
    } catch (e) {
      debugPrint('Persist notification failed: $e');
    }
  }

  Future<void> addPaymentNotification(BookingRecord record) async {
    final map = record.toJson();
    _items.insert(0, map);
    _unreadCount += 1;
    await _persist();
    notifyListeners();
    debugPrint('Payment notification added: ${record.id}');
  }

  /// Simpler generic API used by ATM flow: adds a short notification entry.
  Future<void> addNotification(String title, String body) async {
    try {
      final map = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _items.insert(0, map);
      _unreadCount += 1;
      await _persist();
      notifyListeners();
      debugPrint('Notification added: $title');
    } catch (e) {
      debugPrint('Failed to add notification: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(kNotificationsKey);
      if (raw == null || raw.isEmpty) return;
      // Parse JSON in a background isolate to avoid blocking the UI thread.
      final List<dynamic> list = await compute(_decodeJsonList, raw);
      _items.clear();
      for (final e in list) {
        _items.add(Map<String, dynamic>.from(e as Map));
      }
      _unreadCount = _items.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Load notifications failed: $e');
    }
  }

  void clear() {
    _unreadCount = 0;
    notifyListeners();
  }
}

// Top-level helper for compute() — must be a top-level function (not a
// class instance method) so it can be run in a background isolate.
List<dynamic> _decodeJsonList(String raw) {
  return jsonDecode(raw) as List<dynamic>;
}
