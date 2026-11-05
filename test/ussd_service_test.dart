import 'package:flutter_test/flutter_test.dart';
import 'package:unione/services/benin_phone.dart';
import 'package:unione/services/ussd_service.dart';

void main() {
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
  });

  group('BeninPhone.normalize', () {
    test('accepts national and international Benin formats', () {
      expect(BeninPhone.normalize('97 00 00 00', '10'), '0197000000');
      expect(BeninPhone.normalize('+229 01 97 00 00 00', '8'), '97000000');
      expect(BeninPhone.normalize('00229 01 97 00 00 00', '229+8'), '22997000000');
    });
  });
}
