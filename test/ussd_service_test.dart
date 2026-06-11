import 'package:flutter_test/flutter_test.dart';
import 'package:zoli/services/ussd_service.dart';

void main() {
  group('UssdService.buildFromTemplate', () {
    test('builds MTN MoMo transfer code with sanitized input', () {
      final template = '*880*1*1*{{0}}*{{1}}*{{pin}}#';
      final data = {
        '0': '97 00 00 00',
        '1': '1 000',
        'pin': ' 1234 ',
      };
      
      final code = UssdService.buildFromTemplate(
        template: template,
        data: data,
      );

      expect(code, '*880*1*1*97000000*1000*1234#');
    });

    test('builds MOOV transfer code', () {
      final template = '*855*1*{{0}}*{{1}}*{{pin}}#';
      final data = {
        '0': '96000000',
        '1': '500',
        'pin': '1234',
      };
      
      final code = UssdService.buildFromTemplate(
        template: template,
        data: data,
      );

      expect(code, '*855*1*96000000*500*1234#');
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
}
