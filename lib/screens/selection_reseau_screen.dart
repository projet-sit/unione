import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/ussd_data.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_card.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../services/theme_service.dart';
import 'menu_actions_screen.dart';
import 'settings_screen.dart';

class SelectionReseauScreen extends StatefulWidget {
  const SelectionReseauScreen({super.key});

  @override
  State<SelectionReseauScreen> createState() => _SelectionReseauScreenState();
}

class _SelectionReseauScreenState extends State<SelectionReseauScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildBackground(context),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(context),
                      const SizedBox(height: 60),
                      _buildTitle(context),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView.builder(
                          itemCount: UssdData.reseaux.length,
                          itemBuilder: (context, index) {
                            final reseau = UssdData.reseaux[index];
                            return ReseauCard(
                              reseau: reseau,
                              isDetected: false,
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.03),
                ),
              ),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _BackgroundPainter(
                color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppLogo(size: 32),
              ),
              const SizedBox(width: 14),
              Text(
                'UNIONE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_network'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
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
