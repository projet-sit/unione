import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Thème global : palette extraite du logo officiel (bleu nuit, bleu
/// électrique, cyan) et typographie centralisée.
class AppTheme {
  static const Color primary = AppColors.electric;
  static const Color background = AppColors.night;
  static const Color surface = AppColors.nightSurface;
  static const Color textPrimary = AppColors.white;
  static const Color textSecondary = AppColors.neutralSecondary;

  static const Color lightPrimary = AppColors.lightPrimary;
  static const Color lightBackground = AppColors.lightBackground;
  static const Color lightSurface = AppColors.lightSurface;
  static const Color lightTextPrimary = AppColors.lightTextPrimary;
  static const Color lightTextSecondary = AppColors.lightTextSecondary;

  // Thème sombre global
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.electric,
      secondary: AppColors.cyan,
      surface: AppColors.nightSurface,
      onSurface: AppColors.white,
      surfaceContainerHighest: AppColors.nightElevated,
    ),
    scaffoldBackgroundColor: AppColors.night,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontSize: AppTypography.fontSizeTitleMedium,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontWeight: FontWeight.w700,
        fontSize: AppTypography.fontSizeTitle,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.neutralSecondary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.nightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      elevation: 0,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SoberPageTransitionsBuilder(),
        TargetPlatform.iOS: SoberPageTransitionsBuilder(),
      },
    ),
  );

  // Thème clair global (principalement utilisé)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: const Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontSize: AppTypography.fontSizeTitleMedium,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: AppTypography.fontSizeTitle,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: AppColors.lightTextSecondary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightSeparator),
      ),
      elevation: 2,
      shadowColor: AppColors.night.withValues(alpha: 0.04),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SoberPageTransitionsBuilder(),
        TargetPlatform.iOS: SoberPageTransitionsBuilder(),
      },
    ),
  );
}

class SoberPageTransitionsBuilder extends PageTransitionsBuilder {
  const SoberPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}
