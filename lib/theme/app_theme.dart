import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales Modernes
  static const Color primary = Color(0xFF007BFF); // Blue Accent
  static const Color background = Color(0xFF0F172A); // Deep Slate
  static const Color surface = Color(0xFF1E293B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);

  // Couleurs Thème Clair Raffiné (Adouci pour les yeux)
  static const Color lightPrimary = Color(0xFF2563EB); // Royal Blue
  static const Color lightBackground = Color(
    0xFFEDF2F7,
  ); // Gris très clair (plus doux que F8FAFC)
  static const Color lightSurface = Color(
    0xFFF7FAFC,
  ); // Blanc cassé (plus doux que pur white)
  static const Color lightTextPrimary = Color(0xFF1A202C); // Gris très sombre
  static const Color lightTextSecondary = Color(0xFF4A5568); // Gris moyen

  // Thème sombre global
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: primary.withValues(alpha: 0.8),
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: Color(0xFF334155),
    ),
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(color: textSecondary),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      elevation: 0,
    ),
  );

  // Thème clair global (Principalement utilisé)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary.withValues(alpha: 0.8),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: lightBackground,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(color: lightTextPrimary),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(color: lightTextSecondary),
    ),

    cardTheme: CardThemeData(
      color: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFCBD5E0)),
      ),
      elevation: 2,
      shadowColor: Color(0xFF0F172A).withValues(alpha: 0.04),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
