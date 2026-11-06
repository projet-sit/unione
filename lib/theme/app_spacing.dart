import 'package:flutter/material.dart';

/// Dimensions et espacements centralisés (échelle 4 points).
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusSheet = 32;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(24, 20, 24, 36);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets sectionGap = EdgeInsets.only(bottom: 28);
}
