import 'package:flutter/material.dart';

/// Vrais logos officiels des opérateurs, chargés depuis les fichiers fournis.
/// Jamais de dessin ou de recréation : image brute, fond = couleur de marque.
class OperatorLogo extends StatelessWidget {
  final String operatorId;
  final double size;
  final double? borderRadius;

  const OperatorLogo({
    super.key,
    required this.operatorId,
    this.size = 44,
    this.borderRadius,
  });

  static const _assets = <String, String>{
    'mtn': 'assets/logos/mtn.jpg',
    'moov': 'assets/logos/moov.jpg',
    'celtiis': 'assets/logos/celtiis.jpg',
  };

  static List<String> get availableAssets => _assets.values.toList(growable: false);

  /// Fond de marque (échantillonné sur les fichiers officiels).
  static const _tileColors = <String, Color>{
    'mtn': Color(0xFFFFCB05),
    'moov': Color(0xFF005CC3),
    'celtiis': Color(0xFF173A73),
  };

  static Color tileColor(String operatorId) =>
      _tileColors[operatorId] ?? const Color(0xFF2563EB);

  /// Couleur de marque ajustée pour rester lisible : en mode sombre, les
  /// marques à fond sombre (Celtiis, Moov) sont éclaircies vers le blanc.
  static Color accent(BuildContext context, Color brand) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark || brand.computeLuminance() >= 0.2) return brand;
    return Color.lerp(brand, Colors.white, 0.45)!;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _assets[operatorId];
    if (assetPath == null) {
      return SizedBox.square(dimension: size);
    }
    // Celtiis : la capture fournie a une bordure blanche — zoom léger pour la
    // masquer ; les autres gardent leur fond de marque déjà rempli complet.
    final zoom = operatorId == 'celtiis' ? 1.14 : 1.0;
    final radius = borderRadius ?? size * 0.3;
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: tileColor(operatorId),
              child: Transform.scale(
                scale: zoom,
                child: Image.asset(
                  assetPath,
                  width: size * 0.82,
                  height: size * 0.82,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                  cacheWidth: (size * 0.82).toInt(),
                  cacheHeight: (size * 0.82).toInt(),
                ),
              ),
        ),
      ),
    );
  }
}
