// File: lib/screens/profile_screen.dart
// Deskripsi: Layar profil pengguna. Terhubung ke AuthSource (Firebase).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';
import '../widgets/safe_asset_image.dart';
import '../providers/auth_provider.dart';

import '../services/auth_service.dart';
import '../common/info.dart';
import '../models/user.dart'; // Import model User

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
  // --- FUNGSI LOGOUT YANG SUDAH TERHUBUNG KE FIREBASE ---
  Future<void> _performLogout() async {
    try {
      Info.showLoading(context, message: 'Keluar dari akun...');

      await AuthSource.signOut();

      // Hapus sesi lokal di Provider agar benar-benar bersih
      if (mounted) {
        await context.read<AuthProvider>().setUser(User(name: '', email: ''));
      }

      Info.hideLoading();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
      Info.success('Berhasil keluar dari akun.');
    } catch (e) {
      Info.hideLoading();
      if (mounted) {
        Info.error('Logout gagal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: Column(
        children: [
          // --- HEADER PROFILE DENGAN SAFEAREA (RESPONSIVE) ---
          Container(
            color: _kPrimary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                          // Mengambil nama dan email yang sebenarnya
                          final displayName = user?.name ?? 'Memuat...';
                          final displayEmail = user?.email ?? '';

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
                      icon:
                          const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final res = await Navigator.of(context)
                            .push<Map<String, dynamic>>(
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                        if (!mounted) {
                          return;
                        }
                        if (res != null) {
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
            ),
          ),

          // --- Content ---
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
                const Divider(color: _kSurfaceDivider),
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
