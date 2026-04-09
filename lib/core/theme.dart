import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pastel Color Palette
  static const Color primaryPastel = Color(0xFFAEC6CF); // Soft Blue
  static const Color secondaryPastel = Color(0xFFFFD1DC); // Pastel Pink
  static const Color backgroundLight = Color(0xFFFDFDFD); // Off White
  static const Color textDark = Color(0xFF4A4A4A); // Soft Charcoal

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPastel,
        primary: primaryPastel,
        secondary: secondaryPastel,
        background: backgroundLight,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}