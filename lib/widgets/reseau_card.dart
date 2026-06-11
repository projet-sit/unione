import 'package:flutter/material.dart';
import '../models/reseau.dart';

import 'zoli_shimmer.dart';

class ReseauCard extends StatelessWidget {
  final Reseau reseau;
  final VoidCallback onTap;

  const ReseauCard({super.key, required this.reseau, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Fond sombre au lieu de la couleur pleine
        color: const Color(0xFF101C2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: reseau.couleur.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: reseau.couleur.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: reseau.couleur.withValues(alpha: 0.15),
          highlightColor: reseau.couleur.withValues(alpha: 0.08),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Bande de couleur à gauche (accent)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: reseau.couleur,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
                // Lueur subtile en haut à droite
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          reseau.couleur.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Contenu principal
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 22.0,
                  ),
                  child: Row(
                    children: [
                      // Logo du réseau
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: reseau.couleur.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: reseau.couleur.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: reseau.logo(size: 30),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Nom du réseau
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ZoliShimmer(
                              baseColor: Colors.white,
                              highlightColor: reseau.couleur.withValues(alpha: 0.7),
                              child: Text(
                                '${reseau.nom} Bénin',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Réseau mobile',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Flèche
                      ZoliShimmer(
                        baseColor: Colors.transparent,
                        highlightColor: reseau.couleur.withValues(alpha: 0.4),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: reseau.couleur.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: reseau.couleur.withValues(alpha: 0.20),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: reseau.couleur,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
