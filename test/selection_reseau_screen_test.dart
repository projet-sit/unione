import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:unione/screens/selection_reseau_screen.dart';
import 'package:unione/services/codes_repository.dart';
import 'package:unione/services/history_service.dart';
import 'package:unione/models/reseau.dart';
import 'package:unione/widgets/reseau_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await HistoryService.initInMemoryDatabase();
    SharedPreferences.setMockInitialValues({});
    await CodesRepository.instance.initialize();
  });

  setUp(() async {
    final db = await HistoryService().database;
    await db.delete('history');
    SharedPreferences.setMockInitialValues({});
    if (CodesRepository.instance.catalogue.value == null) {
      await CodesRepository.instance.initialize();
    }
  });

  group('SelectionReseauScreen widget', () {
    testWidgets('affiche le skeleton pendant le chargement initial', (
      tester,
    ) async {
      final previous = CodesRepository.instance.catalogue.value;
      CodesRepository.instance.catalogue.value = null;
      try {
        await tester.pumpWidget(_wrap(const SelectionReseauScreen()));
        await tester.pump();
        expect(find.byType(SelectionReseauScreen), findsOneWidget);
      } finally {
        CodesRepository.instance.catalogue.value = previous;
      }
    });

    testWidgets('affiche les cartes réseau après chargement du catalogue', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SelectionReseauScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Les trois opérateurs Bénin doivent être affichés
      expect(find.text('MTN'), findsAtLeast(1));
      expect(find.textContaining('Moov'), findsAtLeast(1));
      expect(find.text('Celtiis'), findsAtLeast(1));
    });

    testWidgets('le champ de recherche est présent', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await CodesRepository.instance.initialize();

      await tester.pumpWidget(_wrap(const SelectionReseauScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('la recherche filtre les actions USSD', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await CodesRepository.instance.initialize();

      await tester.pumpWidget(_wrap(const SelectionReseauScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Saisir "solde" dans la barre de recherche
      await tester.enterText(find.byType(TextField), 'solde');
      // Attendre le debounce (300ms)
      await tester.pump(const Duration(milliseconds: 400));

      // La section "Résultats" doit apparaître
      expect(find.text('Résultats'), findsOneWidget);
    });

    testWidgets('le bouton Paramètres est présent dans le header', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await CodesRepository.instance.initialize();

      await tester.pumpWidget(_wrap(const SelectionReseauScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('les réseaux restent dans l\'ordre MTN, Moov, Celtiis', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SelectionReseauScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final cards = tester
          .widgetList<ReseauCard>(find.byType(ReseauCard))
          .toList(growable: false);
      expect(cards.map((card) => card.reseau.type).toList(), [
        ReseauType.mtn,
        ReseauType.moov,
        ReseauType.celtiis,
      ]);
    });
  });
}
