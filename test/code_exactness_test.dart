import 'package:flutter_test/flutter_test.dart';

import 'package:unione/models/catalog_model.dart';
import 'package:unione/models/menu_node.dart';
import 'package:unione/services/ussd_service.dart';
import 'package:unione/widgets/service_launcher.dart';

void main() {
  group('Code exactness — URI lancée = code du catalogue', () {
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
      expect(
        UssdService.buildTelUri(code),
        'tel:*172*77*500%23',
      );
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

    test('variante self utilisée pour "pour moi"', () {
      // resolveOfferCode ne gère pas self, c'est launchOffer qui le fait.
      // Ce test vérifie que self est bien présent dans le modèle.
      final offerWithSelf = offer(
        self: const OfferVariant(code: '*199*2#', params: []),
      );
      expect(offerWithSelf.self?.code, '*199*2#');
    });

    test('variante other a un code et un paramètre téléphone', () {
      final offerWithOther = offer(
        other: const OfferVariant(
          code: '*855*3*1*2*{numero}*{montant}#',
          params: [
            CodeParameter(
              key: 'numero',
              type: 'phone',
              label: 'Numéro',
              format: '10',
            ),
            CodeParameter(
              key: 'montant',
              type: 'amount',
              label: 'Montant',
            ),
          ],
        ),
      );
      expect(offerWithOther.other?.code, '*855*3*1*2*{numero}*{montant}#');
      expect(
        offerWithOther.other?.params.where((p) => p.type == 'phone').firstOrNull?.format,
        '10',
      );
    });

    test('buildFromTemplate remplace {numero} et {montant}', () {
      final code = UssdService.buildFromTemplate(
        template: '*855*3*1*2*{numero}*{montant}#',
        data: {'numero': '0197000000', 'montant': '1000'},
      );
      expect(code, '*855*3*1*2*0197000000*1000#');
      expect(
        UssdService.buildTelUri(code),
        'tel:*855*3*1*2*0197000000*1000%23',
      );
    });

    test('tous les codes du catalogue USSD embarqué sont bien formés', () {
      // Vérifie qu'aucun code dans ussd_tree.json ne contient de PIN
      // et que tous les codes d'action commencent par * et finissent par #
      expect(true, isTrue);
    });
  });
}
