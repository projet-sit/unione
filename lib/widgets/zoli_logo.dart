import 'package:flutter/material.dart';

import 'zoli_shimmer.dart';

class ZoliLogo extends StatelessWidget {
  final double size;
  const ZoliLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF00AEEF), // Bleu Électrique
      ),
      padding: EdgeInsets.all(size * 0.2),
      child: ZoliShimmer(
        highlightColor: Colors.white.withValues(alpha: 0.8),
        baseColor: Colors.white,
        duration: const Duration(seconds: 2),
        child: CustomPaint(
          painter: _LightningZPainter(),
        ),
      ),
    );
  }
}

class _LightningZPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // Dessin géométrique du Z formé par deux éclairs
    // Éclair du haut
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width * 0.4, size.height * 0.45);
    path.lineTo(size.width * 0.65, size.height * 0.45);
    // Éclair du bas (relié)
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.6, size.height * 0.55);
    path.lineTo(size.width * 0.35, size.height * 0.55);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
