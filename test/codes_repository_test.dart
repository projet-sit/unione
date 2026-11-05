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
        'ussd_tree_v4': '{"invalid": json}',
      });

      final repository = CodesRepository.instance;
      await repository.initialize();

      expect(repository.catalogue.value, isNotNull);
      expect(repository.catalogue.value!.operators, isNotEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('ussd_tree_v4'), isFalse);
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
              }
            ],
          }
        ],
      });

      SharedPreferences.setMockInitialValues({
        'ussd_tree_v4': validJson,
      });

      final repository = CodesRepository.instance;
      await repository.initialize();

      expect(repository.catalogue.value, isNotNull);
      expect(repository.catalogue.value!.version, 99);
      expect(repository.catalogue.value!.node('mtn_solde_custom'), isNotNull);
    });
  });
}
