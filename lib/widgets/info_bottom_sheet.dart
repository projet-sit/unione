import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InfoBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;

  const InfoBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée du bottom sheet
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: colorScheme.primary, size: 32)
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 2000.ms, color: Colors.white24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  content,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),
    );
  }
}
