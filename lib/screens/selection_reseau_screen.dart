import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/ussd_data.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_card.dart';
import '../services/sim_service.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../services/theme_service.dart';
import 'menu_actions_screen.dart';
import 'settings_screen.dart';
import 'comparator_screen.dart';

class SelectionReseauScreen extends StatefulWidget {
  const SelectionReseauScreen({super.key});

  @override
  State<SelectionReseauScreen> createState() => _SelectionReseauScreenState();
}

class _SelectionReseauScreenState extends State<SelectionReseauScreen> {
  Set<String> _detectedOperators = {};

  @override
  void initState() {
    super.initState();
    _detectSims();
  }

  Future<void> _detectSims() async {
    final operators = await SimService.getDetectedOperators();
    if (mounted) {
      setState(() {
        _detectedOperators = operators;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              // Background avec dégradé et illustration
              _buildBackground(context),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Header
                      _buildHeader(context),
                      const SizedBox(height: 60),
                      // Titre principal (Animation supprimée pour plus de sobriété)
                      _buildTitle(context),
                      const SizedBox(height: 30),
                      
                      // Section de comparaison supprimée à la demande de l'utilisateur
                      // _buildProminentCompareCard(context),

                      // Liste des réseaux mobile
                      Expanded(
                        child: ListView.builder(
                          itemCount: UssdData.reseaux.length,
                          itemBuilder: (context, index) {
                            final reseau = UssdData.reseaux[index];
                            final isDetected = _detectedOperators.contains(reseau.nom.toUpperCase());
                            
                            return ReseauCard(
                              reseau: reseau,
                              isDetected: isDetected,
                              onTap: () => _navigateToActions(context, reseau),
                            );
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
      },
    );
  }

  Widget _buildBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF121212), // Fond sombre
                    Color(0xFF1A1A1A), // Gris sombre
                    Color(0xFF000000), // Noir Profond
                  ]
                : const [
                    Color(0xFFF8FAFC), // Off-white
                    Color(0xFFF1F5F9), // Slate light
                    Color(0xFFE2E8F0), // Slate gray border-ish
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: _BackgroundPainter(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
          ),
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
            Text(
              'UNIONE',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'select_network'.tr(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildProminentCompareCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ComparatorScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.compare_arrows_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comparer les offres',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Le meilleur forfait au meilleur prix',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
  }

  void _navigateToActions(BuildContext context, dynamic reseau) async {
    await HistoryService().logEvent(
      title: 'history_network_title',
      description: 'history_network_selected|${reseau.nom}',
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
  final Color color;
  _BackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
