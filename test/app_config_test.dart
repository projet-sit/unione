import 'package:flutter_test/flutter_test.dart';

import 'package:unione/config/app_config.dart';

void main() {
  group('AppConfig — liens WhatsApp', () {
    test('construit un lien wa.me avec le numéro international', () {
      final uri = AppConfig.whatsappUri();

      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/22991831317');
      expect(uri.queryParameters, isEmpty);
    });

    test('encode le message prérempli sans le laisser brut', () {
      const message = 'Bonjour & test\nDeuxième ligne';
      final uri = AppConfig.whatsappUri(message: message);
      final raw = uri.toString();

      expect(uri.queryParameters['text'], message);
      expect(raw, contains('%26'));
      expect(raw, contains('%0A'));
      expect(raw, isNot(contains('\n')));
    });

    test('construit le lien direct vers l’application WhatsApp', () {
      final uri = AppConfig.whatsappAppUri(message: 'Salut');

      expect(uri.scheme, 'whatsapp');
      expect(uri.host, 'send');
      expect(uri.queryParameters['phone'], AppConfig.whatsappNumber);
      expect(uri.queryParameters['text'], 'Salut');
    });
  });

  group('AppConfig — partage', () {
    test('ne diffuse jamais le marqueur technique de lien manquant', () {
      expect(AppConfig.shareText, contains('UNIONE'));
      expect(AppConfig.shareText, isNot(contains('TODO_REMPLACER')));
    });

    test('le message de partage tient en quelques lignes', () {
      expect(AppConfig.shareText.split('\n').length, lessThanOrEqualTo(2));
    });
  });

  group('AppConfig — signalements', () {
    test('le signalement de problème contient la version et le modèle', () {
      final message = AppConfig.reportProblemMessage(
        androidVersion: '14',
        model: 'Pixel 7',
      );

      expect(message, contains(AppConfig.appVersion));
      expect(message, contains('Android : 14'));
      expect(message, contains('Modèle : Pixel 7'));
    });

    test('le signalement de code conserve le service et le code', () {
      final message = AppConfig.reportCodeMessage(
        operatorName: 'MTN',
        path: 'MTN › Solde',
        service: 'Solde principal',
        code: '*111#',
        treeVersion: '12',
      );

      expect(message, contains('MTN › Solde'));
      expect(message, contains('Solde principal'));
      expect(message, contains('*111#'));
      expect(message, contains('Version du JSON : 12'));
    });
  });
}
