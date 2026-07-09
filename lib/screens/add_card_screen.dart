// File: lib/screens/add_card_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../providers/auth_provider.dart';
import 'payment_webview_screen.dart';
import 'receipt_screen.dart';

class AddCardScreen extends StatefulWidget {
  final int total;
  final Room room;
  final MonthsSelection months;
  final GuestSelection guests;
  final String selectedRoomDetail;

  const AddCardScreen({
    super.key,
    required this.total,
    required this.room,
    required this.months,
    required this.guests,
    required this.selectedRoomDetail,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  // HAPUS VARIABLE _isLoading AGAR TIDAK ADA WARNING

  // URL ini mengarah ke peladen Vercel Anda yang baru saja selesai di-deploy
  final String _serverUrl = 'https://vercel-psi-six-20.vercel.app/api/index';

  // === CHECKOUT ===
  // === API CALL ===
  // Mengirim data pesanan ke backend Vercel untuk meminta token pembayaran Midtrans
  Future<void> _processPayment() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login required')),
        );
      }
      return;
    }

    final String orderId = "ORDER-${DateTime.now().millisecondsSinceEpoch}";

    try {
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

        // === API CALL ===
        // Menyimpan status awal transaksi (PENDING) ke Firebase Firestore
        // 1. Simpan Status Awal PENDING
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(orderId)
            .set({
          'orderId': orderId,
          'userId': user.email,
          'hotelId': widget.room.id,
          'hotelName': widget.room.name,
          'location': widget.room.location,
          'roomDetail': widget.selectedRoomDetail,
          'startDate': widget.months.startDate.toIso8601String(),
          'endDate': widget.months.endDate.toIso8601String(),
          'monthsCount': widget.months.monthsCount,
          'totalGuests': widget.guests.totalGuests,
          'totalPrice': widget.total,
          'status': 'PENDING',
          'paymentUrl': redirectUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'paymentMethod': 'Midtrans',
        });

        if (!mounted) return;

        // === NAVIGATION ===
        // Membuka layar WebView Midtrans dan menunggu (await) hasilnya
        // 2. Buka Webview & TUNGGU HASIL Laporannya
        final webviewResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebviewScreen(url: redirectUrl),
          ),
        );

        // 3. Olah Hasil Laporan
        String finalStatus = 'PENDING';
        if (webviewResult == 'success') {
          finalStatus = 'SUCCESS';
        } else if (webviewResult == 'failed') {
          finalStatus = 'FAILED';
        }

        // === API CALL ===
        // Memperbarui status transaksi di Firestore berdasarkan respons dari Midtrans
        // 4. Update Database Firebase dengan Status Baru
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(orderId)
            .update({'status': finalStatus});

        if (!mounted) return;

        // 5. Susun Data untuk Struk (Receipt)
        final receiptData = {
          'orderId': orderId,
          'hotelName': widget.room.name,
          'roomDetail': widget.selectedRoomDetail,
          'totalPrice': widget.total,
          'status': finalStatus,
          'totalGuests': widget.guests.totalGuests,
          'monthsCount': widget.months.monthsCount,
          'startDate': widget.months.startDate.toIso8601String(),
          'endDate': widget.months.endDate.toIso8601String(),
        };

        // === NAVIGATION ===
        // Mengarahkan pengguna ke layar Struk (Receipt) atau kembali ke awal jika gagal
        // 6. Tampilkan Layar Receipt dan hapus riwayat tumpukan halaman sebelumnya
        if (finalStatus == 'SUCCESS') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptScreen(data: receiptData),
            ),
            (route) => route.isFirst,
          );
        } else if (finalStatus == 'FAILED') {
          Navigator.popUntil(context, (route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Pembayaran Gagal atau Dibatalkan'),
                backgroundColor: Colors.red),
          );
        } else {
          // Jika layar ditutup paksa (Pending)
          Navigator.popUntil(context, (route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Menunggu Pembayaran Diselesaikan...')),
          );
        }
      } else {
        throw Exception("Server Error: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyambung ke gateway: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF5D5CFF)),
            const SizedBox(height: 20),
            Text("Connecting to Payment Gateway...",
                style: GoogleFonts.inter(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
