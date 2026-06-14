import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DeveloperInfoSheet extends StatelessWidget {
  const DeveloperInfoSheet({super.key});

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
                      child: const Icon(Icons.person, color: Color(0xFF00AEEF), size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À propos du développeur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ulrich IDOHOU',
                            style: TextStyle(
                              color: Color(0xFF00AEEF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  "Je suis Ulrich IDOHOU, développeur Flutter basé à Abomey-Calavi, Bénin. Passionné par la création d'outils utiles et accessibles pour le quotidien africain, je développe des applications centrées sur l'expérience utilisateur locale.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'À propos de UNIONE',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "UNIONE est une application conçue pour simplifier l'accès aux codes USSD des opérateurs mobiles au Bénin (MTN, MOOV, Celtiis). Plus besoin de mémoriser ou chercher les codes — tout est regroupé en un seul endroit, organisé et accessible en quelques secondes.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
