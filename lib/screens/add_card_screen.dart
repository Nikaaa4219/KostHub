// File: lib/screens/add_card_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Import file-file Anda
import '../models/room.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../providers/auth_provider.dart';
import 'payment_webview_screen.dart'; // Pastikan file ini sudah ada!

class AddCardScreen extends StatefulWidget {
  final int total;
  final Room room;
  final MonthsSelection months;
  final GuestSelection guests;

  const AddCardScreen({
    super.key,
    required this.total,
    required this.room,
    required this.months,
    required this.guests,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  bool _isLoading = false;

  // Link Vercel Anda (Sesuai perbaikan terakhir)
  final String _serverUrl =
      'https://kosthub-server-fwlnm3pv0-condorianos-projects.vercel.app/api/index';

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    // 1. Ambil data User
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User tidak ditemukan. Login ulang.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // 2. Buat Order ID Unik
    final String orderId = "ORDER-${DateTime.now().millisecondsSinceEpoch}";

    try {
      // 3. Request Link ke Vercel (Midtrans Snap)
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "order_id": orderId,
          "gross_amount": widget.total,
          "customer_details": {
            "first_name": user.name.isNotEmpty ? user.name : "Guest",
            "email": user.email,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String redirectUrl = data['redirect_url'];

        // 4. Simpan ke Firebase (Status: PENDING)
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(orderId)
            .set({
          'orderId': orderId,
          'userId': user.email,
          'hotelId': widget.room.id,
          'hotelName': widget.room.name,
          'startDate': widget.months.startDate.toIso8601String(),
          'endDate': widget.months.endDate.toIso8601String(),
          'totalPrice': widget.total,
          'status': 'SUCCESS',
          'paymentUrl': redirectUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'paymentMethod': 'Midtrans',
        });

        if (!mounted) return;

        // 5. Buka Halaman WebView (Snap UI)
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebviewScreen(url: redirectUrl),
          ),
        );

        // 6. Setelah User menutup WebView, kembali ke Home
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cek status di Riwayat Booking.')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        throw Exception("Gagal: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error Payment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text("Konfirmasi Pembayaran"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Summary",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2029),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildRow("Hotel", widget.room.name),
                  const Divider(color: Colors.white24, height: 24),
                  _buildRow("Check-in",
                      "${widget.months.startDate.day}/${widget.months.startDate.month}/${widget.months.startDate.year}"),
                  const Divider(color: Colors.white24, height: 24),
                  _buildRow("Total Tagihan", "Rp ${widget.total}",
                      isBold: true),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D5CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                    : Text(
                        "Bayar Sekarang (Midtrans)",
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Helper untuk membuat baris teks (DI DALAM CLASS, DI LUAR BUILD)
  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70)),
        Text(value,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14)),
      ],
    );
  }
}
