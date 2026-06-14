import 'package:flutter/material.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';
import '../models/forfait.dart';

/// Classe regroupant toutes les données statiques des réseaux et services USSD actualisées pour 2025.
/// Conformité avec le passage aux 10 chiffres et l'harmonisation de l'ARCEP.
class UssdData {
  /// Liste des réseaux mobiles supportés au Bénin.
  static const List<Reseau> reseaux = [
    Reseau(
      type: ReseauType.mtn,
      nom: 'MTN',
      couleur: Color(0xFFFFCC00),
      logoLabel: 'MTN',
    ),
    Reseau(
      type: ReseauType.moov,
      nom: 'Moov Africa',
      couleur: Color(0xFF007EB8),
      logoLabel: 'MOOV',
    ),
    Reseau(
      type: ReseauType.celtiis,
      nom: 'Celtiis',
      couleur: Color(0xFF0A1F5C),
      logoLabel: 'CELTIIS',
    ),
  ];

  /// Mapping des actions USSD par type de réseau.
  static final Map<ReseauType, List<ActionUssd>> actions = {
    // --- SERVICES MTN BÉNIN (MAJ 2025) ---
    ReseauType.mtn: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104#',
      ),
      ActionUssd(
        titre: 'MTN MoMo',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*880#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*103#',
      ),
      ActionUssd(
        titre: 'Menu Services (*199#)',
        type: ActionType.information,
        icone: Icons.grid_view_rounded,
        codeBase: '*199#',
      ),
      ActionUssd(
        titre: 'Transfert Me2U',
        type: ActionType.transfer,
        template: '*102*{{numero}}*{{montant}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'MTN Internet',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*123#',
        forfaits: [
          Forfait(prix: '100', data: '175 Mo', duree: '24h', codeUssd: '*123*100#'),
          Forfait(prix: '200', data: '370 Mo', duree: '24h', codeUssd: '*123*200#'),
          Forfait(prix: '500', data: '1.2 Go', duree: '72h', codeUssd: '*123*500#'),
          Forfait(prix: '1000', data: '2.5 Go', duree: '7j', codeUssd: '*123*1000#'),
          Forfait(prix: '2000', data: '5.5 Go', duree: '30j', codeUssd: '*123*2000#'),
          Forfait(prix: '5000', data: '15 Go', duree: '30j', codeUssd: '*123*5000#'),
        ],
      ),
      ActionUssd(
        titre: 'MTN Maxi',
        type: ActionType.bundle,
        icone: Icons.phone_in_talk,
        codeBase: '*173#',
        forfaits: [
          Forfait(prix: '100', data: 'Maxi 100F', duree: '24h', codeUssd: '*173*100#'),
          Forfait(prix: '200', data: 'Maxi 200F', duree: '24h', codeUssd: '*173*200#'),
          Forfait(prix: '500', data: 'Maxi 500F', duree: '48h', codeUssd: '*173*500#'),
          Forfait(prix: '1000', data: 'Maxi 1000F', duree: '7j', codeUssd: '*173*1000#'),
        ],
      ),
    ],

    // --- SERVICES MOOV AFRICA BÉNIN (MAJ 2025) ---
    ReseauType.moov: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*101#',
      ),
      ActionUssd(
        titre: 'Moov Money',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*855#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*100*1*1#',
      ),
      ActionUssd(
        titre: 'Menu Services (*199#)',
        type: ActionType.information,
        icone: Icons.grid_view_rounded,
        codeBase: '*199#',
      ),
      ActionUssd(
        titre: 'Transfert Me2U',
        type: ActionType.transfer,
        template: '*102*{{montant}}*{{numero}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Moov Internet',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*130#',
        forfaits: [
          Forfait(prix: '100', data: 'Internet 100F', duree: '24h', codeUssd: '*130*100#'),
          Forfait(prix: '200', data: 'Internet 200F', duree: '24h', codeUssd: '*130*200#'),
          Forfait(prix: '500', data: 'Internet 500F', duree: '3j', codeUssd: '*130*500#'),
          Forfait(prix: '1000', data: 'Internet 1000F', duree: '7j', codeUssd: '*130*1000#'),
        ],
      ),
      ActionUssd(
        titre: 'Moov Sayaa',
        type: ActionType.bundle,
        icone: Icons.phone_in_talk,
        codeBase: '*173#',
        forfaits: [
          Forfait(prix: '100', data: 'Sayaa 100F', duree: '24h', codeUssd: '*173*100#'),
          Forfait(prix: '200', data: 'Sayaa 200F', duree: '24h', codeUssd: '*173*200#'),
          Forfait(prix: '500', data: 'Sayaa 500F', duree: '3j', codeUssd: '*173*500#'),
        ],
      ),
    ],

    // --- SERVICES CELTIIS BÉNIN (MAJ 2025) ---
    ReseauType.celtiis: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104#',
      ),
      ActionUssd(
        titre: 'Celtiis Cash',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*889#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*199*7*4#',
      ),
      ActionUssd(
        titre: 'Menu Services (*199#)',
        type: ActionType.information,
        icone: Icons.grid_view_rounded,
        codeBase: '*199#',
      ),
      ActionUssd(
        titre: 'Forfaits IllimiNet',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*199*4#',
        forfaits: [
          Forfait(prix: '100', data: 'IllimiNet 100F', duree: '24h', codeUssd: '*199*4*100#'),
          Forfait(prix: '500', data: 'IllimiNet 500F', duree: '24h', codeUssd: '*199*4*500#'),
          Forfait(prix: '1000', data: 'IllimiNet 1000F', duree: '7j', codeUssd: '*199*4*1000#'),
        ],
      ),
    ],
  };
}
