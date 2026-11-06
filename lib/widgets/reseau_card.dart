import 'package:flutter/material.dart';
import '../models/reseau.dart';

class ReseauCard extends StatelessWidget {
  final Reseau reseau;
  final VoidCallback onTap;
  final bool isDetected;

  const ReseauCard({
    super.key,
    required this.reseau,
    required this.onTap,
    this.isDetected = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    // Libellé sémantique complet pour l'accessibilité.
    final semanticLabel = isDetected
        ? '${reseau.nom}, réseau détecté. Appuyez pour sélectionner.'
        : '${reseau.nom}. Appuyez pour sélectionner.';

    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: reseau.couleur.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            splashColor: reseau.couleur.withValues(alpha: 0.1),
            highlightColor: reseau.couleur.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'logo_${reseau.nom}',
                          child: reseau.logo(size: 72, borderRadius: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reseau.nom,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: reseau.couleur.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Bénin',
                            style: TextStyle(
                              color: reseau.couleur,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        if (isDetected) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Réseau détecté',
                            style: TextStyle(
                              color: reseau.couleur,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ExcludeSemantics(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: onSurfaceColor.withValues(alpha: 0.4),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
