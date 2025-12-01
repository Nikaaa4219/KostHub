import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable payment result popup used by the ATM/manual flow.
class PaymentPopup extends StatelessWidget {
  final bool success;
  final String? message;

  const PaymentPopup({super.key, required this.success, this.message});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: const Color(0xFF0E0F12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (success) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D5CFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.white24, blurRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment Received Successfully',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Congratulations 🎉 Your booking has been confirmed',
                  style: GoogleFonts.inter(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('payment_success_back_home'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
              ] else ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment Failed',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? 'Please enter the correct amount',
                  style: GoogleFonts.inter(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('payment_fail_try_again'),
                        onPressed: () {
                          Navigator.of(context).pop('retry');
                        },
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop('back');
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
