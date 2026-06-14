import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_header.dart';
import '../widgets/forfait_card.dart';
import '../services/ussd_service.dart';

/// Écran affichant la liste des forfaits disponibles pour une catégorie donnée.
class ForfaitsScreen extends StatelessWidget {
  /// Le réseau mobile sélectionné.
  final Reseau reseau;
  /// L'action (catégorie) parente contenant la liste des forfaits.
  final ActionUssd parentAction;

  const ForfaitsScreen({
    super.key,
    required this.reseau,
    required this.parentAction,
  });

  @override
  Widget build(BuildContext context) {
    // Récupération de la liste des forfaits définie pour cette action.
    final forfaits = parentAction.forfaits ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppLogo.small(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: ReseauHeader(reseau: reseau)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la catégorie de forfait (ex: MTN Go, IllimiNet)
            Text(
              parentAction.titre.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            // Liste déroulante des forfaits
            Expanded(
              child: ListView.builder(
                itemCount: forfaits.length,
                itemBuilder: (context, index) {
                  final forfait = forfaits[index];
                  return ForfaitCard(
                        forfait: forfait,
                        reseau: reseau,
                        onTap: () =>
                            // Lancement de l'opération USSD lors du clic.
                            UssdService.launchUssd(
                              context, 
                              forfait.codeUssd,
                              title: 'Achat Forfait ${forfait.data}',
                              network: reseau.nom,
                            ),
                      )
                      .animate()
                      .fadeIn(delay: (index * 70).ms, duration: 300.ms)
                      .slideX(
                        begin: 0.3,
                        delay: (index * 70).ms,
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
