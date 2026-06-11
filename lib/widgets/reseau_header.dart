import 'package:flutter/material.dart';
import '../models/reseau.dart';

class ReseauHeader extends StatelessWidget {
  final Reseau reseau;

  const ReseauHeader({super.key, required this.reseau});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'header-${reseau.type}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Fond sombre avec accent subtil de la couleur réseau
          color: const Color(0xFF101C2E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: reseau.couleur.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: reseau.couleur.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Petit point de couleur
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: reseau.couleur,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: reseau.couleur.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              reseau.nom,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            reseau.logo(size: 24),
          ],
        ),
      ),
    );
  }
}
