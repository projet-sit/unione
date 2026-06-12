import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color background = Color(0xFF121212);
  static const Color surface = Colors.black;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFAAAAAA);

  // Thème global
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.inter().fontFamily,
    
    // Configuration de l'AppBar
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

    // Configuration des textes
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w900),
      titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      bodyLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.inter(color: textSecondary),
    ),

    // Style des cartes et containers
    cardTheme: CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
    ),
  );
}
