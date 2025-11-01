// Auto-generated per user prompt — manual review required
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../utils/payment_utils.dart';

class PaymentIntent {
  final String invoiceId;
  final Uint8List? qrisImage;
  final String atmAccount;

  PaymentIntent({
    required this.invoiceId,
    this.qrisImage,
    required this.atmAccount,
  });
}

class PaymentService {
  /// Set this to true in tests to force verifyPayment to succeed.
  static bool forceVerifyResult = true;

  /// Simulate creating a payment intent (QRIS image or ATM account)
  static Future<PaymentIntent> createPayment({
    required int amount,
    String currency = 'IDR',
    String method = 'qris',
    bool forceSuccess = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final invoiceId = generateInvoiceId();
    try {
      Uint8List? bytes;
      // Try to load a placeholder asset qris image; if missing, return null
      try {
        final bd = await rootBundle.load('assets/images/qris_placeholder.png');
        bytes = bd.buffer.asUint8List();
      } catch (_) {
        bytes = null;
      }
      return PaymentIntent(
        invoiceId: invoiceId,
        qrisImage: bytes,
        atmAccount: 'BANK ABC: 1234567890',
      );
    } catch (e) {
      // fallback
      return PaymentIntent(
        invoiceId: invoiceId,
        qrisImage: null,
        atmAccount: 'BANK ABC: 1234567890',
      );
    }
  }

  /// Simulate payment verification. Returns true on success.
  static Future<bool> verifyPayment(
    String invoiceId, {
    bool? forceResult,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (forceResult != null) return forceResult;
    return forceVerifyResult;
  }
}
