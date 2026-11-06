import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unione/models/history_item.dart';
import 'package:unione/services/history_service.dart';

/// Initialise SQLite en mode FFI pour l'environnement de test desktop.
void _setupSqfliteFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  setUpAll(() async {
    _setupSqfliteFfi();
    await HistoryService.initInMemoryDatabase();
  });

  // Réinitialise l'instance singleton entre chaque test pour isoler les états.
  setUp(() async {
    final db = await HistoryService().database;
    await db.delete('history');
  });

  group('HistoryService', () {
    test('démarre avec un historique vide', () async {
      final items = await HistoryService().getHistory();
      expect(items, isEmpty);
    });

    test('enregistre et récupère un événement', () async {
      await HistoryService().logEvent(
        title: 'Test',
        description: 'Description test',
        network: 'MTN',
        type: HistoryType.ussdLaunch,
      );

      final items = await HistoryService().getHistory();
      expect(items.length, 1);
      expect(items.first.title, 'Test');
      expect(items.first.network, 'MTN');
      expect(items.first.type, HistoryType.ussdLaunch);
    });

    test('filtre par réseau', () async {
      await HistoryService().logEvent(
        title: 'MTN Action',
        description: '',
        network: 'mtn',
        type: HistoryType.ussdLaunch,
      );
      await HistoryService().logEvent(
        title: 'Moov Action',
        description: '',
        network: 'moov',
        type: HistoryType.ussdLaunch,
      );

      final mtnItems = await HistoryService().getHistory(network: 'mtn');
      expect(mtnItems.length, 1);
      expect(mtnItems.first.title, 'MTN Action');
    });

    test('filtre par plage de dates', () async {
      await HistoryService().logEvent(
        title: 'Ancien',
        description: '',
        type: HistoryType.networkSelection,
      );
      // On attend 10ms pour garantir un timestamp distinct.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final cutoff = DateTime.now();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await HistoryService().logEvent(
        title: 'Récent',
        description: '',
        type: HistoryType.networkSelection,
      );

      final recents = await HistoryService().getHistory(startDate: cutoff);
      expect(recents.length, 1);
      expect(recents.first.title, 'Récent');
    });

    test('efface tout l\'historique', () async {
      await HistoryService().logEvent(
        title: 'À effacer',
        description: '',
        type: HistoryType.other,
      );
      await HistoryService().clearHistory();

      final items = await HistoryService().getHistory();
      expect(items, isEmpty);
    });

    test('filtre par texte dans le titre', () async {
      await HistoryService().logEvent(
        title: 'Solde MTN',
        description: 'Consultation solde',
        type: HistoryType.ussdLaunch,
      );
      await HistoryService().logEvent(
        title: 'Transfert Moov',
        description: 'Envoi argent',
        type: HistoryType.ussdLaunch,
      );

      final results = await HistoryService().getHistory(query: 'solde');
      expect(results.length, 1);
      expect(results.first.title, 'Solde MTN');
    });
  });
}
