import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xFF007AFF),
    cardColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: GoogleFonts.inter(
        color: const Color(0xFF007AFF),
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.inter(
        color: const Color(0xFF007AFF),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: const Color(0xFF12B0F8),
    cardColor: const Color(0xFF1E1E1E),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: GoogleFonts.inter(
        color: const Color(0xFF12B0F8),
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.inter(
        color: const Color(0xFF12B0F8),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}