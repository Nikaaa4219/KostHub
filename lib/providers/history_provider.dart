// Auto-generated per user prompt — manual review required
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/payment_utils.dart';

class HistoryProvider extends ChangeNotifier {
  static const _kKey = kHistoryKey;

  final List<BookingRecord> _history = [];

  UnmodifiableListView<BookingRecord> get history =>
      UnmodifiableListView(_history);

  Future<void> loadHistory() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_kKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      _history.clear();
      for (final e in list) {
        _history.add(
          BookingRecord.fromJson(Map<String, dynamic>.from(e as Map)),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  Future<void> addBooking(BookingRecord record) async {
    try {
      _history.insert(0, record);
      final sp = await SharedPreferences.getInstance();
      final raw = jsonEncode(_history.map((e) => e.toJson()).toList());
      await sp.setString(_kKey, raw);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to persist booking: $e');
    }
  }
}
