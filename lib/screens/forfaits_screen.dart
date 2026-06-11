import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';
import '../widgets/app_logo.dart';
import '../widgets/reseau_header.dart';
import '../widgets/forfait_card.dart';
import '../services/ussd_service.dart';

class ForfaitsScreen extends StatelessWidget {
  final Reseau reseau;
  final ActionUssd parentAction;

  const ForfaitsScreen({
    super.key,
    required this.reseau,
    required this.parentAction,
  });

  @override
  Widget build(BuildContext context) {
    final forfaits = parentAction.forfaits ?? [];

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parentAction.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: forfaits.length,
                itemBuilder: (context, index) {
                  final forfait = forfaits[index];
                  return ForfaitCard(
                        forfait: forfait,
                        reseau: reseau,
                        onTap: () =>
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
