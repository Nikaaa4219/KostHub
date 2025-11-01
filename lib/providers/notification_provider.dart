// File: lib/providers/notification_provider.dart
// Deskripsi: Provider stub untuk jumlah notifikasi belum dibaca.
// See TODOs.md for steps to wire real notification sources (push, polling, etc.)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/payment_utils.dart';

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
    // Keep a debug log so the event is visible during development.
    // Note: integrate `flutter_local_notifications` (or another platform plugin)
    // to trigger real local notifications in the future when needed.
    debugPrint('Payment notification added: ${record.id}');
  }

  Future<void> loadNotifications() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(kNotificationsKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
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
