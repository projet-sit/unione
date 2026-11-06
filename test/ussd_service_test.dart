import 'package:flutter_test/flutter_test.dart';
import 'package:unione/services/android_ussd_gateway.dart';
import 'package:unione/services/benin_phone.dart';
import 'package:unione/services/ussd_service.dart';

void main() {
  group('UssdService.buildTelUri', () {
    test('encode le # et conserve les *', () {
      expect(UssdService.buildTelUri('*880#'), 'tel:*880%23');
    });

    test('encode un code à paramètres et conserve les *', () {
      expect(UssdService.buildTelUri('*880*45#'), 'tel:*880*45%23');
    });

    test('encode un code construit avec des paramètres, sans PIN', () {
      final code = UssdService.buildFromTemplate(
        template: '*880*1*1*{numero}*{montant}#',
        data: {'numero': '97000000', 'montant': '1000'},
      );

      expect(code, '*880*1*1*97000000*1000#');
      expect(
        UssdService.buildTelUri(code),
        'tel:*880*1*1*97000000*1000%23',
      );
    });
  });

  group('operatorIdFromMccMnc', () {
    test('reconnaît les opérateurs béninois', () {
      expect(operatorIdFromMccMnc('61602'), 'moov');
      expect(operatorIdFromMccMnc('61603'), 'mtn');
      expect(operatorIdFromMccMnc('61607'), 'celtiis');
    });

    test('ignore les codes inconnus ou vides', () {
      expect(operatorIdFromMccMnc(null), isNull);
      expect(operatorIdFromMccMnc(''), isNull);
      expect(operatorIdFromMccMnc('61604'), isNull);
    });
  });

  group('UssdService.buildFromTemplate', () {
    test('builds a parameterized code without PIN', () {
      final template = '*880*1*1*{numero}*{montant}#';
      final data = {'numero': '97000000', 'montant': '1000'};

      final code = UssdService.buildFromTemplate(
        template: template,
        data: data,
      );

      expect(code, '*880*1*1*97000000*1000#');
    });

    test('builds MOOV transfer code', () {
      final template = '*855*1*{numero}*{montant}#';
      final data = {'numero': '96000000', 'montant': '500'};

      final code = UssdService.buildFromTemplate(
        template: template,
        data: data,
      );

      expect(code, '*855*1*96000000*500#');
    });

    test('returns empty code when a required field is missing in data map', () {
      final template = '*104*3*1*{{0}}*{{1}}#';
      final data = {
        '0': '95000000',
        // '1' is missing
      };

      final code = UssdService.buildFromTemplate(
        template: template,
        data: data,
      );

      expect(code, isEmpty);
    });

    test('rejette les templates contenant "pin"', () {
      final code = UssdService.buildFromTemplate(
        template: '*136*{pin}#',
        data: {'pin': '1234'},
      );
      expect(code, isEmpty);
    });

    test('rejette les templates dont les clés data contiennent "pin"', () {
      final code = UssdService.buildFromTemplate(
        template: '*136*{secret}#',
        data: {'secret': '1234', 'code_pin': '0000'},
      );
      expect(code, isEmpty);
    });
  });

  group('BeninPhone.normalize', () {
    test('accepts national and international Benin formats', () {
      expect(BeninPhone.normalize('97 00 00 00', '10'), '0197000000');
      expect(BeninPhone.normalize('+229 01 97 00 00 00', '8'), '97000000');
      expect(BeninPhone.normalize('00229 01 97 00 00 00', '229+8'), '22997000000');
    });

    test('retourne null pour une chaîne vide', () {
      expect(BeninPhone.normalize('', '8'), isNull);
    });

    test('retourne null pour un numéro non béninois (7 chiffres)', () {
      expect(BeninPhone.normalize('1234567', '8'), isNull);
    });

    test('retourne null pour un format inconnu', () {
      expect(BeninPhone.normalize('97000000', 'unknown'), isNull);
    });

    test('format "8" avec saisie 10 chiffres (préfixe 01)', () {
      expect(BeninPhone.normalize('0197000000', '8'), '97000000');
    });

    test('format "10" avec 8 chiffres en entrée', () {
      expect(BeninPhone.normalize('97000000', '10'), '0197000000');
    });

    test('format "229+8" avec 8 chiffres en entrée', () {
      expect(BeninPhone.normalize('97000000', '229+8'), '22997000000');
    });
  });
}

