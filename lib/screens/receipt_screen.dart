// File: lib/screens/receipt_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/booking_utils.dart'; // Untuk format currency

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReceiptScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0C10);
    const surface = Color(0xFF1F2029);
    const accent = Color(0xFF5D5CFF);
    const successColor = Color(0xFF00C853);

    // Parse Data
    final String orderId = data['orderId'] ?? '-';
    final String hotelName = data['hotelName'] ?? 'Unknown Hotel';
    final String roomDetail = data['roomDetail'] ?? 'Standard Room';
    final int price = data['totalPrice'] ?? 0;
    final String status = data['status'] ?? 'PENDING';
    final int guests = data['totalGuests'] ?? 1;
    final int months = data['monthsCount'] ?? 1;

    // Date Parsing
    final DateTime start =
        DateTime.tryParse(data['startDate'] ?? '') ?? DateTime.now();
    final DateTime end =
        DateTime.tryParse(data['endDate'] ?? '') ?? DateTime.now();
    final String dateStr =
        "${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
    final String paidAt = DateFormat('dd MMM yyyy, HH:mm')
        .format(DateTime.now()); // Atau ambil dari createdAt

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Payment Receipt",
            style: GoogleFonts.playfairDisplay(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- TICKET CARD ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // HEADER SUCCESS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: status == 'SUCCESS'
                          ? successColor.withValues(alpha: 0.1)
                          : const Color.fromARGB(255, 255, 0, 0)
                              .withValues(alpha: 0.1),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          status == 'SUCCESS'
                              ? Icons.check_circle
                              : Icons.access_time_filled,
                          color: status == 'SUCCESS'
                              ? successColor
                              : const Color.fromARGB(255, 255, 0, 0),
                          size: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          status == 'SUCCESS'
                              ? "Payment Successful"
                              : "Payment Pending",
                          style: GoogleFonts.inter(
                            color: status == 'SUCCESS'
                                ? successColor
                                : const Color.fromARGB(255, 255, 0, 0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Show this to the cashier",
                          style: GoogleFonts.inter(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT DETAILS
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            formatCurrency(price),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        _itemRow("Order ID", orderId, isBold: true),
                        _itemRow("Payment Date", paidAt),
                        _divider(),

                        _itemRow("Hotel", hotelName, isBold: true),
                        _itemRow("Room Unit", roomDetail,
                            color: accent), // Detail Kamar
                        _divider(),

                        _itemRow("Check-in / Out", dateStr),
                        _itemRow("Duration", "$months Month(s)"),
                        _itemRow("Guests", "$guests Person(s)"),

                        // Break down charges logic display
                        if (guests > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "* Includes extra guest fee (Rp 250.000)",
                              style: GoogleFonts.inter(
                                  color: Colors.orangeAccent,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        if (months > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "* Price multiplied by duration",
                              style: GoogleFonts.inter(
                                  color: Colors.white30,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),

                        const SizedBox(height: 30),

                        // Fake Barcode/QR
                        Center(
                          child: Container(
                            height: 60,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text(
                                "||| || ||| | |||| ||| || ||||",
                                style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Download Button (Dummy)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Receipt saved to Gallery (Dummy)")));
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text("Save Receipt Image",
                    style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                color: color ?? Colors.white,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
    );
  }
}
