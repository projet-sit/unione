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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              color: Colors.white24,
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
                        color: const Color(0xFF00AEEF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: const Color(0xFF00AEEF), size: 32)
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFF00AEEF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
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
