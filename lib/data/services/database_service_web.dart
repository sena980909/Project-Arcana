/// Arcana: The Three Hearts - 데이터베이스 서비스 (웹)
library;

import 'dart:convert';
import 'dart:html' as html;

import '../models/player_state.dart';
import '../models/game_state.dart';
import 'save_slot.dart';

/// 데이터베이스 서비스 (웹 - localStorage)
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  bool _isInitialized = false;

  /// 초기화
  Future<void> initialize() async {
    _isInitialized = true;
  }

  /// 게임 저장
  Future<void> saveGame(int slot, PlayerState playerState, GameState gameState) async {
    final now = DateTime.now().toIso8601String();
    final data = {
      'slot': slot,
      'player_state': playerState.toJson(),
      'game_state': gameState.toJson(),
      'created_at': now,
      'updated_at': now,
    };
    html.window.localStorage['arcana_save_$slot'] = jsonEncode(data);
  }

  /// 게임 불러오기
  Future<SaveSlot?> loadGame(int slot) async {
    final raw = html.window.localStorage['arcana_save_$slot'];
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return SaveSlot(
        slot: data['slot'] as int,
        playerState: PlayerState.fromJson(
          data['player_state'] as Map<String, dynamic>,
        ),
        gameState: GameState.fromJson(
          data['game_state'] as Map<String, dynamic>,
        ),
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  /// 모든 저장 슬롯 정보 가져오기
  Future<List<SaveSlot?>> getAllSaveSlots() async {
    final slots = <SaveSlot?>[];
    for (int i = 1; i <= 3; i++) {
      slots.add(await loadGame(i));
    }
    return slots;
  }

  /// 저장 슬롯 삭제
  Future<void> deleteSave(int slot) async {
    html.window.localStorage.remove('arcana_save_$slot');
  }

  /// 설정 저장
  Future<void> setSetting(String key, String value) async {
    html.window.localStorage['arcana_setting_$key'] = value;
  }

  /// 설정 불러오기
  Future<String?> getSetting(String key) async {
    return html.window.localStorage['arcana_setting_$key'];
  }

  /// 닫기
  Future<void> close() async {
    _isInitialized = false;
  }
}
