import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Aide statique : questions fréquentes, sans dépendance réseau.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faq = <({String question, String answer})>[
    (
      question: 'Comment lancer un code USSD ?',
      answer:
          'Choisissez un opérateur, puis un service. UNIONE lance l’appel '
          'USSD avec Android, comme si vous composiez le code vous-même. '
          'Android affiche ensuite le dialogue de votre opérateur.',
    ),
    (
      question: 'Pourquoi UNIONE demande-t-il l’autorisation Téléphone ?',
      answer:
          'Cette autorisation sert uniquement à lancer l’appel USSD que vous '
          'avez demandé. UNIONE n’accède pas à vos appels et n’enregistre '
          'aucune donnée de communication.',
    ),
    (
      question: 'Pourquoi dois-je parfois choisir une carte SIM ?',
      answer:
          'Le choix de la SIM est géré par Android, dans ses réglages '
          'd’appels. UNIONE ne choisit jamais la carte SIM à votre place. '
          'Si aucune SIM par défaut n’est définie, Android affiche sa propre '
          'fenêtre de choix.',
    ),
    (
      question: 'Un code ne fonctionne plus, que faire ?',
      answer:
          'Faites un appui long sur le service concerné puis choisissez '
          '« Signaler un code qui ne marche plus ». Vous pouvez aussi '
          'utiliser « Signaler un problème » dans Paramètres → Assistance. '
          'Les opérateurs modifient parfois leurs codes sans préavis.',
    ),
    (
      question: 'UNIONE enregistre-t-il mes numéros ou mes montants ?',
      answer:
          'Non. L’historique conserve le service et l’opérateur, jamais les '
          'numéros, les montants ou les codes PIN saisis.',
    ),
    (
      question: 'Pourquoi les tarifs des forfaits peuvent-ils changer ?',
      answer:
          'Les forfaits sont proposés par les opérateurs et peuvent évoluer. '
          'UNIONE affiche la date de dernière vérification et permet de '
          'signaler un tarif incorrect depuis un catalogue.',
    ),
    (
      question: 'UNIONE fonctionne-t-il sans connexion Internet ?',
      answer:
          'Oui, le catalogue principal est embarqué dans l’application. Une '
          'connexion sert seulement à actualiser les catalogues lorsqu’un '
          'serveur est configuré.',
    ),
    (
      question: 'UNIONE est-il une application officielle des opérateurs ?',
      answer:
          'Non. UNIONE est une application indépendante, sans affiliation, '
          'sponsorisation ni approbation de MTN, Moov Africa ou Celtiis.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('help_faq'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _faq.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _faq[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: colorScheme.primary,
                collapsedIconColor: colorScheme.onSurface.withValues(
                  alpha: 0.4,
                ),
                title: Text(
                  item.question,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
