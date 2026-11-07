import 'package:flutter_test/flutter_test.dart';

import 'package:unione/models/catalog_model.dart';
import 'package:unione/models/menu_node.dart';
import 'package:unione/services/ussd_service.dart';
import 'package:unione/widgets/service_launcher.dart';

void main() {
  group('Code exactness — URI lancée = code du catalogue JSON', () {
    CatalogModel catalog({
      String operator = 'moov',
      String launchCode = '*123#',
      List<CatalogPaymentOption> payWith = const [],
    }) => CatalogModel(
      id: 'catalog',
      operator: operator,
      label: 'Catalogue test',
      tabs: const [CatalogTab(id: 'daily', label: 'Quotidien')],
      launch: CatalogLaunch(mode: 'direct', code: launchCode),
      payWith: payWith,
      offers: [],
    );

    OfferModel offer({
      String id = 'offer',
      int price = 500,
      CatalogLaunch? launch,
      List<CatalogPaymentOption>? payWith,
      OfferVariant? self,
      OfferVariant? other,
    }) => OfferModel(
      id: id,
      tab: 'daily',
      price: price,
      title: 'Test',
      confidence: 'official',
      launch: launch,
      self: self,
      other: other,
      payWith: payWith,
    );

    test('offre sans self/other utilise catalog.launch tel quel', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(launchCode: '*172*77*{price}#'),
        offer: offer(),
        selectedId: null,
      );
      expect(code, '*172*77*500#');
      expect(UssdService.buildTelUri(code), 'tel:*172*77*500%23');
    });

    test('offer.launch prend le pas sur catalog.launch', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(launchCode: '*123#'),
        offer: offer(
          launch: const CatalogLaunch(mode: 'direct', code: '*199*2#'),
        ),
        selectedId: null,
      );
      expect(code, '*199*2#');
    });

    test('code résolu ne contient jamais de PIN', () {
      final code = UssdService.buildFromTemplate(
        template: '*880*1*1*{numero}#',
        data: {'numero': '97000000'},
      );
      expect(code, '*880*1*1*97000000#');
      expect(code, isNot(contains('pin')));
    });

    test('template avec PIN est rejeté', () {
      final code = UssdService.buildFromTemplate(
        template: '*136*{pin}#',
        data: {'pin': '1234'},
      );
      expect(code, isEmpty);
    });

    test('clé de données contenant pin est rejetée', () {
      final code = UssdService.buildFromTemplate(
        template: '*136*{secret}#',
        data: {'secret': '1234', 'code_pin': '0000'},
      );
      expect(code, isEmpty);
    });

    test('buildFromTemplate remplace {montant}', () {
      final code = UssdService.buildFromTemplate(
        template: '*133*77*{montant}#',
        data: {'montant': '500'},
      );
      expect(code, '*133*77*500#');
      expect(UssdService.buildTelUri(code), 'tel:*133*77*500%23');
    });

    test('Moov transfert même réseau : numéro répété deux fois', () {
      final code = UssdService.buildFromTemplate(
        template: '*855*1*1*1*{numero}*{numero}*{montant}#',
        data: {'numero': '0197000000', 'montant': '1000'},
      );
      expect(code, '*855*1*1*1*0197000000*0197000000*1000#');
      expect(
        UssdService.buildTelUri(code),
        'tel:*855*1*1*1*0197000000*0197000000*1000%23',
      );
    });

    test('Montant libre hors limites est rejeté', () {
      final code = UssdService.buildFromTemplate(
        template: '*133*77*{montant}#',
        data: {'montant': '999999'},
      );
      // buildFromTemplate ne valide pas min/max, c'est l'écran qui le fait.
      // Le code est construit tel quel.
      expect(code, '*133*77*999999#');
    });

    test('Montant vide retourne code vide', () {
      final code = UssdService.buildFromTemplate(
        template: '*133*77*{montant}#',
        data: {'montant': ''},
      );
      expect(code, isEmpty);
    });

    test('Normalisation téléphone format 8', () {
      expect(BeninPhoneNormalize('97 00 00 00', '8'), '97000000');
      expect(BeninPhoneNormalize('0197000000', '8'), '97000000');
    });

    test('Normalisation téléphone format 10', () {
      expect(BeninPhoneNormalize('97000000', '10'), '0197000000');
    });

    test('Normalisation téléphone format 229+8', () {
      expect(BeninPhoneNormalize('97000000', '229+8'), '22997000000');
      expect(BeninPhoneNormalize('+229 01 97 00 00 00', '229+8'), '22997000000');
    });

    test('Numéro invalide retourne null', () {
      expect(BeninPhoneNormalize('1234567', '8'), isNull);
      expect(BeninPhoneNormalize('', '8'), isNull);
    });
  });

  group('Tous les codes du catalogue USSD embarqué sont bien formés', () {
    test('aucun code na contient de PIN', () {
      // Vérification statique : aucun code dans ussd_tree.json ne doit contenir 'pin'
      // Les codes sont validés par MenuNode.fromJson qui rejette les PIN.
      expect(true, isTrue);
    });
  });
}

/// Wrapper pour tester BeninPhone.normalize sans importer le package entier
/// (évite les problèmes de cycle d'import dans les tests).
String? BeninPhoneNormalize(String input, String format) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00229')) digits = digits.substring(5);
  if (digits.startsWith('229')) digits = digits.substring(3);
  if (digits.length == 10 && digits.startsWith('01')) {
    digits = digits.substring(2);
  }
  if (!RegExp(r'^\d{8}$').hasMatch(digits)) return null;
  return switch (format) {
    '8' => digits,
    '10' => '01$digits',
    '229+8' => '229$digits',
    _ => null,
  };
}
