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
      version: 3,
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE Message (
            id TEXT PRIMARY KEY,
            chatRoomId TEXT NOT NULL,
            seqId INTEGER,
            senderId TEXT,
            content TEXT,
            messageType INTEGER,
            readCount INTEGER,
            createdAt TEXT
          )
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE Friends (
            id INTEGER PRIMARY KEY,
            stringId TEXT NOT NULL,
            nickName TEXT NOT NULL,
            originName TEXT NOT NULL,
            friendTypeId INTEGER NOT NULL,
            isPinned INTEGER NOT NULL,
            profileImg TEXT
          )
          ''');
        }
      },
    );
  }

  static Future<void> insert(String table, Map<String, dynamic> data, {bool replace = true}) async {
    await _database!.insert(table, data,
        conflictAlgorithm: replace ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore);
  }

  static Future<void> batchInsert(String table, List<Map<String, dynamic>> dataList,
      {bool replace = true}) async {
    final Batch batch = _database!.batch();
    for (final Map<String, dynamic> data in dataList) {
      batch.insert(table, data,
          conflictAlgorithm: replace ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> search(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    return await _database!.query(table, where: where, whereArgs: whereArgs);
  }

  static Future<void> close() async {
    await _database!.close();
  }
}
