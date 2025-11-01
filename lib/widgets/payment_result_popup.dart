// Auto-generated per user prompt — manual review required
import 'dart:ui';

import 'package:flutter/material.dart';

enum PaymentResultVariant { success, failure }

class PaymentResultPopup extends StatelessWidget {
  final PaymentResultVariant variant;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onBackToHome;

  const PaymentResultPopup({
    super.key,
    required this.variant,
    this.message,
    this.onRetry,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = variant == PaymentResultVariant.success;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0F12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: isSuccess ? Colors.green : Colors.red,
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSuccess ? 'Payment Received Successfully' : 'Payment Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    (isSuccess
                        ? 'Your booking has been confirmed'
                        : 'Payment failed, please try again'),
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: isSuccess
                    ? [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onBackToHome != null) onBackToHome!();
                            },
                            child: const Text('Back to Home'),
                          ),
                        ),
                      ]
                    : [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onRetry != null) onRetry!();
                            },
                            child: const Text('Retry'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onBackToHome != null) onBackToHome!();
                            },
                            child: const Text('Back to Home'),
                          ),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
