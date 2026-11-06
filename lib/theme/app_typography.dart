import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie centralisée (Plus Jakarta Sans), échelle compacte et réutilisable.
class AppTypography {
  const AppTypography._();

  static String get fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  static double fontSizeDisplay = 28;
  static double fontSizeTitle = 22;
  static double fontSizeTitleMedium = 20;
  static double fontSizeBody = 16;
  static double fontSizeBodyMedium = 15;
  static double fontSizeCaption = 12;

  /// Styles de base, à composer avec la couleur du thème courant.
  static TextStyle displayLarge({Color? color}) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: fontSizeDisplay,
    fontWeight: FontWeight.w800,
  );

  static TextStyle titleLarge({Color? color}) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.w700,
  );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: fontSizeTitleMedium,
    fontWeight: FontWeight.w800,
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: fontSizeBody,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: fontSizeBodyMedium,
    fontWeight: FontWeight.w500,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: fontSizeCaption,
    fontWeight: FontWeight.w600,
  );
}
