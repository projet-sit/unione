import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unione/services/codes_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CodesRepository', () {
    test('initializes and loads catalogue correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = CodesRepository.instance;

      await repository.initialize();

      expect(repository.catalogue.value, isNotNull);
      final tree = repository.catalogue.value!;
      expect(tree.version, greaterThanOrEqualTo(4));
      expect(tree.operators, isNotEmpty);
      expect(tree.actions, isNotEmpty);
    });

    test('cleans corrupted cache and falls back to bundled tree', () async {
      SharedPreferences.setMockInitialValues({
        'ussd_tree_v5': '{"invalid": json}',
      });

      final repository = CodesRepository.instance;
      await repository.initialize();

      expect(repository.catalogue.value, isNotNull);
      expect(repository.catalogue.value!.operators, isNotEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('ussd_tree_v5'), isFalse);
    });

    test('decodes valid cached tree when present', () async {
      final validJson = jsonEncode({
        'version': 99,
        'updatedAt': '2026-11-06',
        'operators': [
          {
            'id': 'mtn',
            'name': 'MTN',
            'country': 'Bénin',
            'color': '#FFCC00',
            'rootCode': '*199#',
            'children': [
              {
                'id': 'mtn_solde_custom',
                'type': 'action',
                'label': 'Solde Custom',
                'icon': 'bank',
                'status': 'ok',
                'confidence': 'high',
                'code': '*126#',
                'params': [],
              },
            ],
          },
        ],
      });

      SharedPreferences.setMockInitialValues({'ussd_tree_v5': validJson});

      final repository = CodesRepository.instance;
      await repository.initialize();

      expect(repository.catalogue.value, isNotNull);
      expect(repository.catalogue.value!.version, 99);
      expect(repository.catalogue.value!.node('mtn_solde_custom'), isNotNull);
    });

    test(
      'un catalogue embarqué plus récent remplace un ancien cache',
      () async {
        final oldCache = jsonEncode({
          'version': 1,
          'catalogs': {
            'ancien_catalogue': {
              'operator': 'mtn',
              'label': 'Ancien',
              'tabs': [
                {'id': 'daily', 'label': 'Quotidien'},
              ],
              'launch': {'mode': 'menu', 'code': '*123#'},
              'offers': [
                {
                  'id': 'ancien_offre',
                  'tab': 'daily',
                  'price': 100,
                  'title': 'Ancien',
                  'confidence': 'to_test',
                },
              ],
            },
          },
        });
        SharedPreferences.setMockInitialValues({'catalogs_v1': oldCache});

        final repository = CodesRepository.instance;
        repository.catalogue.value = null;
        repository.catalogs.value = null;
        await repository.initialize();

        expect(repository.catalogs.value, isNotNull);
        expect(repository.catalogs.value!.version, 3);
        expect(repository.catalogs.value!.catalog('ancien_catalogue'), isNull);
        expect(repository.getCatalog('celtiis_connect'), isNotNull);
        expect(
          repository.findOffer('celtiis_connect_2500')!.confidence,
          'official',
        );
      },
    );

    test('initializes and decodes bundled catalogs correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = CodesRepository.instance;
      await repository.initialize();

      expect(repository.catalogs.value, isNotNull);
      final catalogsData = repository.catalogs.value!;
      expect(catalogsData.version, greaterThanOrEqualTo(1));
      expect(catalogsData.catalogs.length, greaterThanOrEqualTo(10));

      final celtiisConnect = repository.getCatalog('celtiis_connect');
      expect(celtiisConnect, isNotNull);
      expect(celtiisConnect!.operator, 'celtiis');
      expect(celtiisConnect.tabs, isNotEmpty);
      expect(celtiisConnect.offers, isNotEmpty);
      expect(celtiisConnect.launch.mode, 'menu');
      expect(celtiisConnect.launch.code, '*199*2#');
      expect(celtiisConnect.bestValueOfferId, isNotNull);

      final mtnIllimite = repository.getCatalog('mtn_illimite');
      expect(mtnIllimite, isNotNull);
      expect(mtnIllimite!.payWith, isNotEmpty);
      expect(mtnIllimite.payWith.first.id, 'airtime');
      expect(mtnIllimite.payWith.last.id, 'momo');

      final foundOffer = repository.findOffer('celtiis_connect_500');
      expect(foundOffer, isNotNull);
      expect(foundOffer!.price, 500);
      expect(foundOffer.title, '1 Go');
    });
  });
}
