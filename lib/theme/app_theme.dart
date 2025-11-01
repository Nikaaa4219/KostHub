import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _background = Color(0xFF0B0C10);
  static const Color _surface = Color(0xFF0E0F12);
  static const Color _primary = Color(0xFF5D5CFF);
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
      tertiary: _primary,
      onTertiary: _textPrimary,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F2130)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1F2130)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2A2B33),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}
