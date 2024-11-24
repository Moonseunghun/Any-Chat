import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<void> getDatabase() async {
    if (_database != null) return;

    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'anychat.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ChatRoomInfo (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            lastMessage TEXT,
            profileImg TEXT,
            updatedAt TEXT,
            unreadCount INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    await _database!.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> search(String table) async {
    return await _database!.query(table);
  }

  static Future<void> close() async {
    await _database!.close();
  }
}
