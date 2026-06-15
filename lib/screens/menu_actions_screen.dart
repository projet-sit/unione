import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/ussd_service.dart';
import '../models/reseau.dart';
import '../widgets/action_tile.dart';
import '../widgets/ussd_flow_screen.dart';
import '../models/action_ussd.dart';
import '../data/ussd_data.dart';

class MenuActionsScreen extends StatelessWidget {
  final Reseau reseau;

  const MenuActionsScreen({super.key, required this.reseau});

  @override
  Widget build(BuildContext context) {
    final actions = UssdData.actions[reseau.type] ?? [];
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Hero(
          tag: 'logo_${reseau.nom}',
          child: reseau.logo(size: 32),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Subtle background elements
          Positioned(
            top: 40,
            right: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reseau.couleur.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reseau.nom} Bénin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: reseau.couleur,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'select_action'.tr(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: onSurfaceColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return ActionTile(
                        action: action,
                        reseau: reseau,
                        onTap: () => _handleAction(context, action),
                      )
                      .animate()
                      .fadeIn(delay: (index * 50).ms, duration: 400.ms)
                      .scale(begin: const Offset(0.9, 0.9), delay: (index * 50).ms, curve: Curves.easeOutBack);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, ActionUssd action) async {
    if (!action.aBesoinParam && action.codeBase != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lancement...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      await UssdService.launchUssd(
        context, 
        action.codeBase!,
        title: action.titre,
        network: reseau.nom,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UssdFlowScreen(
          reseau: reseau,
          action: action,
        ),
      ),
    );
  }
}
