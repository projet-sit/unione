import 'package:flutter/material.dart';
import '../services/ussd_service.dart';
import '../models/reseau.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_header.dart';
import '../widgets/action_tile.dart';
import '../widgets/ussd_flow_screen.dart';
import '../models/action_ussd.dart';
import '../data/ussd_data.dart';
import 'forfaits_screen.dart';

class MenuActionsScreen extends StatelessWidget {
  final Reseau reseau;

  const MenuActionsScreen({super.key, required this.reseau});

  @override
  Widget build(BuildContext context) {
    final actions = UssdData.actions[reseau.type] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
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

  void _handleAction(BuildContext context, ActionUssd action) async {
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
      return;
    }

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
