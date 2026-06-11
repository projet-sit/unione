import 'package:flutter/material.dart';

class MoovLogo extends StatelessWidget {
  final double size;

  const MoovLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final triangleSize = size * 0.22;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0070B8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0070B8).withValues(alpha: 0.5),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
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
      ),
    );
  }
}

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
