import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_record.dart';

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
      final List<dynamic> list = await compute(_parseJsonList, raw);
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

  // NOTE: compute() requires a top-level or static function. The actual
  // implementation lives at file-level below the class.

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

  /// Alias for the newer naming used in payment flow.
  Future<void> addPayment(BookingRecord record) async => addBooking(record);
}

// Top-level helper for compute() — must be a top-level function (not a
// class instance method) so it can be run in a background isolate.
List<dynamic> _parseJsonList(String raw) {
  return jsonDecode(raw) as List<dynamic>;
}
