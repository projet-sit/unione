import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color primary = Color(0xFF00F2FF); // Electric Blue
  static const Color background = Color(0xFF121212);
  static const Color surface = Colors.black;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFAAAAAA);

  // Couleurs Thème Clair
  static const Color lightPrimary = Color(0xFF0284C7); // Sky Blue
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate off-white
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate dark
  static const Color lightTextSecondary = Color(0xFF475569); // Slate medium

  // Thème sombre global
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: primary.withValues(alpha: 0.7),
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.inter().fontFamily,
    
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w900),
      titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      bodyLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.inter(color: textSecondary),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white10),
      ),
      elevation: 0,
    ),
  );

  // Thème clair global
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary.withValues(alpha: 0.7),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: Color(0xFFF1F5F9),
    ),
    scaffoldBackgroundColor: lightBackground,
    fontFamily: GoogleFonts.inter().fontFamily,
    
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: lightTextPrimary),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w900),
      titleLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      bodyLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.inter(color: lightTextSecondary),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
    ),
  );
}
