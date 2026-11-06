import 'package:flutter/material.dart';

import '../models/reseau.dart';
import 'operator_logo.dart';
import 'responsive_layout.dart';

class ReseauCard extends StatelessWidget {
  final Reseau reseau;
  final VoidCallback onTap;

  const ReseauCard({
    super.key,
    required this.reseau,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final accent = OperatorLogo.accent(context, reseau.couleur);

    // Libellé sémantique complet pour l'accessibilité.
    final semanticLabel = '${reseau.nom}. Appuyez pour sélectionner.';

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
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: kMinTouchWidth,
                          minHeight: kMinTouchHeight,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'logo_${reseau.nom}',
                            child: reseau.logo(size: 60, borderRadius: 22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reseau.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: onSurfaceColor,
                              fontSize: 20,
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
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Bénin',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ExcludeSemantics(
                      child: TouchZone(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(22),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: null,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }
}
