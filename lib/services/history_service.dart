import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_item.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  static Database? _database;

  factory HistoryService() {
    return _instance;
  }

  HistoryService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'zoli_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            timestamp TEXT,
            network TEXT,
            type INTEGER
          )
          ''',
        );
      },
    );
  }

  Future<void> logEvent({
    required String title,
    required String description,
    String? network,
    required HistoryType type,
  }) async {
    final db = await database;
    final item = HistoryItem(
      title: title,
      description: description,
      timestamp: DateTime.now(),
      network: network,
      type: type,
    );
    await db.insert(
      'history',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryItem>> getHistory({
    String? query,
    String? network,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += '(title LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    if (network != null && network.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'network = ?';
      whereArgs.add(network);
    }

    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return HistoryItem.fromMap(maps[i]);
    });
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}
