import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:unione/screens/history_screen.dart';
import 'package:unione/services/history_service.dart';
import 'package:unione/models/history_item.dart';

/// Wrapper minimaliste pour injecter l'environnement Flutter (Material).
Widget _wrap(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Monte HistoryScreen et attend la fin de la requête SQLite asynchrone.
Future<void> _pumpHistoryScreen(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const HistoryScreen()));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await HistoryService.initInMemoryDatabase();
  });

  setUp(() async {
    final db = await HistoryService().database;
    await db.delete('history');
  });

  group('HistoryScreen widget', () {
    testWidgets('affiche l\'état vide quand l\'historique est vide', (tester) async {
      await _pumpHistoryScreen(tester);

      // La clé de localisation 'no_history' doit être affichée (ou sa valeur brute)
      expect(
        find.byType(HistoryScreen),
        findsOneWidget,
        reason: 'L\'écran HistoryScreen doit être monté',
      );
      expect(find.byIcon(Icons.history_toggle_off_rounded), findsOneWidget);
      expect(find.textContaining('no_history'), findsOneWidget);
    });

    testWidgets('affiche le skeleton pendant le chargement', (tester) async {
      await tester.pumpWidget(_wrap(const HistoryScreen()));
      // Juste après le premier frame, _isLoading == true → skeleton visible
      await tester.pump();

      // On vérifie la présence du ListView dans l'état chargement
      expect(find.byType(ListView), findsAtLeast(1));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('affiche les entrées après chargement', (tester) async {
      // Pré-remplir la base dans le contexte réel d'I/O FFI
      await tester.runAsync(() async {
        await HistoryService().logEvent(
          title: 'history_network_title',
          description: 'history_network_selected|MTN',
          network: 'MTN',
          type: HistoryType.networkSelection,
        );
        await HistoryService().logEvent(
          title: 'history_ussd_title',
          description: 'history_ussd_executed',
          network: 'MOOV',
          type: HistoryType.ussdLaunch,
        );
      });

      await _pumpHistoryScreen(tester);

      // Les deux titres doivent apparaître (clés brutes car pas de EasyLocalization)
      expect(find.textContaining('history_network_title'), findsAtLeast(1));
      expect(find.textContaining('history_ussd_title'), findsAtLeast(1));
    });

    testWidgets('le bouton de suppression est présent dans la AppBar', (tester) async {
      await _pumpHistoryScreen(tester);

      expect(
        find.byIcon(Icons.delete_sweep_outlined),
        findsOneWidget,
        reason: 'Le bouton de suppression doit être dans la barre d\'application',
      );
    });

    testWidgets('le champ de recherche est présent', (tester) async {
      await _pumpHistoryScreen(tester);

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('les deux filtres (date et réseau) sont affichés', (tester) async {
      await _pumpHistoryScreen(tester);

      // Les filtres sont des InkWell avec icônes
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cell_tower_rounded), findsAtLeast(1));
    });
  });
}
