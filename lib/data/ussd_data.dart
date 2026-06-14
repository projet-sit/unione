import 'package:flutter/material.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';
import '../models/forfait.dart';

/// Classe regroupant toutes les données statiques des réseaux et services USSD.
/// Structure PLATE : Toutes les catégories ont été supprimées pour un accès direct.
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
      type: ReseauType.celtiis,
      nom: 'Celtiis',
      couleur: Color(0xFF0A1F5C),
      logoLabel: 'CELTIIS',
    ),
    Reseau(
      type: ReseauType.moov,
      nom: 'MOOV',
      couleur: Color.fromARGB(255, 0, 126, 184),
      logoLabel: 'MOOV',
    ),
  ];

  /// Mapping des actions USSD par type de réseau.
  /// AUCUNE SOUS-OPTION : L'utilisateur accède directement aux listes de forfaits.
  static final Map<ReseauType, List<ActionUssd>> actions = {
    // --- SERVICES MTN BÉNIN ---
    ReseauType.mtn: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*124#',
      ),
      ActionUssd(
        titre: 'MTN MoMo (Menu)',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*880#',
      ),
      ActionUssd(
        titre: 'Transfert de crédit',
        type: ActionType.transfer,
        template: '*102*{{numero}}*{{montant}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Achat de crédit',
        type: ActionType.credit,
        template: '*106*{{pin}}*{{montant}}*{{numero}}#',
        icone: Icons.phone_android_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'MTN Go (Internet)',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*130#',
        forfaits: [
          Forfait(prix: '100', data: '175 Mo', duree: '24h', codeUssd: '*130*1#'),
          Forfait(prix: '200', data: '370 Mo', duree: '24h', codeUssd: '*130*2#'),
          Forfait(prix: '500', data: '1.2 Go', duree: '72h', codeUssd: '*130*3#'),
          Forfait(prix: '1000', data: '2.5 Go', duree: '7j', codeUssd: '*130*4#'),
          Forfait(prix: '2000', data: '5.5 Go', duree: '30j', codeUssd: '*130*5#'),
          Forfait(prix: '5000', data: '15 Go', duree: '30j', codeUssd: '*130*6#'),
          Forfait(prix: '10000', data: '35 Go', duree: '30j', codeUssd: '*130*7#'),
          Forfait(prix: '15000', data: '60 Go', duree: '30j', codeUssd: '*130*8#'),
          Forfait(prix: '20000', data: '100 Go', duree: '30j', codeUssd: '*130*9#'),
        ],
      ),
      ActionUssd(
        titre: 'Go Pack (Appel + Net)',
        type: ActionType.bundle,
        icone: Icons.swap_calls_rounded,
        codeBase: '*123#',
        forfaits: [
          Forfait(prix: '100', data: 'Go Pack 100F', duree: '24h', codeUssd: '*123*1*1#'),
          Forfait(prix: '200', data: 'Go Pack 200F', duree: '24h', codeUssd: '*123*1*2#'),
          Forfait(prix: '500', data: 'Go Pack 500F', duree: '72h', codeUssd: '*123*1*3#'),
          Forfait(prix: '1000', data: 'Go Pack 1000F', duree: '7j', codeUssd: '*123*1*4#'),
          Forfait(prix: '2000', data: 'Go Pack 2000F', duree: '7j', codeUssd: '*123*1*5#'),
          Forfait(prix: '5000', data: 'Go Pack 5000F', duree: '30j', codeUssd: '*123*1*6#'),
        ],
      ),
      ActionUssd(
        titre: 'MTN Maxi (Appels)',
        type: ActionType.bundle,
        icone: Icons.phone_in_talk,
        codeBase: '*173#',
        forfaits: [
          Forfait(prix: '100', data: 'Maxi 100F', duree: '24h', codeUssd: '*173*77*100#'),
          Forfait(prix: '150', data: 'Maxi 150F', duree: '24h', codeUssd: '*173*77*150#'),
          Forfait(prix: '200', data: 'Maxi 200F', duree: '24h', codeUssd: '*173*77*200#'),
          Forfait(prix: '500', data: 'Maxi 500F', duree: '48h', codeUssd: '*173*77*500#'),
          Forfait(prix: '1000', data: 'Maxi 1000F', duree: '7j', codeUssd: '*173*77*1000#'),
          Forfait(prix: '2500', data: 'Maxi 2500F', duree: '30j', codeUssd: '*173*77*2500#'),
          Forfait(prix: '5000', data: 'Maxi 5000F', duree: '30j', codeUssd: '*173*77*5000#'),
          Forfait(prix: '10000', data: 'Big Maxi 10000F', duree: '30j', codeUssd: '*173*77*10000#'),
          Forfait(prix: '25000', data: 'Big Maxi 25000F', duree: '30j', codeUssd: '*173*77*25000#'),
          Forfait(prix: '50000', data: 'Big Maxi 50000F', duree: '30j', codeUssd: '*173*77*50000#'),
        ],
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*123*1*1#',
      ),
    ],

    // --- SERVICES CELTIIS BÉNIN ---
    ReseauType.celtiis: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104#',
      ),
      ActionUssd(
        titre: 'Celtiis Cash (Menu)',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*150#',
      ),
      ActionUssd(
        titre: 'Transfert de crédit',
        type: ActionType.transfer,
        template: '*300*{{numero}}*{{montant}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'IllimiNet (Internet)',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*199*4#',
        forfaits: [
          Forfait(prix: '100', data: 'Pass Chrono 100F', duree: '24h', codeUssd: '*199*2*1*1#'),
          Forfait(prix: '200', data: 'Pass Chrono 200F', duree: '24h', codeUssd: '*199*2*1*2#'),
          Forfait(prix: '500', data: 'Pass Chrono 500F', duree: '24h', codeUssd: '*199*2*1*3#'),
          Forfait(prix: '1000', data: 'Connect 1000F', duree: '7j', codeUssd: '*199*2*2*1#'),
          Forfait(prix: '2000', data: 'Connect 2000F', duree: '30j', codeUssd: '*199*2*3*1#'),
          Forfait(prix: '5000', data: 'IllimiNet 5000F', duree: '30j', codeUssd: '*199*4*1#'),
          Forfait(prix: '10000', data: 'IllimiNet 10000F', duree: '30j', codeUssd: '*199*4*2#'),
          Forfait(prix: '15000', data: 'IllimiNet 15000F', duree: '30j', codeUssd: '*199*4*3#'),
          Forfait(prix: '30000', data: 'IllimiNet 30000F', duree: '30j', codeUssd: '*199*4*4#'),
        ],
      ),
      ActionUssd(
        titre: 'Top Appel (Voix)',
        type: ActionType.bundle,
        icone: Icons.phone_in_talk,
        codeBase: '*199*1#',
        forfaits: [
          Forfait(prix: '100', data: 'Top Appel 100F', duree: '24h', codeUssd: '*199*1*1#'),
          Forfait(prix: '200', data: 'Top Appel 200F', duree: '24h', codeUssd: '*199*1*2#'),
          Forfait(prix: '500', data: 'Top Appel 500F', duree: '7j', codeUssd: '*199*1*3#'),
          Forfait(prix: '1000', data: 'Top Appel 1000F', duree: '30j', codeUssd: '*199*1*4#'),
        ],
      ),
      ActionUssd(
        titre: 'My Mix (Mixte)',
        type: ActionType.bundle,
        icone: Icons.swap_calls_rounded,
        codeBase: '*199*3#',
        forfaits: [
          Forfait(prix: '100', data: 'My Mix 100F', duree: '24h', codeUssd: '*199*3*1#'),
          Forfait(prix: '200', data: 'My Mix 200F', duree: '24h', codeUssd: '*199*3*2#'),
          Forfait(prix: '500', data: 'My Mix 500F', duree: '7j', codeUssd: '*199*3*3#'),
          Forfait(prix: '1000', data: 'My Mix 1000F', duree: '30j', codeUssd: '*199*3*4#'),
        ],
      ),
    ],

    // --- SERVICES MOOV AFRICA BÉNIN ---
    ReseauType.moov: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104#',
      ),
      ActionUssd(
        titre: 'Moov Money (Menu)',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*855#',
      ),
      ActionUssd(
        titre: 'Transfert (Me2U)',
        type: ActionType.transfer,
        template: '*105*{{numero}}*{{montant}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Achat de crédit',
        type: ActionType.credit,
        template: '*106*{{numero}}*{{montant}}*{{pin}}#',
        icone: Icons.phone_android_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Extra Bonus (Net)',
        type: ActionType.bundle,
        icone: Icons.wifi,
        codeBase: '*123#',
        forfaits: [
          Forfait(prix: '100', data: 'Extra 100F', duree: '24h', codeUssd: '*123*1*1*1#'),
          Forfait(prix: '150', data: 'Extra 150F', duree: '24h', codeUssd: '*123*1*1*2#'),
          Forfait(prix: '200', data: 'Extra 200F', duree: '24h', codeUssd: '*123*1*1*3#'),
          Forfait(prix: '300', data: 'Extra 300F', duree: '24h', codeUssd: '*123*1*1*4#'),
          Forfait(prix: '500', data: 'Extra 500F', duree: '3j', codeUssd: '*123*1*1*5#'),
          Forfait(prix: '1000', data: 'Extra 1000F', duree: '7j', codeUssd: '*123*1*2*2#'),
          Forfait(prix: '2000', data: 'Extra 2000F', duree: '7j', codeUssd: '*123*1*2*3#'),
          Forfait(prix: '5000', data: 'Extra 5000F', duree: '30j', codeUssd: '*123*1*3*5#'),
          Forfait(prix: '10000', data: 'Extra 10000F', duree: '30j', codeUssd: '*123*1*3*8#'),
        ],
      ),
      ActionUssd(
        titre: 'Moov Sayaa (Appels)',
        type: ActionType.bundle,
        icone: Icons.phone_in_talk,
        codeBase: '*173*9#',
        forfaits: [
          Forfait(prix: '100', data: 'Sayaa 100F', duree: '24h', codeUssd: '*173*9*100#'),
          Forfait(prix: '150', data: 'Sayaa 150F', duree: '24h', codeUssd: '*173*9*150#'),
          Forfait(prix: '200', data: 'Sayaa 200F', duree: '24h', codeUssd: '*173*9*200#'),
          Forfait(prix: '300', data: 'Sayaa 300F', duree: '24h', codeUssd: '*173*9*300#'),
          Forfait(prix: '500', data: 'Sayaa 500F', duree: '3j', codeUssd: '*173*9*500#'),
          Forfait(prix: '1000', data: 'Sayaa 1000F', duree: '7j', codeUssd: '*173*9*1000#'),
          Forfait(prix: '5000', data: 'Sayaa 5000F', duree: '30j', codeUssd: '*173*9*5000#'),
        ],
      ),
      ActionUssd(
        titre: 'Pass Mixte',
        type: ActionType.bundle,
        icone: Icons.swap_calls_rounded,
        codeBase: '*173#',
        forfaits: [
          Forfait(prix: '100', data: 'Mixte 100F', duree: '24h', codeUssd: '*173*100#'),
          Forfait(prix: '150', data: 'Mixte 150F', duree: '24h', codeUssd: '*173*150#'),
          Forfait(prix: '200', data: 'Mixte 200F', duree: '24h', codeUssd: '*173*200#'),
          Forfait(prix: '500', data: 'Mixte 500F', duree: '72h', codeUssd: '*173*500#'),
          Forfait(prix: '1000', data: 'Mixte 1000F', duree: '7j', codeUssd: '*173*1000#'),
          Forfait(prix: '2500', data: 'Mixte 2500F', duree: '20j', codeUssd: '*173*2500#'),
          Forfait(prix: '5000', data: 'Mixte 5000F', duree: '30j', codeUssd: '*173*5000#'),
        ],
      ),
    ],
  };
}
