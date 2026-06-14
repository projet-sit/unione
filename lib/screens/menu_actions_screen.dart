import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reseau.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_header.dart';
import '../widgets/action_tile.dart';
import '../widgets/ussd_flow_screen.dart';
import '../models/action_ussd.dart';
import '../data/ussd_data.dart';
import 'forfaits_screen.dart';

/// Écran principal affichant la liste des services disponibles pour un réseau.
/// AUCUNE SOUS-OPTION : L'accès est direct.
class MenuActionsScreen extends StatelessWidget {
  final Reseau reseau;

  const MenuActionsScreen({super.key, required this.reseau});

  @override
  Widget build(BuildContext context) {
    // Récupération de la liste plate des actions
    final actions = UssdData.actions[reseau.type] ?? [];

    return Scaffold(
      backgroundColor: Colors.white, // Forcé sur blanc
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppLogo.small(),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: ReseauHeader(reseau: reseau)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services ${reseau.nom}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
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
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gère la navigation directe vers le service ou la liste des forfaits.
  void _handleAction(BuildContext context, ActionUssd action) {
    // Si l'action contient des forfaits, on va directement à la liste des prix
    if (action.forfaits != null && action.forfaits!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForfaitsScreen(
            reseau: reseau,
            parentAction: action,
          ),
        ),
      );
    } else {
      // Sinon, on va vers le flux USSD (formulaire ou lancement direct)
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
}
