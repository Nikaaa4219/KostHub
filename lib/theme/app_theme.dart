import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna Dark Luxury
  static const Color _background = Color(0xFF0B0C10); // Hitam Pekat
  static const Color _surface = Color(0xFF1C1D24); // Abu Gelap (Untuk Card)
  static const Color _primary = Color(0xFF5D5CFF); // Ungu Neon
  static const Color _textPrimary = Color(0xFFFFFFFF);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.dark(
      primary: _primary,
      onPrimary: _textPrimary,
      secondary: _primary,
      onSecondary: _textPrimary,
      error: Colors.red.shade400,
      surface: _surface,
      onSurface: _textPrimary,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: _textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: _textPrimary),
      labelLarge: GoogleFonts.inter(fontSize: 12, color: _textPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      cardColor: _surface,
      primaryColor: _primary,
      textTheme: textTheme,
      // Input Field Style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
      ),
      // Button Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size.fromHeight(52),
          elevation: 8,
          shadowColor: _primary.withValues(alpha: 0.4),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
