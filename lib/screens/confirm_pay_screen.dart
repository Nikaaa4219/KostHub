// Auto-generated per user prompt — manual review required
// Suppress deprecated Radio group API warnings in some legacy widgets
// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import '../widgets/payment_qris_dialog.dart';
import '../widgets/payment_result_popup.dart';
import '../services/payment_service.dart';
import '../utils/payment_utils.dart';
import '../providers/history_provider.dart';
import '../providers/notification_provider.dart';
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
  List<Map<String, dynamic>> _cards = [];
  int _selectedCardIndex = -1;
  bool _payInFull = true;
  bool _isProcessing = false;
  bool _tapLocked = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('saved_cards');
    if (raw == null) return;
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    _cards = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (mounted) setState(() {});
  }

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
      // capture context-derived objects to avoid using BuildContext across async gaps
      final ctx = context;
      final navigator = Navigator.of(ctx);
      final messenger = ScaffoldMessenger.of(ctx);
      // validation
      if (widget.months.monthsCount <= 0 || widget.guests.adults < 1) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal dan tamu terlebih dahulu'),
          ),
        );
        return;
      }
      // Create a payment intent (QRIS or bank transfer account)
      final PaymentIntent intent = await PaymentService.createPayment(
        amount: _grandTotal,
      );

      // show QRIS / ATM dialog and wait for user action
      final result = await showDialog<PaymentDialogAction?>(
        context: ctx,
        barrierDismissible: true,
        builder: (_) => PaymentQrisDialog(
          qrisImage: intent.qrisImage,
          atmAccount: intent.atmAccount,
          invoiceId: intent.invoiceId,
        ),
      );

      if (result == PaymentDialogAction.paid) {
        // verify payment
        final verified = await PaymentService.verifyPayment(intent.invoiceId);
        if (!mounted) return;
        if (verified) {
          // persist booking and notify
          final history = Provider.of<HistoryProvider>(ctx, listen: false);
          final notif = Provider.of<NotificationProvider>(ctx, listen: false);
          final rec = BookingRecord(
            id: generateInvoiceId(),
            roomId: widget.room.id,
            startDate: widget.months.startDate,
            endDate: widget.months.endDate,
            adults: widget.guests.adults,
            children: widget.guests.children,
            infants: widget.guests.infants,
            total: _grandTotal,
            invoiceId: intent.invoiceId,
            paymentMethod: intent.qrisImage != null ? 'QRIS' : 'ATM',
            timestamp: DateTime.now(),
          );
          await history.addBooking(rec);
          await notif.addPaymentNotification(rec);

          // show success popup
          await showDialog(
            context: ctx,
            builder: (_) => PaymentResultPopup(
              variant: PaymentResultVariant.success,
              onBackToHome: () {
                // navigate back to home
                navigator.popUntil((r) => r.isFirst);
                navigator.pushReplacementNamed('/home');
              },
            ),
          );
        } else {
          // failed
          await showDialog(
            context: ctx,
            builder: (_) => PaymentResultPopup(
              variant: PaymentResultVariant.failure,
              message: 'Payment failed, please try again',
              onRetry: () async {
                navigator.pop();
                // reopen the QR dialog by recursively calling _onPayNow
                if (mounted) {
                  await _onPayNow();
                }
              },
              onBackToHome: () {
                navigator.popUntil((r) => r.isFirst);
                navigator.pushReplacementNamed('/home');
              },
            ),
          );
        }
      }
    } catch (e, st) {
      debugPrint('Pay error: $e\n$st');
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

  Future<void> _onAddCard() async {
    final res = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (res == null) return;
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('saved_cards');
    final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    list.add(res);
    await sp.setString('saved_cards', jsonEncode(list));
    await _loadCards();
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment Method',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _payInFull,
                      onChanged: (v) => setState(() => _payInFull = v ?? true),
                    ),
                    title: const Text(
                      'Pay in full',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => setState(() => _payInFull = true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _payInFull,
                      onChanged: (v) => setState(() => _payInFull = v ?? true),
                    ),
                    title: const Text(
                      'Pay part now, part later',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => setState(() => _payInFull = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ..._cards.asMap().entries.map((e) {
                    final idx = e.key;
                    final card = e.value;
                    final last4 = (card['number'] as String).replaceAll(
                      ' ',
                      '',
                    );
                    final display =
                        '**** **** **** ${last4.substring(last4.length - 4)}';
                    return ListTile(
                      leading: Radio<int>(
                        value: idx,
                        groupValue: _selectedCardIndex,
                        onChanged: (v) =>
                            setState(() => _selectedCardIndex = v ?? -1),
                      ),
                      title: Text(
                        display,
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      subtitle: Text(
                        card['name'] ?? '',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                      onTap: () => setState(() => _selectedCardIndex = idx),
                    );
                  }),
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.white),
                    title: const Text(
                      'Add card',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: _onAddCard,
                  ),
                ],
              ),
            ),
            Card(
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ValueListenableBuilder(
                valueListenable: ValueNotifier<bool>(false),
                builder: (_, __, ___) {
                  final canPay =
                      (widget.months.monthsCount > 0) &&
                      (widget.guests.adults >= 1) &&
                      !_isProcessing &&
                      (_cards.isNotEmpty || _selectedCardIndex >= 0);
                  return ElevatedButton(
                    onPressed: canPay ? _onPayNow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canPay
                          ? primaryAccent
                          : Colors.grey.shade800,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Pay Now'),
                  );
                },
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
          Text(label, style: TextStyle(color: Colors.white70)),
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
