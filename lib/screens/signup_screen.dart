import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/info.dart';
import '../services/auth_service.dart';
import '../widgets/button_primary.dart';
import '../widgets/custom_text_input.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final edtName = TextEditingController();
  final edtEmail = TextEditingController();
  final edtPassword = TextEditingController();

  @override
  void dispose() {
    edtName.dispose();
    edtEmail.dispose();
    edtPassword.dispose();
    super.dispose();
  }

  void createNewAccount() async {
    if (edtName.text.trim().isEmpty) {
      return Info.error('Nama lengkap harus diisi!');
    }
    if (edtEmail.text.trim().isEmpty) {
      return Info.error('Alamat email harus diisi!');
    }
    if (edtPassword.text.trim().isEmpty) {
      return Info.error('Kata sandi harus diisi!');
    }
    if (edtPassword.text.length < 6) {
      return Info.error('Password minimal 6 karakter!');
    }

    Info.showLoading(context, message: 'Membuat akun...');

    final message = await AuthSource.signUp(
      edtName.text.trim(),
      edtEmail.text.trim(),
      edtPassword.text.trim(),
    );

    Info.hideLoading();

    if (message != 'success') {
      return Info.error(message);
    }

    Info.success('Account created successfully!');
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/signin');
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
                Text(
                  "Create Account",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign up to start your journey",
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Text(
                  'Full Name',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Input(
                  icon: 'assets/ic_profile.png',
                  hint: 'Enter full name',
                  editingController: edtName,
                ),
                const SizedBox(height: 20),
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
                  hint: 'Create password',
                  editingController: edtPassword,
                  obsecure: true,
                ),
                const SizedBox(height: 30),
                ButtonPrimary(text: 'Sign Up', onTap: createNewAccount),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: GoogleFonts.inter(color: Colors.white70)),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/signin'),
                      child: Text("Log In",
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
