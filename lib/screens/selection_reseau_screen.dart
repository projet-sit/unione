import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/ussd_data.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_card.dart';
import '../widgets/info_bottom_sheet.dart';
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
      backgroundColor: const Color(0xFF0A2540), // Bleu Nuit
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
                  // Bottom Bar
                  _buildBottomBar(context).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 20),
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
              Color(0xFF0A2540), // Bleu Nuit
              Color(0xFF16213E), // Bleu Indigo
              Color(0xFF051220), // Noir Profond
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

  Widget _buildBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUtilityButton(Icons.info_outline, const Color(0xFF00AEEF), () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const InfoBottomSheet(
              title: 'À propos de Zoli',
              subtitle: '',
              content: "Zoli est une application conçue pour simplifier l'accès aux codes USSD des opérateurs mobiles au Bénin (MTN, MOOV, Celtiis). Plus besoin de mémoriser ou chercher les codes — tout est regroupé en un seul endroit, organisé et accessible en quelques secondes.",
              icon: Icons.info_outline,
            ),
          );
        }),
        const SizedBox(width: 24),
        _buildUtilityButton(Icons.code, Colors.white60, () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const InfoBottomSheet(
              title: 'À propos du développeur',
              subtitle: 'Ulrich IDOHOU',
              content: "Je suis Ulrich IDOHOU, développeur Flutter basé à Abomey-Calavi, Bénin. Passionné par la création d'outils utiles et accessibles pour le quotidien africain, je développe des applications centrées sur l'expérience utilisateur locale.",
              icon: Icons.person,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUtilityButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: color, size: 28),
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
