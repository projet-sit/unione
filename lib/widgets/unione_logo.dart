import 'package:flutter/material.dart';

import '../theme/app_assets.dart';

/// Logo officiel d'UNIONE (image `AppAssets.appLogo`).
///
/// Sans déformation : `BoxFit.contain` dans un conteneur carré, proportions
/// du fichier source préservées. L'icône historique (`AppAssets.legacyIcon`)
/// sert de repli si l'image ne charge pas.
class UnioneLogo extends StatelessWidget {
  /// Taille du logo (largeur = hauteur).
  final double size;

  const UnioneLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          AppAssets.appLogo,
          width: size,
          height: size,
          fit: BoxFit.contain,
          cacheWidth: size.toInt(),
          cacheHeight: size.toInt(),
          errorBuilder: (context, error, stackTrace) => Image.asset(
            AppAssets.legacyIcon,
            width: size,
            height: size,
            fit: BoxFit.contain,
            cacheWidth: size.toInt(),
            cacheHeight: size.toInt(),
          ),
        ),
      ),
    );
  }
}
