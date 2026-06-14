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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF121212),
                    Color(0xFF1A1A1A),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                    Color(0xFFE2E8F0),
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
