import 'package:flutter/material.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';

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
    // --- SERVICES MTN BÉNIN (MAJ 2026) ---
    ReseauType.mtn: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*126#',
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
        titre: 'Menu Services',
        type: ActionType.information,
        icone: Icons.grid_view_rounded,
        codeBase: '*199#',
      ),
      ActionUssd(
        titre: 'Portail Forfaits',
        type: ActionType.bundle,
        icone: Icons.shopping_bag_outlined,
        codeBase: '*123#',
      ),
      ActionUssd(
        titre: 'XtraTime',
        type: ActionType.credit,
        icone: Icons.access_time_rounded,
        codeBase: '*785#',
      ),
    ],

    // --- SERVICES MOOV AFRICA BÉNIN (MAJ 2026) ---
    ReseauType.moov: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104#',
      ),
      ActionUssd(
        titre: 'Moov Money',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*855#',
      ),
      ActionUssd(
        titre: 'Moov Bomi',
        type: ActionType.bundle,
        icone: Icons.flash_on_rounded,
        codeBase: '*855*2#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*199*1*3#',
      ),
      ActionUssd(
        titre: 'Menu Services',
        type: ActionType.information,
        icone: Icons.grid_view_rounded,
        codeBase: '*199#',
      ),
      ActionUssd(
        titre: 'Moov Internet',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*123#',
      ),
      ActionUssd(
        titre: 'Moov Forfaits Voix',
        type: ActionType.bundle,
        icone: Icons.phone_in_talk,
        codeBase: '*173#',
      ),
    ],

    // --- SERVICES CELTIIS BÉNIN (MAJ 2026) ---
    ReseauType.celtiis: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104*1*1#',
      ),
      ActionUssd(
        titre: 'Celtiis Cash',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*889#',
      ),
      ActionUssd(
        titre: 'Solde Forfait',
        type: ActionType.information,
        icone: Icons.signal_cellular_alt_rounded,
        codeBase: '*104*1*2#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*199*7*4#',
      ),
      ActionUssd(
        titre: 'Menu Pass',
        type: ActionType.bundle,
        icone: Icons.grid_view_rounded,
        codeBase: '*199#',
      ),
      ActionUssd(
        titre: 'Programme Fidélité',
        type: ActionType.other,
        icone: Icons.star_outline_rounded,
        codeBase: '*133#',
      ),
      ActionUssd(
        titre: 'Service client',
        type: ActionType.other,
        icone: Icons.support_agent_rounded,
        codeBase: '7373',
      ),
    ],
  };
}
