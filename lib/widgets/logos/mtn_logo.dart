import 'dart:math' as math;

import 'package:flutter/material.dart';

class MtnLogo extends StatelessWidget {
  final double size;

  const MtnLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC00),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCC00).withValues(alpha: 0.5),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _MtnWavesPainter())),
          Text(
            'MTN',
            style: TextStyle(
              color: Colors.black,
              fontSize: size * 0.28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MtnWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);
    final radii = [size.width * 0.15, size.width * 0.22, size.width * 0.3];
    final opacities = [1.0, 0.6, 0.3];

    for (var i = 0; i < radii.length; i++) {
      final paint = Paint()
        ..color = Colors.black.withValues(alpha: opacities[i])
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(center: center, radius: radii[i]);
      canvas.drawArc(rect, math.pi, math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
