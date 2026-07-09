import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// == PAYMENT GATEWAY ==
class PaymentWebviewScreen extends StatefulWidget {
  final String url;

  const PaymentWebviewScreen({super.key, required this.url});

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFinished = false; // Mencegah double-pop

  @override
  void initState() {
    super.initState();
    // Konfigurasi WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) _checkPaymentStatus(change.url!);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // == URL MIDTRANS ==
  void _checkPaymentStatus(String url) {
    if (_isFinished) return;

    final lowercaseUrl = url.toLowerCase();
    debugPrint("Memeriksa URL Midtrans: $lowercaseUrl");
    if (lowercaseUrl.contains('transaction_status=settlement') ||
        lowercaseUrl.contains('transaction_status=capture') ||
        lowercaseUrl.contains('status_code=200') ||
        lowercaseUrl.contains('success') ||
        lowercaseUrl.contains('payment_success')) {
      _isFinished = true;
      Navigator.pop(context, 'success');
    } else if (lowercaseUrl.contains('transaction_status=deny') ||
        lowercaseUrl.contains('transaction_status=cancel') ||
        lowercaseUrl.contains('transaction_status=expire') ||
        lowercaseUrl.contains('status_code=202')) {
      _isFinished = true;
      Navigator.pop(context, 'failed');
    }
  }

  // == EDGE CASE ==
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selesaikan Pembayaran"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_isFinished) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1F2029),
                  title: const Text("Batalkan Pembayaran?",
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "Jika Anda sudah membayar, pastikan menekan tombol 'Kembali ke Merchant' di dalam halaman web sebelum menyilang layar ini.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Kembali"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, 'pending');
                      },
                      child: const Text("Tutup Halaman",
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
