// Auto-generated — manual review required
// File: lib/screens/edit_profile_screen.dart
// Implements edit profile form and end-to-end call to UserService.updateProfile
// Requires package:intl for DateFormat('dd/MM/yyyy'). Ensure `intl` exists in pubspec.yaml.
// (stubbed by default; see TODOs.md and `lib/services/user_service.dart`)

// The file uses RadioListTile as a compatibility fallback for SDKs older than
// Flutter 3.32. Those members are deprecated in newer SDKs; we keep the
// fallback and silence the deprecation info-level lint for this file.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/user_service.dart' show updateProfileFn;
import '../providers/auth_provider.dart';

const _kBackground = Color(0xFF0B0C10);
const _kSurface = Color(0xFF0E0F12);
const _kPrimary = Color(0xFF5D5CFF);
const _kMuted = Color(0xFFB9B9C9);

// Requires Flutter >= 3.32 for RadioGroup; fallback to RadioListTile if compatibility required.
// To change behavior, set this const to false.
const bool useRadioGroup = false; // set to true only if SDK supports RadioGroup

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'john.doe@example.com',
  );
  final TextEditingController _phoneCtrl = TextEditingController(
    text: '+628123456789',
  );
  final TextEditingController _dobCtrl = TextEditingController();

  String? _gender = 'Male';
  bool _saving = false;

  final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // default DOB approx 20 years ago
    _dobCtrl.text = _formatDate(
      DateTime.now().subtract(const Duration(days: 365 * 20)),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => _dateFmt.format(d);

  DateTime? _parseDate(String s) {
    try {
      return _dateFmt.parseStrict(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    DateTime initDate = _parseDate(_dobCtrl.text) ??
        DateTime.now().subtract(const Duration(days: 365 * 20));
    final res = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (res != null) {
      _dobCtrl.text = _formatDate(res);
    }
  }

  Future<void> _doSave() async {
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Periksa isian form')));
      return;
    }

    setState(() => _saving = true);

    // Build User model to send to service. dob is converted to DateTime (model holds DateTime).
    final DateTime? dob = _parseDate(_dobCtrl.text);
    final userToUpdate = User(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dob: dob,
      gender: _gender,
    );

    try {
      // call the top-level override-able function (test-friendly)
      final updated = await updateProfileFn(userToUpdate);

      if (!mounted) {
        return;
      }

      // update AuthProvider if available
      try {
        context.read<AuthProvider>().setUser(updated);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _buildGenderInput() {
    // If you want to use the new RadioGroup API (Flutter >= 3.32), set useRadioGroup = true.
    // Example (uncomment and adapt if SDK supports it):
    // RadioGroup<String>(
    //   initialValue: _gender ?? 'Male',
    //   onChanged: (v) => setState(() => _gender = v),
    //   items: ['Male','Female'],
    //   labelBuilder: (v) => Text(v, style: GoogleFonts.inter(fontSize:14)),
    // )

    // Fallback implementation using RadioListTile (compatible with older SDKs).
    // The RadioListTile API is deprecated after Flutter 3.32 in favor of RadioGroup.
    // We keep the fallback for older SDKs and explicitly ignore the deprecation
    // lint here so analyzer doesn't spam an info-level warning.
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: Text(
              'Male',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
            value: 'Male',
            groupValue: _gender,
            onChanged: (v) => setState(() => _gender = v ?? 'Male'),
            activeColor: _kPrimary,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: Text(
              'Female',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
            value: 'Female',
            groupValue: _gender,
            onChanged: (v) => setState(() => _gender = v ?? 'Female'),
            activeColor: _kPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar placeholder
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih foto: fitur stub'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: _kPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: GoogleFonts.inter(
                        color: _kMuted,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: _kSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama diperlukan'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.inter(
                        color: _kMuted,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: _kSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email diperlukan';
                      }
                      if (!v.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      labelStyle: GoogleFonts.inter(
                        color: _kMuted,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: _kSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'No. telepon diperlukan';
                      }
                      if (v.replaceAll(RegExp(r'[^0-9+]'), '').length < 9) {
                        return 'No. telepon terlalu pendek';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dobCtrl,
                    readOnly: true,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle: GoogleFonts.inter(
                        color: _kMuted,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: _kSurface,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                        ),
                        onPressed: _pickDate,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 12),
                  // Gender input (adaptive)
                  _buildGenderInput(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saving ? null : _doSave,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
