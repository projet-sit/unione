import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unione/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeService', () {
    test('defaults to light theme', () {
      final service = ThemeService();
      expect(service.themeMode, ThemeMode.light);
      expect(service.isDarkMode, isFalse);
    });

    test('updates theme mode and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ThemeService();

      int notifications = 0;
      service.addListener(() => notifications++);

      await service.setThemeMode(ThemeMode.dark);

      expect(service.themeMode, ThemeMode.dark);
      expect(service.isDarkMode, isTrue);
      expect(notifications, greaterThanOrEqualTo(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });
  });
}
