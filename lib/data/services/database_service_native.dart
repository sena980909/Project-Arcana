/// Arcana: The Three Hearts - 데이터베이스 서비스 (네이티브)
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/player_state.dart';
import '../models/game_state.dart';
import 'save_slot.dart';

/// 데이터베이스 서비스 (네이티브 - SQLite)
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;
  bool _isInitialized = false;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Windows에서 sqflite_ffi 사용
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/arcana_saves.db';

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );

    _isInitialized = true;
  }

  /// 데이터베이스 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE save_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        slot INTEGER UNIQUE NOT NULL,
        player_state TEXT NOT NULL,
        game_state TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// 게임 저장
  Future<void> saveGame(int slot, PlayerState playerState, GameState gameState) async {
    if (_database == null) {
      await initialize();
    }

    final now = DateTime.now().toIso8601String();
    final playerJson = jsonEncode(playerState.toJson());
    final gameJson = jsonEncode(gameState.toJson());

    // UPSERT 사용
    await _database!.insert(
      'save_data',
      {
        'slot': slot,
        'player_state': playerJson,
        'game_state': gameJson,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 게임 불러오기
  Future<SaveSlot?> loadGame(int slot) async {
    if (_database == null) {
      await initialize();
    }

    final results = await _database!.query(
      'save_data',
      where: 'slot = ?',
      whereArgs: [slot],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    return SaveSlot(
      slot: row['slot'] as int,
      playerState: PlayerState.fromJson(
        jsonDecode(row['player_state'] as String) as Map<String, dynamic>,
      ),
      gameState: GameState.fromJson(
        jsonDecode(row['game_state'] as String) as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// 모든 저장 슬롯 정보 가져오기
  Future<List<SaveSlot?>> getAllSaveSlots() async {
    if (_database == null) {
      await initialize();
    }

    final slots = <SaveSlot?>[];

    for (int i = 1; i <= 3; i++) {
      slots.add(await loadGame(i));
    }

    return slots;
  }

  /// 저장 슬롯 삭제
  Future<void> deleteSave(int slot) async {
    if (_database == null) {
      await initialize();
    }

    await _database!.delete(
      'save_data',
      where: 'slot = ?',
      whereArgs: [slot],
    );
  }

  /// 설정 저장
  Future<void> setSetting(String key, String value) async {
    if (_database == null) {
      await initialize();
    }

    await _database!.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 설정 불러오기
  Future<String?> getSetting(String key) async {
    if (_database == null) {
      await initialize();
    }

    final results = await _database!.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    await _database?.close();
    _database = null;
    _isInitialized = false;
  }
}
