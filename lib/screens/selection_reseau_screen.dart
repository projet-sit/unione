import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/ussd_data.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_card.dart';

import '../services/history_service.dart';
import '../models/history_item.dart';
import 'menu_actions_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class SelectionReseauScreen extends StatelessWidget {
  const SelectionReseauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fond sombre neutre
      body: Stack(
        children: [
          // Background avec dégradé et illustration
          _buildBackground(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 60),
                  // Titre principal
                  _buildTitle().animate().fadeIn(duration: 600.ms).slideX(),
                  const SizedBox(height: 40),
                  // Liste des boutons
                  Expanded(
                    child: ListView.builder(
                      itemCount: UssdData.reseaux.length,
                      itemBuilder: (context, index) {
                        return ReseauCard(
                          reseau: UssdData.reseaux[index],
                          onTap: () => _navigateToActions(context, UssdData.reseaux[index]),
                        ).animate().fadeIn(delay: (200 + index * 100).ms).scale(begin: const Offset(0.9, 0.9));
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121212), // Fond sombre
              Color(0xFF1A1A1A), // Gris sombre
              Color(0xFF000000), // Noir Profond
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: _BackgroundPainter(),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const AppLogo(size: 45),
            const SizedBox(width: 12),
            const Text(
              'Zoli',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white70),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white70),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Veuillez sélectionner\nun réseau :',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
    );
  }



  void _navigateToActions(BuildContext context, dynamic reseau) async {
    await HistoryService().logEvent(
      title: 'Sélection Réseau',
      description: 'Choix de l\'opérateur ${reseau.nom}',
      network: reseau.nom,
      type: HistoryType.networkSelection,
    );
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuActionsScreen(reseau: reseau)),
      );
    }
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Dessine des cercles concentriques pour un effet subtil de profondeur
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        100.0 * i,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
