// File: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Jika ini merah, coba Restart VS Code setelah pub get
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'main_shell.dart';
import '../widgets/safe_asset_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLoginResult(LoginResult? resp) async {
    if (resp != null) {
      final token = resp.token;
      final userMap = resp.user;
      final user = User(
        name: userMap['name'] as String? ?? '',
        email: userMap['email'] as String? ?? '',
      );

      try {
        if (!mounted) return;
        final authProv = context.read<AuthProvider>();
        await authProv.setUser(user, token: token);

        if (!mounted) return;
        MainShell.navigateTo(context, 0);
      } catch (e) {
        debugPrint('Provider error: $e');
      }
    } else {
      _showError('Login gagal atau dibatalkan');
    }
  }

  Future<void> _doGoogleLogin() async {
    setState(() => _loading = true);
    try {
      final resp = await AuthService.instance.loginWithGoogle();
      if (!mounted) return;
      await _handleLoginResult(resp);
    } catch (e) {
      if (mounted) _showError('Gagal login Google: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doLogin() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _loading = true);
    try {
      final resp = await AuthService.instance.login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (!mounted) return;
      if (resp != null) {
        await _handleLoginResult(resp);
      } else {
        _showError('Email atau password salah');
      }
    } catch (e) {
      if (mounted) _showError('Terjadi kesalahan saat login');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // PERBAIKAN 1: Menambahkan const agar warning hilang
                    const SafeAssetImage(
                      'assets/images/PNG-KostHub/Logo_SplashScreen.png',
                      width: 36,
                      height: 36,
                      circle: true,
                      semanticLabel: 'Logo',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'KostHub',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Let's get you Login!",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your information below',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Tombol Google
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _doGoogleLogin,
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text('Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white12),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Facebook
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null, // Dummy
                        icon: const FaIcon(
                          FontAwesomeIcons.facebookF,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text('Facebook'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white12),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or login with',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white12)),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Colors.white70),
                    hintText: 'Email',
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Email tidak valid'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.white70),
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 karakter' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _showError('Fitur belum tersedia'),
                    child: Text('Forgot Password?',
                        style: GoogleFonts.inter(color: Colors.white70)),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _doLogin,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
