import 'package:flutter/material.dart';

/// Largeur maximale du contenu sur les grands écrans (tablettes, téléphones
/// très larges). Au-delà, le contenu est centré et limité à cette largeur.
const double kMaxContentWidth = 700;

/// Largeur de référence sous laquelle on considère l'écran comme « étroit »
/// (téléphones compacts) et on passe à 2 colonnes dans la grille.
const double kNarrowWidth = 600;

/// Hauteur minimale de la zone tactile pour respecter les 48 dp Android.
const double kMinTouchHeight = 48;
const double kMinTouchWidth = 48;

/// Enveloppe un écran dans une [SafeArea] compatible affichage bord à bord
/// (Android 15), avec une largeur maximale de contenu centrée sur les grands
/// écrans. Le padding horizontal est relatif à la largeur d'écran.
class SafePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SafePage({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < kNarrowWidth;
    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(horizontal: isNarrow ? 20 : 24, vertical: 16);
    final constrainedWidth = width - effectivePadding.horizontal;

    return SafeArea(
      minimum: EdgeInsets.zero,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kMaxContentWidth),
          child: Padding(
            padding: effectivePadding,
            child: SizedBox(
              width: constrainedWidth > kMaxContentWidth
                  ? kMaxContentWidth
                  : constrainedWidth,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Grille adaptative : 2 colonnes en dessous de [kNarrowWidth] dp, 3 au-delà.
/// Chaque carte a une hauteur adaptée à son contenu (pas de hauteur fixe).
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mainAxisSpacing = 20,
    this.crossAxisSpacing = 20,
    this.childAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width < kNarrowWidth
            ? (width - 40) / 2
            : (width - 72) / 3,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Zone tactile garantie d'au moins 48 dp, centrant l'enfant à l'intérieur.
class TouchZone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;

  const TouchZone({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kMinTouchWidth,
      height: kMinTouchHeight,
      child: Material(
        color: color ?? Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Center(child: child),
        ),
      ),
    );
  }
}
