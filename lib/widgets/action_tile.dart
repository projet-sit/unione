import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';

class ActionTile extends StatelessWidget {
  final ActionUssd action;
  final Reseau reseau;
  final VoidCallback onTap;

  const ActionTile({
    super.key, 
    required this.action, 
    required this.reseau, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // Couleur de bordure selon réseau
    Color borderColor = reseau.couleur;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icone as IconData, 
              size: 32, 
              color: borderColor
            ),
            const SizedBox(height: 12),
            Text(
              action.titre.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            // Les codes USSD ne sont plus affichés dans l'interface
          ],
        ),
      ),
    );
  }
}
