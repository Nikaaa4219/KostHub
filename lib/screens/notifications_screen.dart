// File: lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final DateTime date = timestamp.toDate();
    return DateFormat('dd MMM HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userEmail = authProvider.user?.email;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: userEmail == null
            ? const Center(
                child: Text("Please login first",
                    style: TextStyle(color: Colors.white)))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: userEmail)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF5D5CFF)));
                  }

                  final allDocs = snapshot.data?.docs ?? [];

                  // FILTER: HANYA TAMPILKAN YANG SUCCESS ATAU FAILED
                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? '';
                    return status == 'SUCCESS' || status == 'FAILED';
                  }).toList();

                  // JIKA KOSONG
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 64,
                              // PERBAIKAN 1: Ganti withOpacity -> withValues(alpha: ...)
                              color: Colors.white.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada notifikasi baru',
                            style: GoogleFonts.inter(
                                color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final data = docs[i].data() as Map<String, dynamic>;

                      final String hotelName = data['hotelName'] ?? 'Hotel';
                      final String status = data['status'] ?? 'FAILED';
                      final Timestamp? createdAt = data['createdAt'];

                      String title = "Payment Failed";
                      String message =
                          "Pembayaran untuk $hotelName gagal/dibatalkan.";
                      IconData iconData = Icons.cancel;
                      Color iconColor = Colors.red;

                      if (status == 'SUCCESS') {
                        title = "Payment Successful";
                        message =
                            "Pembayaran $hotelName berhasil! Selamat menginap.";
                        iconData = Icons.check_circle;
                        iconColor = Colors.green;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2029),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              // PERBAIKAN 2: Ganti withOpacity -> withValues(alpha: ...)
                              Border.all(
                                  color: Colors.white.withValues(alpha: 0.05)),
                          boxShadow: [
                            BoxShadow(
                              // PERBAIKAN 3: Ganti withOpacity -> withValues(alpha: ...)
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              // PERBAIKAN 4: Ganti withOpacity -> withValues(alpha: ...)
                              color: iconColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconData, color: iconColor, size: 24),
                          ),
                          title: Text(
                            title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                message,
                                style: GoogleFonts.inter(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTimestamp(createdAt),
                                style: GoogleFonts.inter(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
