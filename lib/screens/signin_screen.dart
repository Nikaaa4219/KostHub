import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:d_session/d_session.dart';

import '../common/info.dart';
import '../services/auth_service.dart';
import '../widgets/button_primary.dart';
import '../widgets/custom_text_input.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final edtEmail = TextEditingController();
  final edtPassword = TextEditingController();

  @override
  void dispose() {
    edtEmail.dispose();
    edtPassword.dispose();
    super.dispose();
  }

  void signIn() async {
    if (edtEmail.text.trim().isEmpty) {
      return Info.error('Alamat email harus diisi!');
    }
    if (edtPassword.text.trim().isEmpty) {
      return Info.error('Kata sandi harus diisi!');
    }

    Info.showLoading(context, message: 'Memverifikasi...');

    final message = await AuthSource.signIn(
      edtEmail.text.trim(),
      edtPassword.text.trim(),
    );

    Info.hideLoading();

    if (message != 'success') {
      return Info.error(message);
    }

    // --- JEMBATAN DATA KE AUTH PROVIDER ---
    final sessionData = await DSession.getUser();
    if (sessionData != null && mounted) {
      final userModel = User(
        name: sessionData['name'] ?? 'User',
        email: sessionData['email'] ?? edtEmail.text.trim(),
      );
      // Menyimpan data ke memori aplikasi agar bisa dibaca halaman Profile
      await context
          .read<AuthProvider>()
          .setUser(userModel, token: 'firebase_token');
    }
    // --------------------------------------

    Info.success('Welcome Back!');
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/discover');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // HEADER LOGO KECIL
                Row(
                  children: [
                    Image.asset(
                      'assets/images/PNG-KostHub/Logo_SplashScreen.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.hotel, color: Color(0xFF5D5CFF)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'KostHub',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        color: const Color(0xFF5D5CFF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // TEKS SAMBUTAN
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Log in to continue",
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 32),

                // FORM INPUT
                Text(
                  'Email Address',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Input(
                  icon: 'assets/ic_email.png',
                  hint: 'Enter email address',
                  editingController: edtEmail,
                ),
                const SizedBox(height: 20),

                Text(
                  'Password',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Input(
                  icon: 'assets/ic_key.png',
                  hint: 'Enter password',
                  editingController: edtPassword,
                  obsecure: true,
                ),
                const SizedBox(height: 30),

                // TOMBOL LOGIN
                ButtonPrimary(text: 'Log In', onTap: signIn),
                const SizedBox(height: 24),

                // DIVIDER & GOOGLE
                Row(
                  children: [
                    const Expanded(
                        child:
                            Divider(color: Color.fromARGB(31, 255, 255, 255))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or continue with',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white54)),
                    ),
                    const Expanded(child: Divider(color: Colors.white12)),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Info.error('Google Sign-In segera hadir!'),
                    icon: const FaIcon(FontAwesomeIcons.google,
                        color: Colors.white, size: 18),
                    label: Text('Google',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // TOMBOL PINDAH HALAMAN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: GoogleFonts.inter(color: Colors.white70)),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/signup'),
                      child: Text("Sign Up",
                          style: GoogleFonts.inter(
                              color: const Color(0xFF5D5CFF),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
