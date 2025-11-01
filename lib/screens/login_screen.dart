import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
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

  Future<void> _doLogin() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() => _loading = true);
    try {
      final resp = await AuthService.instance.login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (!mounted) return;
      if (resp != null) {
        final token = resp.token;
        final userMap = resp.user;
        final user = User(
          name: userMap['name'] as String? ?? '',
          email: userMap['email'] as String? ?? '',
        );

        // set minimal user info + token into AuthProvider so logout/other screens work
        try {
          final authProv = context.read<AuthProvider>();
          await authProv.setUser(user, token: token);
          if (!mounted) return;
          // Navigate into the MainShell so the shared bottom navigation is
          // active and tab switching is smooth.
          MainShell.navigateTo(context, 0);
        } catch (_) {}
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal: email atau password tidak valid'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat login')),
      );
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
                    // small logo (safe placeholder if asset missing)
                    SafeAssetImage(
                      'assets/images/logo.png',
                      width: 36,
                      height: 36,
                      circle: true,
                      semanticLabel: 'KostHub logo small',
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
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: SafeAssetImage(
                          'assets/images/google.png',
                          width: 18,
                          height: 18,
                          semanticLabel: 'Google',
                        ),
                        label: const Text('Google'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: SafeAssetImage(
                          'assets/images/facebook.png',
                          width: 18,
                          height: 18,
                          semanticLabel: 'Facebook',
                        ),
                        label: const Text('Facebook'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or login with',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white12)),
                  ],
                ),
                const SizedBox(height: 18),
                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    hintText: 'Email',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email diperlukan';
                    if (!v.contains('@')) return 'Masukkan email yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.white70,
                    ),
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password diperlukan';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // non-functional placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur lupa password belum tersedia'),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
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
