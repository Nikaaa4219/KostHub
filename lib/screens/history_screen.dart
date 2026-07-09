// File: lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'receipt_screen.dart'; // Pastikan file ini sudah ada!

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String formatCurrency(num amount) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  String formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userEmail = authProvider.user?.email;

    if (userEmail == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0C10),
        body: Center(
            child: Text("Please login first",
                style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                'Riwayat Booking',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: userEmail)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada riwayat booking',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      // Ambil data lengkap dari Firestore
                      final data = docs[i].data() as Map<String, dynamic>;

                      final String roomName =
                          data['hotelName'] ?? 'Unknown Hotel';
                      final num total = data['totalPrice'] ?? 0;
                      final String status = data['status'] ?? 'SUCCESS';
                      final String startDate = data['startDate'];
                      final String endDate = data['endDate'];
                      final String orderId = data['orderId'] ?? '-';

                      // Tentukan Warna Status
                      Color statusColor = Colors.orange;
                      if (status == 'SUCCESS') statusColor = Colors.green;
                      if (status == 'FAILED') statusColor = Colors.red;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2029),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          // Icon Hotel
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D5CFF)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.hotel,
                                color: Color(0xFF5D5CFF)),
                          ),
                          // Judul & Badge Status
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  roomName,
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          // Detail Tanggal & Harga
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${formatDate(startDate)} - ${formatDate(endDate)}',
                                  style: GoogleFonts.inter(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: $orderId',
                                  style: GoogleFonts.inter(
                                      color: Colors.white38, fontSize: 10),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(total),
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          // AKSI SAAT DITEKAN: Buka ReceiptScreen
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Kirim seluruh data booking ke ReceiptScreen
                                builder: (context) => ReceiptScreen(data: data),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
