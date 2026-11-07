import 'package:flutter_test/flutter_test.dart';

import 'package:unione/models/catalog_model.dart';
import 'package:unione/widgets/service_launcher.dart';

void main() {
  group('ServiceLauncher.resolveOfferCode', () {
    OfferModel offer({
      int price = 500,
      CatalogLaunch? launch,
      List<CatalogPaymentOption>? payWith,
    }) => OfferModel(
      id: 'offer',
      tab: 'daily',
      price: price,
      title: 'Test',
      confidence: 'official',
      launch: launch,
      payWith: payWith,
    );

    CatalogModel catalog({
      String launchCode = '*123#',
      String launchMode = 'menu',
      List<CatalogPaymentOption> payWith = const [],
      OfferModel? withOffer,
    }) => CatalogModel(
      id: 'catalog',
      operator: 'moov',
      label: 'Catalogue test',
      tabs: const [CatalogTab(id: 'daily', label: 'Quotidien')],
      launch: CatalogLaunch(mode: launchMode, code: launchCode),
      payWith: payWith,
      offers: [withOffer ?? offer()],
    );

    test('utilise offer.launch en priorité', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(
          launchCode: '*123#',
          payWith: const [
            CatalogPaymentOption(
              id: 'moov_money',
              label: 'Moov Money',
              code: '*855*3*2#',
            ),
          ],
        ),
        offer: offer(
          launch: const CatalogLaunch(mode: 'menu', code: '*199*2#'),
        ),
        selectedId: 'moov_money',
      );

      expect(code, '*199*2#');
    });

    test('utilise offer.payWith spécifique avant le catalogue', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(launchCode: '*123#'),
        offer: offer(
          payWith: const [
            CatalogPaymentOption(
              id: 'momo',
              label: 'MTN MoMo',
              code: '*880*173*77*{price}#',
            ),
          ],
        ),
        selectedId: 'momo',
      );

      expect(code, '*880*173*77*500#');
    });

    test(
      'une option générique ne remplace pas la destination du catalogue',
      () {
        final code = ServiceLauncher.resolveOfferCode(
          catalog: catalog(
            launchCode: '*123*9#',
            payWith: const [
              CatalogPaymentOption(
                id: 'airtime',
                label: 'Crédit principal',
                code: '*123#',
              ),
              CatalogPaymentOption(
                id: 'moov_money',
                label: 'Moov Money',
                code: '*855*3*2#',
              ),
            ],
          ),
          offer: offer(),
          selectedId: 'moov_money',
        );

        expect(code, '*123*9#');
      },
    );

    test('une option de catalogue contenant {price} reste prioritaire', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(
          launchCode: '*123#',
          payWith: const [
            CatalogPaymentOption(
              id: 'airtime',
              label: 'Crédit principal',
              code: '*123*77*{price}#',
            ),
            CatalogPaymentOption(
              id: 'momo',
              label: 'MTN MoMo',
              code: '*880*123*77*{price}#',
            ),
          ],
        ),
        offer: offer(),
        selectedId: 'momo',
      );

      expect(code, '*880*123*77*500#');
    });

    test('retombe sur catalog.launch quand aucune option spécifique', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(launchCode: '*172*77*{price}#', launchMode: 'direct'),
        offer: offer(),
        selectedId: null,
      );

      expect(code, '*172*77*500#');
    });

    test('un code catalogue fixe est lancé tel quel', () {
      final code = ServiceLauncher.resolveOfferCode(
        catalog: catalog(launchCode: '*123*5#'),
        offer: offer(),
        selectedId: null,
      );

      expect(code, '*123*5#');
    });
  });
}
