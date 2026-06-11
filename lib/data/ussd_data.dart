import 'package:flutter/material.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';

class UssdData {
  // Définition des réseaux
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

  static final Map<ReseauType, List<ActionUssd>> actions = {
    ReseauType.mtn: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104#',
      ),
      ActionUssd(
        titre: 'Mobile Money',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*880#',
      ),
      ActionUssd(
        titre: 'Transfert crédit',
        type: ActionType.transfer,
        template: '*155*{{montant}}*{{numero}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Achat crédit',
        type: ActionType.credit,
        template: '*155*1*{{montant}}*{{numero}}*{{pin}}#',
        icone: Icons.phone_android_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Emprunter crédit',
        type: ActionType.credit,
        template: '*121*{{montant}}#',
        icone: Icons.access_time_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Forfait',
        type: ActionType.bundle,
        icone: Icons.language_outlined,
        codeBase: '*123#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*103#',
      ),
      ActionUssd(
        titre: 'Service client',
        type: ActionType.information,
        icone: Icons.headset_mic_outlined,
        codeBase: '111',
      ),
    ],

    ReseauType.celtiis: [
      ActionUssd(
        titre: 'Solde principal',
        type: ActionType.information,
        icone: Icons.account_balance_outlined,
        codeBase: '*104*1*1#',
      ),
      ActionUssd(
        titre: 'Solde internet',
        type: ActionType.information,
        icone: Icons.wifi_outlined,
        codeBase: '*104*1*2#',
      ),
      ActionUssd(
        titre: 'Celtiis Cash',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*889#',
      ),
      ActionUssd(
        titre: 'Transfert crédit',
        type: ActionType.transfer,
        template: '*889*3*1*{{numero}}*{{montant}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Prêt de crédit',
        type: ActionType.credit,
        icone: Icons.access_time_outlined,
        codeBase: '*199*7*2#',
      ),
      ActionUssd(
        titre: 'Forfait internet',
        type: ActionType.bundle,
        icone: Icons.language_outlined,
        codeBase: '*199*2#',
      ),
      ActionUssd(
        titre: 'Forfait mixte',
        type: ActionType.bundle,
        icone: Icons.shuffle_outlined,
        codeBase: '*199*3#',
      ),
      ActionUssd(
        titre: 'Top Appel',
        type: ActionType.bundle,
        icone: Icons.phone_outlined,
        codeBase: '*199*1*2#',
      ),
      ActionUssd(
        titre: 'Mon numéro',
        type: ActionType.information,
        icone: Icons.person_pin_outlined,
        codeBase: '*199*7*4#',
      ),
      ActionUssd(
        titre: 'Service client',
        type: ActionType.information,
        icone: Icons.headset_mic_outlined,
        codeBase: '7373',
      ),
    ],

    ReseauType.moov: [
      ActionUssd(
        titre: 'Menu MOOV',
        type: ActionType.information,
        icone: Icons.apps_outlined,
        codeBase: '*221#',
      ),
      ActionUssd(
        titre: 'Moov Money',
        type: ActionType.information,
        icone: Icons.account_balance_wallet_outlined,
        codeBase: '*855#',
      ),
      ActionUssd(
        titre: 'Transfert',
        type: ActionType.transfer,
        template: '*855*1*{{numero}}*{{montant}}*{{pin}}#',
        icone: Icons.send_outlined,
        aBesoinParam: true,
      ),
      ActionUssd(
        titre: 'Forfait voix',
        type: ActionType.bundle,
        icone: Icons.phone_outlined,
        codeBase: '*706#',
      ),
      ActionUssd(
        titre: 'Forfait internet',
        type: ActionType.bundle,
        icone: Icons.language_outlined,
        codeBase: '*715#',
      ),
      ActionUssd(
        titre: 'Forfait mixte',
        type: ActionType.bundle,
        icone: Icons.shuffle_outlined,
        codeBase: '*717#',
      ),
      ActionUssd(
        titre: 'Solde & conso',
        type: ActionType.information,
        icone: Icons.pie_chart_outline_rounded,
        codeBase: '*811#',
      ),
      ActionUssd(
        titre: 'SMS & services',
        type: ActionType.information,
        icone: Icons.sms_outlined,
        codeBase: '*812#',
      ),
      ActionUssd(
        titre: 'Promo & offres',
        type: ActionType.information,
        icone: Icons.local_offer_outlined,
        codeBase: '*702#',
      ),
      ActionUssd(
        titre: 'Service client',
        type: ActionType.information,
        icone: Icons.headset_mic_outlined,
        codeBase: '*708#',
      ),
    ],
  };
}
