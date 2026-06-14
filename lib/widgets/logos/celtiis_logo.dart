import 'package:flutter/material.dart';

/// Widget affichant le logo officiel de Celtiis Bénin.
/// Utilise une image réelle (assets/logos/celtiis.png) avec un fallback textuel.
class CeltiisLogo extends StatelessWidget {
  /// Taille du logo.
  final double size;

  const CeltiisLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F5C), // Bleu foncé officiel
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F5C).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/logos/celtiis.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Si l'image n'est pas trouvée, on affiche le logo généré par code
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'celtiis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
