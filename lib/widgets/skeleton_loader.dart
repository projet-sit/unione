import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget shimmer générique animé, utilisé comme placeholder pendant
/// le chargement asynchrone de données.
/// Affiche un conteneur animé dont la couleur oscille entre [baseColor]
/// et [highlightColor] pour simuler un squelette de chargement.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
      _ctrl.repeat(reverse: true);
    }
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(base, highlight, _anim.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton d'une carte réseau (ReseauCard) pendant le chargement.
class SkeletonReseauCard extends StatelessWidget {
  const SkeletonReseauCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement en cours',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Row(
          children: [
            SkeletonBox(width: 72, height: 72, borderRadius: 22),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 120, height: 20, borderRadius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 60, height: 14, borderRadius: 6),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBox(width: 44, height: 44, borderRadius: 22),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/// Skeleton d'une carte d'historique (HistoryScreen) pendant le chargement.
class SkeletonHistoryCard extends StatelessWidget {
  const SkeletonHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement en cours',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 48, height: 48, borderRadius: 16),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 120, height: 16, borderRadius: 6),
                      SkeletonBox(width: 36, height: 12, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 8),
                  SkeletonBox(height: 12, borderRadius: 4),
                  SizedBox(height: 4),
                  SkeletonBox(width: 160, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
