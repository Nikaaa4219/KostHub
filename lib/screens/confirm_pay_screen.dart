// Confirm & Pay (refactored to use ATM/manual flow)
// This file implements the redesigned Confirm & Pay screen per the new
// ATM/manual payment flow. The old online payment implementation is
// deprecated and replaced by a simplified Pay Now -> ATM Payment flow.
// Note: consider replacing the manual ATM flow with a real payment gateway
// integration in the future if you add online payments.
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import 'add_card_screen.dart';

const Color primaryAccent = Color(0xFF5D5CFF);
const int monthlyPrice = 2500000;
const int taxesFees = 10000;

final _fmt = NumberFormat.currency(
  locale: 'id',
  symbol: 'Rp ',
  decimalDigits: 0,
);

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
  bool _tapLocked = false;

  int _baseSubtotal() => monthlyPrice * widget.months.monthsCount;

  int _applyGuestRule(int subtotal) {
    final totalGuests = widget.guests.totalGuests;
    if (totalGuests >= 5) return subtotal * 2;
    if (totalGuests == 4) return subtotal + 50000;
    return subtotal;
  }

  int get _grandTotal => _applyGuestRule(_baseSubtotal()) + taxesFees;

  Future<void> _onPayNow() async {
    if (_tapLocked) return;
    _tapLocked = true;
    setState(() => _isProcessing = true);
    try {
      final ctx = context;
      final navigator = Navigator.of(ctx);
      final messenger = ScaffoldMessenger.of(ctx);

      // Basic validation
      if (widget.months.monthsCount <= 0 || widget.guests.adults < 1) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal dan tamu terlebih dahulu'),
          ),
        );
        return;
      }

      // Open the ATM payment screen (repurposed AddCardScreen) and wait result
      final res = await navigator.push<bool?>(
        MaterialPageRoute(
          builder: (_) => AddCardScreen(
            total: _grandTotal,
            room: widget.room,
            months: widget.months,
            guests: widget.guests,
          ),
        ),
      );

      // If AddCardScreen returns true, payment succeeded and it already handled
      // history/notification and navigation. Nothing else needed here.
      if (res == true) {
        // Payment handled in AddCardScreen - just ensure we close this screen
        if (navigator.canPop()) navigator.pop();
      }
    } catch (e, st) {
      debugPrint('PayNow error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
      _tapLocked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.months.startDate;
    final end = widget.months.endDate;
    final guests = widget.guests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm & Pay'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0B0C10),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.room.assetImage,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.name,
                        style: GoogleFonts.playfairDisplay(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.room.location,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${guests.totalGuests} guests',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF0E0F12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dates',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () async {
                            final months = await showMonthPickerSheet(
                              context,
                              initial: start,
                            );
                            if (months != null) setState(() {});
                          },
                          icon: const Icon(Icons.edit, color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Guests',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () async {
                            final g = await showGuestPickerSheet(
                              context,
                              initial: guests,
                            );
                            if (g != null) setState(() {});
                          },
                          icon: const Icon(Icons.edit, color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      '${guests.adults} Adults, ${guests.children} Children, ${guests.infants} Infants',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                color: const Color(0xFF0E0F12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _priceRow('Base', _fmt.format(_baseSubtotal())),
                      _priceRow(
                        'Guest rules',
                        _fmt.format(_applyGuestRule(_baseSubtotal())),
                      ),
                      _priceRow('Taxes & fees', _fmt.format(taxesFees)),
                      const Divider(color: Colors.white12),
                      _priceRow(
                        'Grand Total',
                        _fmt.format(_grandTotal),
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                key: const Key('pay_now_button'),
                onPressed: _isProcessing ? null : _onPayNow,
                style: ElevatedButton.styleFrom(backgroundColor: primaryAccent),
                child: _isProcessing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay Now', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
