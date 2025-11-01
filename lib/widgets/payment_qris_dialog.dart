// Auto-generated per user prompt — manual review required
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

enum PaymentDialogAction { paid, cancelled }

class PaymentQrisDialog extends StatefulWidget {
  final Uint8List? qrisImage;
  final String atmAccount;
  final String invoiceId;

  const PaymentQrisDialog({
    super.key,
    required this.qrisImage,
    required this.atmAccount,
    required this.invoiceId,
  });

  @override
  State<PaymentQrisDialog> createState() => _PaymentQrisDialogState();
}

class _PaymentQrisDialogState extends State<PaymentQrisDialog> {
  bool _didReturn = false;

  Future<void> _copyAccount() async {
    await Clipboard.setData(ClipboardData(text: widget.atmAccount));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account copied')));
  }

  void _onPaid() {
    if (_didReturn) return;
    _didReturn = true;
    Navigator.of(context).pop(PaymentDialogAction.paid);
  }

  void _onCancel() {
    if (_didReturn) return;
    _didReturn = true;
    Navigator.of(context).pop(PaymentDialogAction.cancelled);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0F12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.qrisImage != null)
                Image.memory(
                  widget.qrisImage!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  semanticLabel: 'QRIS',
                )
              else
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white12,
                  ),
                  child: const Center(child: Text('QRIS Placeholder')),
                ),
              const SizedBox(height: 12),
              SelectableText(
                widget.atmAccount,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _copyAccount,
                      child: const Text('Copy Account'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onPaid,
                      child: const Text('I have paid'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _onCancel, child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}
