import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_record.dart';

// === Manajemen State Riwayat Pemesanan ===

class HistoryProvider extends ChangeNotifier {
  static const _kKey = kHistoryKey;

  final List<BookingRecord> _history = [];

  // === Enkapsulasi Data ===
  // Mencegah komponen UI (Layar) memanipulasi data riwayat secara ilegal/langsung tanpa melalui fungsi resmi di Provider ini.
  UnmodifiableListView<BookingRecord> get history =>
      UnmodifiableListView(_history);

  // === Parsing JSON dengan Isolate ===
  // Mencegah aplikasi menjadi 'lag', patah-patah, atau 'freeze'
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

  // === Riwayat & Persistensi ===
  // Memasukkan transaksi yang baru berhasil dibayar ke dalam daftar dan menyimpannya secara permanen ke penyimpanan lokal.
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

  Future<void> addPayment(BookingRecord record) async => addBooking(record);
}

// === Background Task Parser ===
// Fungsi murni (Top-Level Function) yang berdiri sendiri secara statis
List<dynamic> _parseJsonList(String raw) {
  return jsonDecode(raw) as List<dynamic>;
}
