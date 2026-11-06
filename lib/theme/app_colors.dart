import 'package:flutter/material.dart';

/// Palette centralisée, extraite du logo officiel UNIONE
/// (échantillonné sur `assets/images/app_logo.png`) :
/// - bleu nuit : fonds sombres
/// - bleu électrique : accent / action
/// - cyan : mise en valeur
/// - blanc : textes et surfaces contrastées
/// - gris neutre : textes secondaires et séparateurs
class AppColors {
  const AppColors._();

  // ---- Bleu nuit (fonds) ----
  static const Color night = Color(0xFF050B26);
  static const Color nightDeep = Color(0xFF02061A);
  static const Color nightSurface = Color(0xFF0E1730);
  static const Color nightElevated = Color(0xFF1A2642);

  // ---- Bleu électrique (primaire / action) ----
  static const Color electric = Color(0xFF0066FF);
  static const Color electricSoft = Color(0xFF4D94FF);

  // ---- Cyan (mise en valeur) ----
  static const Color cyan = Color(0xFF00D4FF);
  static const Color cyanSoft = Color(0xFF66E4FF);

  // ---- Blanc & gris neutre ----
  static const Color white = Color(0xFFFFFFFF);
  static const Color neutralSecondary = Color(0xFF94A3B8);
  static const Color neutralSeparator = Color(0xFF334155);

  // ---- Thème clair ----
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightSecondary = Color(0xFF00B4E6);
  static const Color lightBackground = Color(0xFFEDF2F7);
  static const Color lightSurface = Color(0xFFF7FAFC);
  static const Color lightTextPrimary = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightSeparator = Color(0xFFCBD5E0);
}
