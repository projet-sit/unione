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

    test('garde les six derniers récents, sans doublon', () async {
      final service = UserPreferencesService.instance;

      for (var index = 0; index < 8; index++) {
        await service.addRecent('n:service_$index');
      }
      await service.addRecent('n:service_3');

      final recents = await service.recents();
      expect(recents.length, 6);
      expect(recents.first, 'n:service_3');
      expect(recents.where((entry) => entry == 'n:service_3').length, 1);

      await service.clearRecents();
      expect(await service.recents(), isEmpty);
    });

    test('mémorise l’onboarding et l’explication de permission', () async {
      final service = UserPreferencesService.instance;

      expect(await service.onboardingSeen(), isFalse);
      await service.setOnboardingSeen();
      expect(await service.onboardingSeen(), isTrue);

      expect(await service.phonePrimingSeen(), isFalse);
      await service.setPhonePrimingSeen();
      expect(await service.phonePrimingSeen(), isTrue);
    });
  });
}
