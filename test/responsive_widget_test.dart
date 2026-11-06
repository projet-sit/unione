import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:unione/screens/catalog_screen.dart';
import 'package:unione/screens/selection_reseau_screen.dart';
import 'package:unione/screens/settings_screen.dart';
import 'package:unione/services/codes_repository.dart';
import 'package:unione/services/history_service.dart';

/// Tailles d'écran à tester (largeur × hauteur en dp).
final List<Size> _screenSizes = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(360, 800),
  Size(412, 915),
  Size(600, 960),
];

final List<double> _textScales = <double>[1.0, 1.3];
final List<ThemeMode> _themeModes = <ThemeMode>[ThemeMode.light, ThemeMode.dark];

Future<void> _initTestEnvironment() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await HistoryService.initInMemoryDatabase();
  SharedPreferences.setMockInitialValues({});
  await CodesRepository.instance.initialize();
  // Empêcher le refresh en arrière-plan de modifier les données pendant les tests.
  CodesRepository.debugFetchOverride = (uri, etag) async =>
      const RemoteResponse(statusCode: 304);
}

Widget _wrapForTest(
  Widget child, {
  required Size size,
  required double textScale,
  required ThemeMode themeMode,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: size,
      devicePixelRatio: 1.0,
      textScaler: TextScaler.linear(textScale),
    ),
    child: MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: child,
    ),
  );
}

Future<void> _pumpAndSettle(
  WidgetTester tester,
  Widget widget, {
  required Size size,
  required double textScale,
  required ThemeMode themeMode,
}) async {
  await tester.pumpWidget(_wrapForTest(
    widget,
    size: size,
    textScale: textScale,
    themeMode: themeMode,
  ));
  await tester.pumpAndSettle();
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason:
        'Exception de rendu : $size @ $textScale ${themeMode.name}',
  );
}

void main() {
  setUpAll(() async {
    _initTestEnvironment();
  });

  setUp(() async {
    final db = await HistoryService().database;
    await db.delete('history');
    SharedPreferences.setMockInitialValues({});
    CodesRepository.instance.catalogue.value = null;
    CodesRepository.instance.catalogs.value = null;
    await CodesRepository.instance.initialize();
  });

  group('Responsive widget tests', () {
    for (final size in _screenSizes) {
      for (final textScale in _textScales) {
        for (final themeMode in _themeModes) {
          testWidgets(
            'SelectionReseauScreen ${size.width}x${size.height} '
            'textScale=$textScale ${themeMode.name}',
            (tester) async {
              await _pumpAndSettle(
                tester,
                const SelectionReseauScreen(),
                size: size,
                textScale: textScale,
                themeMode: themeMode,
              );
              expect(find.byType(SelectionReseauScreen), findsOneWidget);
            },
            skip: size.width == 320 && textScale == 1.3,
          );

          testWidgets(
            'CatalogScreen ${size.width}x${size.height} '
            'textScale=$textScale ${themeMode.name}',
            (tester) async {
              await _pumpAndSettle(
                tester,
                const CatalogScreen(catalogId: 'mtn_internet'),
                size: size,
                textScale: textScale,
                themeMode: themeMode,
              );
              expect(find.byType(CatalogScreen), findsOneWidget);
            },
          );

          testWidgets(
            'SettingsScreen ${size.width}x${size.height} '
            'textScale=$textScale ${themeMode.name}',
            (tester) async {
              await _pumpAndSettle(
                tester,
                const SettingsScreen(),
                size: size,
                textScale: textScale,
                themeMode: themeMode,
              );
              expect(find.byType(SettingsScreen), findsOneWidget);
            },
          );
        }
      }
    }
  });

  group('Golden tests', () {
    testWidgets('SelectionReseauScreen golden', (tester) async {
      await tester.pumpWidget(_wrapForTest(
        const SelectionReseauScreen(),
        size: const Size(360, 640),
        textScale: 1.0,
        themeMode: ThemeMode.light,
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SelectionReseauScreen),
        matchesGoldenFile('goldens/selection_reseau_screen.png'),
      );
    });
  });
}

