import 'dart:async';

import 'package:flutter/material.dart';
// google_fonts not needed in splash (image contains wordmark)
import 'login_screen.dart';
// import '../widgets/safe_asset_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brand image (logo + wordmark)
              Image.asset(
                'assets/images/PNG-KostHub/Logo_SplashScreen.png',
                width: 180,
                height: 180,
                // circle: false,
                semanticLabel: 'KostHub brand',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
