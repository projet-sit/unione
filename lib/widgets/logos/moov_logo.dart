import 'package:flutter/material.dart';

/// Widget affichant le logo officiel de Moov Africa Bénin.
/// Utilise une image réelle (assets/logos/moov.png) avec un fallback graphique.
class MoovLogo extends StatelessWidget {
  /// Taille du logo.
  final double size;

  const MoovLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final triangleSize = size * 0.22;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0070B8), // Bleu Moov officiel
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0070B8).withValues(alpha: 0.5),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/logos/moov.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Si l'image n'est pas trouvée, on affiche le logo généré par code
          errorBuilder: (context, error, stackTrace) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Positioned(
                  left: size * 0.6,
                  top: size * 0.6,
                  child: SizedBox.square(
                    dimension: triangleSize,
                    child: CustomPaint(painter: _MoovTrianglePainter()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Peintre pour le triangle décoratif du logo Moov (fallback).
class _MoovTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFF6B00)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
