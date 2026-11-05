import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_item.dart';

/// Service gérant la persistance de l'historique des activités de l'utilisateur.
/// Utilise une base de données SQLite locale pour stocker les événements.
class HistoryService {
  /// Instance unique (singleton) du service d'historique.
  static final HistoryService _instance = HistoryService._internal();
  static Database? _database;

  factory HistoryService() {
    return _instance;
  }

  HistoryService._internal();

  /// Récupère l'instance de la base de données, en l'initialisant si nécessaire.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données SQLite 'unione_history.db'.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'unione_history.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        // Création de la table 'history' lors du premier lancement.
        return db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            timestamp TEXT,
            network TEXT,
            service_id TEXT,
            type INTEGER
          )
          ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await db.execute('ALTER TABLE history ADD COLUMN service_id TEXT');
      },
    );
  }

  /// Enregistre un nouvel événement dans l'historique.
  /// [title] : Le titre de l'action.
  /// [description] : Détails de l'action (peut être formaté pour la traduction).
  /// [network] : Le réseau concerné (optionnel).
  /// [type] : Le type d'activité (Sélection réseau, Lancement USSD, etc.).
  Future<void> logEvent({
    required String title,
    required String description,
    String? network,
    String? serviceId,
    required HistoryType type,
  }) async {
    final db = await database;
    final item = HistoryItem(
      title: title,
      description: description,
      timestamp: DateTime.now(),
      network: network,
      serviceId: serviceId,
      type: type,
    );
    // Insertion de l'entrée dans la base de données.
    await db.insert(
      'history',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère la liste filtrée de l'historique.
  /// Permet la recherche par texte, par réseau et par plage de dates.
  Future<List<HistoryItem>> getHistory({
    String? query,
    String? network,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    // Filtre de recherche textuelle
    if (query != null && query.isNotEmpty) {
      whereClause += '(title LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    // Filtre par réseau (MTN, MOOV, CELTIIS)
    if (network != null && network.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'network = ?';
      whereArgs.add(network);
    }

    // Filtre par date de début
    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    // Filtre par date de fin
    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    // Exécution de la requête avec tri antéchronologique (le plus récent en premier)
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
    );

    // Conversion des résultats SQL en objets HistoryItem
    return List.generate(maps.length, (i) {
      return HistoryItem.fromMap(maps[i]);
    });
  }

  /// Supprime toutes les entrées de l'historique.
  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}
