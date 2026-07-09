// File: lib/screens/confirm_pay_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import '../utils/booking_utils.dart';
import 'add_card_screen.dart';

class ConfirmPayScreen extends StatefulWidget {
  final Room room;
  final MonthsSelection months;
  final GuestSelection guests;

  const ConfirmPayScreen({
    super.key,
    required this.room,
    required this.months,
    required this.guests,
  });

  @override
  State<ConfirmPayScreen> createState() => _ConfirmPayScreenState();
}

class _ConfirmPayScreenState extends State<ConfirmPayScreen> {
  bool _isProcessing = false;

  final List<String> _availableRooms = [
    'Room A-101 (Lantai 1)',
    'Room A-102 (Lantai 1)',
    'Room B-201 (Lantai 2)',
    'Room B-205 (Lantai 2 - View Taman)',
    'Room C-301 (Lantai 3 - VIP)',
  ];
  String? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = _availableRooms.first;
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0C10);
    const surface = Color(0xFF1F2029);
    const accent = Color(0xFF5D5CFF);

    // Memanggil Kalkulator Pintar dari booking_utils.dart
    final breakdown = calculatePriceBreakdown(
      monthlyPrice: 2500000,
      months: widget.months.monthsCount,
      adults: widget.guests.adults,
      children: widget.guests.children,
      selectedRoom: _selectedRoom ?? '',
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Confirm & Pay",
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER HOTEL CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(widget.room.assetImage,
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.room.name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.room.location,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text("Kost/Apartment",
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: accent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- PILIHAN KAMAR ---
            Text("Select Room Unit",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRoom,
                  dropdownColor: surface,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: accent),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  onChanged: (val) => setState(() => _selectedRoom = val),
                  items: _availableRooms
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- BOOKING DETAILS ---
            Text("Booking Details",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _detailRow("Dates",
                      "${DateFormat('dd MMM').format(widget.months.startDate)} - ${DateFormat('dd MMM').format(widget.months.endDate)}"),
                  const Divider(color: Colors.white12, height: 24),
                  _detailRow(
                      "Duration", "${widget.months.monthsCount} Month(s)"),
                  const Divider(color: Colors.white12, height: 24),
                  _detailRow(
                      "Guests", "${widget.guests.totalGuests} Person(s)"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- PAYMENT BREAKDOWN (DYNAMIC) ---
            Text("Payment Breakdown",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _priceRow("Base Price (x${widget.months.monthsCount} Mo)",
                      formatCurrency(breakdown.basePrice)),

                  // Menampilkan biaya Room Type jika pengguna memilih View/VIP
                  if (breakdown.luxurySurcharge > 0)
                    _priceRow("Room Surcharge (VIP/View)",
                        "+ ${formatCurrency(breakdown.luxurySurcharge)}",
                        color: Colors.tealAccent),

                  // Menampilkan biaya Tamu jika pengguna membawa >2 orang
                  if (breakdown.guestSurcharge > 0)
                    _priceRow("Extra Guest Surcharge",
                        "+ ${formatCurrency(breakdown.guestSurcharge)}",
                        color: Colors.orangeAccent),

                  _priceRow("Platform Fee", formatCurrency(breakdown.fees)),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white24, thickness: 1),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Grand Total",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(formatCurrency(breakdown.grandTotal),
                          style: GoogleFonts.inter(
                              color: accent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- BUTTON PAY ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddCardScreen(
                                      total: breakdown
                                          .grandTotal, // Total yang ter-update
                                      room: widget.room,
                                      months: widget.months,
                                      guests: widget.guests,
                                      selectedRoomDetail:
                                          _selectedRoom ?? "Standard Room",
                                    )));
                        setState(() => _isProcessing = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  shadowColor: accent.withValues(alpha: 0.4),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Pay Now",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white54)),
        Text(val,
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _priceRow(String label, String val, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: color ?? Colors.white70)),
          Text(val, style: GoogleFonts.inter(color: color ?? Colors.white)),
        ],
      ),
    );
  }
}
