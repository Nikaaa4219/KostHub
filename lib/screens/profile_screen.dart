// File: lib/screens/profile_screen.dart
// Deskripsi: Layar profil pengguna. Terhubung ke AuthService (stub) dan EditProfileScreen.
// Bergantung pada: lib/screens/edit_profile_screen.dart, lib/services/auth_service.dart, lib/widgets/safe_asset_image.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart';
import '../widgets/safe_asset_image.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

const _kBackground = Color(0xFF0B0C10);
const _kPrimary = Color(0xFF5D5CFF);
const _kSurfaceDivider = Color(0xFF1F2130);
const _kMuted = Color(0xFFB9B9C9);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _performLogout() async {
    // Capture context-dependent objects before awaiting to satisfy the
    // linter rule about using BuildContext across async gaps.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    AuthProvider? authProv;
    try {
      authProv = context.read<AuthProvider>();
    } catch (_) {}

    try {
      await AuthService.instance.logout();
      if (!mounted) return;

      // clear provider if we captured it earlier
      try {
        if (authProv != null) await authProv.clearUser();
      } catch (_) {}

      messenger.showSnackBar(const SnackBar(content: Text('Logout berhasil')));
      navigator.pushReplacementNamed('/login');
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: Column(
        children: [
          // Header - match HomeScreen dimensions to avoid visual jump when
          // navigating between Home and Profile. Use same height and padding
          // and keep a flat bottom (no rounded corners) so the app doesn't
          // appear to resize/slide.
          Container(
            height: 110,
            color: _kPrimary,
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: 'Profile image',
                  child: const SafeAssetImage(
                    'assets/images/profile.jpg',
                    width: 72,
                    height: 72,
                    circle: true,
                    semanticLabel: 'Profile image',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (ctx) {
                      final user = ctx.watch<AuthProvider>().user;
                      final displayName = (user != null && user.name.isNotEmpty)
                          ? user.name
                          : 'John Doe';
                      final displayEmail =
                          (user != null && user.email.isNotEmpty)
                              ? user.email
                              : 'john.doe@example.com';

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayEmail,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFFB9B9C9),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () async {
                    // buka EditProfileScreen dan tunggu hasil
                    final messenger = ScaffoldMessenger.of(context);
                    final res =
                        await Navigator.of(context).push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                    if (!mounted) {
                      return;
                    }
                    if (res != null) {
                      // Updated profile returned; update provider/UI as needed (see TODOs.md)
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Profile diperbarui (lokal)'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTile(
                  Icons.person_outline,
                  'Edit Profile',
                  'Ubah informasi profil',
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: _kSurfaceDivider),
                _buildTile(
                  Icons.lock_outline,
                  'Change Password',
                  'Ubah password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Change password: fitur stub'),
                      ),
                    );
                  },
                ),
                const Divider(color: _kSurfaceDivider),
                _buildTile(
                  Icons.credit_card,
                  'Payment Method',
                  'Kartu & metode pembayaran',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment Method: fitur stub'),
                      ),
                    );
                  },
                ),
                const Divider(color: _kSurfaceDivider),
                _buildTile(
                  Icons.bookmark_border,
                  'My Bookings',
                  'Daftar booking',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('My Bookings: fitur stub')),
                    );
                  },
                ),
                // divider between bookings and privacy as requested
                const Divider(color: _kSurfaceDivider),
                // Dark Mode setting removed - theme handled at app level
                _buildTile(
                  Icons.privacy_tip,
                  'Privacy Policy',
                  'Kebijakan privasi',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy: fitur stub'),
                      ),
                    );
                  },
                ),
                const Divider(color: _kSurfaceDivider),
                _buildTile(
                  Icons.description,
                  'Terms & Conditions',
                  'Syarat & ketentuan',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Terms: fitur stub')),
                    );
                  },
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: _performLogout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation is provided by MainShell when the app runs inside
      // the shell. When the user wants to jump to a tab we navigate to the
      // shell and select the appropriate index so the transition is smooth.
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: _kMuted)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: false,
      horizontalTitleGap: 8,
      visualDensity: VisualDensity.compact,
    );
  }
}

// NOTE: logout already calls AuthService.logout() stub and clears AuthProvider when available.
// Remove this comment once real backend/logout flow is integrated.
