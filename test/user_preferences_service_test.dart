import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unione/services/user_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserPreferencesService', () {
    test('starts with empty favorites', () async {
      final service = UserPreferencesService.instance;
      final favorites = await service.favorites();
      expect(favorites, isEmpty);
    });

    test('toggles favorite correctly', () async {
      final service = UserPreferencesService.instance;

      final added = await service.toggleFavorite('mtn_solde');
      expect(added, isTrue);
      expect(await service.favorites(), contains('mtn_solde'));

      final removed = await service.toggleFavorite('mtn_solde');
      expect(removed, isFalse);
      expect(await service.favorites(), isNot(contains('mtn_solde')));
    });

    test('saves and retrieves last SIM by operator', () async {
      final service = UserPreferencesService.instance;

      expect(await service.lastSim('mtn'), isNull);

      await service.saveLastSim('mtn', 2);
      expect(await service.lastSim('mtn'), 2);

      await service.saveLastSim('moov', 1);
      expect(await service.lastSim('moov'), 1);
      expect(await service.lastSim('mtn'), 2);
    });
  });
}
