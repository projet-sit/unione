import 'package:flutter/material.dart';

/// Le widget de logo officiel de l'application UNIONE.
/// Utilise l'icône de l'application (assets/icon.png) pour garantir la cohérence visuelle.
class UnioneLogo extends StatelessWidget {
  /// Taille du logo (largeur et hauteur).
  final double size;

  const UnioneLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Ombre portée subtile pour détacher le logo du fond
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Utilisation de l'image de l'icône officielle pour la cohérence
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Fallback en cas d'erreur de chargement de l'image
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              size: Size(size, size),
              painter: UnioneLogoPainter(),
            );
          },
        ),
      ),
    );
  }
}

/// Peintre personnalisé utilisé comme fallback si l'image des assets ne charge pas.
class UnioneLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fond avec un dégradé circulaire
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, bgPaint);

    // Bordure subtile pour donner de la profondeur
    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawCircle(center, radius - 1, innerShadowPaint);

    // Dessin du "U" stylisé (en noir pour le contraste)
    final uPaint = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final uPath = Path();
    final uWidth = size.width * 0.4;
    final uHeight = size.height * 0.35;
    final topY = center.dy - uHeight / 2;
    final bottomY = center.dy + uHeight / 4;
    
    uPath.moveTo(center.dx - uWidth / 2, topY);
    uPath.lineTo(center.dx - uWidth / 2, bottomY);
    
    uPath.arcTo(
      Rect.fromLTWH(
        center.dx - uWidth / 2,
        bottomY - uWidth / 2,
        uWidth,
        uWidth,
      ),
      3.14, 
      -3.14,
      false,
    );
    
    uPath.lineTo(center.dx + uWidth / 2, topY);

    canvas.drawPath(uPath, uPaint);

    // Points de connexion symbolisant l'unité (Union)
    final dotPaint = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(center.dx - uWidth / 2, topY), size.width * 0.04, dotPaint);
    canvas.drawCircle(Offset(center.dx + uWidth / 2, topY), size.width * 0.04, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
