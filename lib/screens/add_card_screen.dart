// ATM Payment screen (repurposed from AddCardScreen)
// ignore_for_file: use_build_context_synchronously
// This sheet collects a bank account number and an entered amount for a
// manual ATM/bank transfer flow. It validates input and, on correct
// amount, persists booking history and notifications.
// Keys: input_account, input_amount, payment_success_back_home, payment_fail_try_again
// Note: replace manual transfer with a real payment gateway integration when
// moving from the manual ATM flow to an online provider.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/booking_record.dart';
import '../models/room.dart';
import '../providers/history_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/payment_popup.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import '../widgets/date_picker_bottom_sheet.dart';

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
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _selectedBank = 'BCA';
  bool _isProcessing = false;
  bool _tapLocked = false;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  int _parseCurrency(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _onPay() async {
    if (_tapLocked) return;
    _tapLocked = true;
    setState(() => _isProcessing = true);
    // Capture context-derived objects early to avoid using BuildContext after awaits.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final account = _accountCtrl.text.trim();
      final entered = _parseCurrency(_amountCtrl.text);
      final total = widget.total;

      if (account.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Nomor Rekening harus diisi')),
        );
        return;
      }
      if (entered <= 0) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Nominal harus diisi dengan angka')),
        );
        return;
      }

      if (entered == total) {
        // success flow
        final hist = Provider.of<HistoryProvider>(context, listen: false);
        final notif = Provider.of<NotificationProvider>(context, listen: false);

        final rec = BookingRecord(
          id: generateInvoiceId(),
          roomId: widget.room.id,
          startDate: widget.months.startDate,
          endDate: widget.months.endDate,
          adults: widget.guests.adults,
          children: widget.guests.children,
          infants: widget.guests.infants,
          total: total,
          invoiceId: generateInvoiceId(),
          paymentMethod: 'ATM (${_selectedBank.toUpperCase()})',
          timestamp: DateTime.now(),
        );

        await hist.addPayment(rec);
        // Persist a richer payment notification (contains booking fields)
        await notif.addPaymentNotification(rec);

        // Show success popup using previously-captured navigator.context
        await showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (_) => const PaymentPopup(success: true, message: null),
        );

        // Close all and go back to the main shell (home tab)
        navigator.popUntil((r) => r.isFirst);
        // Push the main shell which contains the Home tab. Using
        // pushReplacementNamed ensures the splash/login screens are
        // replaced so the user lands directly in the app.
        navigator.pushReplacementNamed('/shell');
      } else {
        // failure popup
        final res = await showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (_) => const PaymentPopup(
            success: false,
            message: 'Masukkan nominal yang tepat',
          ),
        );
        // If user chooses retry (dialog returns 'retry'), keep the sheet open; otherwise do nothing
        if (res == 'retry') {
          // allow user to try again; no navigation needed
        }
      }
    } catch (e, st) {
      debugPrint('ATM pay error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
      _tapLocked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0E0F12),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: controller,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ATM Payment',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('input_account'),
                  controller: _accountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nomor Rekening',
                    hintText: 'Contoh: 1234567890',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Pilih Bank: ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedBank,
                      dropdownColor: const Color(0xFF0E0F12),
                      items: const [
                        DropdownMenuItem(value: 'BCA', child: Text('BCA')),
                        DropdownMenuItem(
                          value: 'BANK ABC',
                          child: Text('BANK ABC'),
                        ),
                        DropdownMenuItem(value: 'BNI', child: Text('BNI')),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedBank = v ?? 'BCA'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('input_amount'),
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nominal Pembayaran',
                    hintText: formatCurrency(widget.total),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _onPay,
                    child: _isProcessing
                        ? const CircularProgressIndicator()
                        : const Text('Pay'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total due: ${formatCurrency(widget.total)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
