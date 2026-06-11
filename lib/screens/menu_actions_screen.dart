import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reseau.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_header.dart';
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppLogo.small(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: ReseauHeader(reseau: reseau)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
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
                .fadeIn(delay: (index * 80).ms, duration: 350.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  delay: (index * 80).ms,
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                );
          },
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, ActionUssd action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UssdFlowScreen(
          network: reseau.nom,
          operation: action.titre,
          themeColor: reseau.couleur,
        ),
      ),
    );
  }
}
