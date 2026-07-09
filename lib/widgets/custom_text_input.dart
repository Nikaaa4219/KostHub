import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String icon;
  final String hint;
  final TextEditingController editingController;
  final bool obsecure;

  const Input({
    super.key,
    required this.icon,
    required this.hint,
    required this.editingController,
    this.obsecure = false,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obsecure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 1. MENGUBAH LATAR BELAKANG KOTAK MENJADI ABU GELAP
        color: const Color(0xFF1C1D24),
        borderRadius: BorderRadius.circular(12),
        // 2. MENGUBAH GARIS BORDER MENJADI PUTIH TRANSPARAN
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: widget.editingController,
        obscureText: isObscured,
        // 3. MENGUBAH WARNA TEKS KETIKAN MENJADI PUTIH
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              widget.icon,
              width: 24,
              height: 24,
              // 4. MEMBERI WARNA PUTIH REDUP PADA IKON (Gembok/Email/Profil)
              color: Colors.white70,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.white38),
            ),
          ),
          hintText: widget.hint,
          // 5. MENGUBAH WARNA TEKS PETUNJUK (PLACEHOLDER)
          hintStyle: const TextStyle(color: Colors.white38),
          suffixIcon: widget.obsecure
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    // 6. MENGUBAH WARNA IKON MATA
                    color: Colors.white38,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscured = !isObscured;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
