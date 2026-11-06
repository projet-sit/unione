import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unione/config/backend_config.dart';
import 'package:unione/services/codes_repository.dart';

String catalogsJson({required int version}) => jsonEncode({
  'version': version,
  'catalogs': {
    'mtn_test': {
      'operator': 'mtn',
      'label': 'Test',
      'tabs': [
        {'id': 'internet', 'label': 'Internet'},
      ],
      'launch': {'mode': 'direct', 'code': '*123#'},
      'payWith': [],
      'offers': [
        {
          'id': 'mtn_test_500',
          'tab': 'internet',
          'price': 500,
          'title': '1 Go',
          'confidence': 'to_test',
        },
      ],
    },
  },
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = CodesRepository.instance;

  setUp(() {
    repository.catalogue.value = null;
    repository.catalogs.value = null;
    BackendConfig.catalogsUrl = 'https://example.com/v1/catalogs';
  });

  tearDown(() {
    CodesRepository.debugFetchOverride = null;
    BackendConfig.catalogsUrl = '';
    repository.catalogue.value = null;
    repository.catalogs.value = null;
  });

  group('Sync distante (GET /v1/catalogs)', () {
    test('304 : rien ne change et l\'ETag stocké est renvoyé', () async {
      SharedPreferences.setMockInitialValues({
        'catalogs_v1': catalogsJson(version: 10),
        'catalogs_v1_etag': '"abc123"',
      });
      String? seenEtag;
      CodesRepository.debugFetchOverride = (uri, etag) async {
        seenEtag = etag;
        return const RemoteResponse(statusCode: 304);
      };

      await repository.initialize();
      await repository.refreshInBackground();

      expect(repository.catalogs.value, isNotNull);
      expect(repository.catalogs.value!.version, 10);
      expect(seenEtag, '"abc123"');
    });

    test('JSON invalide : le cache est conservé', () async {
      SharedPreferences.setMockInitialValues({
        'catalogs_v1': catalogsJson(version: 10),
      });
      CodesRepository.debugFetchOverride = (uri, etag) async =>
          const RemoteResponse(
            statusCode: 200,
            body: '{"version": 11, "catalogs": {',
          );

      await repository.initialize();
      await repository.refreshInBackground();

      expect(repository.catalogs.value!.version, 10);
    });

    test('version plus ancienne : rejetée', () async {
      SharedPreferences.setMockInitialValues({
        'catalogs_v1': catalogsJson(version: 10),
      });
      CodesRepository.debugFetchOverride = (uri, etag) async => RemoteResponse(
        statusCode: 200,
        etag: '"v9"',
        body: catalogsJson(version: 9),
      );

      await repository.initialize();
      await repository.refreshInBackground();

      expect(repository.catalogs.value!.version, 10);
    });

    test('version plus récente : appliquée et mise en cache', () async {
      SharedPreferences.setMockInitialValues({
        'catalogs_v1': catalogsJson(version: 10),
      });
      final fresh = catalogsJson(version: 11);
      CodesRepository.debugFetchOverride = (uri, etag) async =>
          RemoteResponse(statusCode: 200, etag: '"v11"', body: fresh);

      await repository.initialize();
      await repository.refreshInBackground();

      expect(repository.catalogs.value!.version, 11);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('catalogs_v1'), fresh);
      expect(prefs.getString('catalogs_v1_etag'), '"v11"');
    });

    test('réseau coupé : le cache est conservé sans erreur', () async {
      SharedPreferences.setMockInitialValues({
        'catalogs_v1': catalogsJson(version: 10),
      });
      CodesRepository.debugFetchOverride = (uri, etag) async {
        throw Exception('réseau coupé');
      };

      await repository.initialize();
      await repository.refreshInBackground();

      expect(repository.catalogs.value!.version, 10);
    });

    test(
      'premier lancement hors ligne : le JSON embarqué prend le relais',
      () async {
        SharedPreferences.setMockInitialValues({});
        CodesRepository.debugFetchOverride = (uri, etag) async {
          throw Exception('réseau coupé');
        };

        await repository.initialize();

        expect(repository.catalogs.value, isNotNull);
        expect(repository.catalogs.value!.version, greaterThanOrEqualTo(1));
        expect(repository.catalogs.value!.catalogs, isNotEmpty);
        expect(repository.catalogue.value, isNotNull);
      },
    );
  });
}
