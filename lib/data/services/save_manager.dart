/// Arcana: The Three Hearts - 세이브 매니저
/// 게임 저장/로드 관리
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/item.dart';

/// 세이브 데이터
class SaveData {
  const SaveData({
    required this.currentFloor,
    required this.currentHearts,
    required this.health,
    required this.maxHealth,
    required this.score,
    required this.playTimeSeconds,
    required this.enemiesKilled,
    required this.itemsCollected,
    required this.gold,
    required this.inventoryItems,
    required this.equippedWeaponId,
    required this.equippedArmorId,
    required this.savedAt,
  });

  /// 현재 층
  final int currentFloor;

  /// 현재 하트 수
  final int currentHearts;

  /// 현재 체력
  final double health;

  /// 최대 체력
  final double maxHealth;

  /// 점수
  final int score;

  /// 플레이 시간 (초)
  final int playTimeSeconds;

  /// 처치한 적 수
  final int enemiesKilled;

  /// 획득한 아이템 수
  final int itemsCollected;

  /// 보유 골드
  final int gold;

  /// 인벤토리 아이템 (아이템ID -> 수량)
  final Map<String, int> inventoryItems;

  /// 장착 무기 ID
  final String? equippedWeaponId;

  /// 장착 방어구 ID
  final String? equippedArmorId;

  /// 저장 시간
  final DateTime savedAt;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'currentFloor': currentFloor,
      'currentHearts': currentHearts,
      'health': health,
      'maxHealth': maxHealth,
      'score': score,
      'playTimeSeconds': playTimeSeconds,
      'enemiesKilled': enemiesKilled,
      'itemsCollected': itemsCollected,
      'gold': gold,
      'inventoryItems': inventoryItems,
      'equippedWeaponId': equippedWeaponId,
      'equippedArmorId': equippedArmorId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      currentFloor: json['currentFloor'] as int,
      currentHearts: json['currentHearts'] as int,
      health: (json['health'] as num).toDouble(),
      maxHealth: (json['maxHealth'] as num).toDouble(),
      score: json['score'] as int,
      playTimeSeconds: json['playTimeSeconds'] as int,
      enemiesKilled: json['enemiesKilled'] as int,
      itemsCollected: json['itemsCollected'] as int,
      gold: json['gold'] as int,
      inventoryItems: Map<String, int>.from(json['inventoryItems'] as Map),
      equippedWeaponId: json['equippedWeaponId'] as String?,
      equippedArmorId: json['equippedArmorId'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// 플레이 시간 Duration
  Duration get playTime => Duration(seconds: playTimeSeconds);
}

/// 세이브 매니저
class SaveManager {
  SaveManager._();

  static final SaveManager instance = SaveManager._();

  static const String _saveKey = 'arcana_save_data';
  static const String _saveKeyBackup = 'arcana_save_data_backup';
  static const String _saveKeyTemp = 'arcana_save_data_temp';
  static const String _settingsKey = 'arcana_settings';

  SharedPreferences? _prefs;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // 시작 시 미완료 저장 복구 시도
    await _recoverFromIncompleteWrite();
  }

  /// 세이브 데이터 존재 여부
  bool get hasSaveData {
    return _prefs?.containsKey(_saveKey) ?? false;
  }

  /// 미완료 쓰기 복구 (앱 크래시 후)
  Future<void> _recoverFromIncompleteWrite() async {
    final hasTemp = _prefs?.containsKey(_saveKeyTemp) ?? false;
    final hasBackup = _prefs?.containsKey(_saveKeyBackup) ?? false;
    final hasMain = _prefs?.containsKey(_saveKey) ?? false;

    if (hasTemp && !hasMain) {
      // 임시 파일만 있음 = 저장 중 크래시
      // 백업이 있으면 백업 복구, 없으면 임시 파일 삭제
      if (hasBackup) {
        final backupData = _prefs?.getString(_saveKeyBackup);
        if (backupData != null) {
          await _prefs?.setString(_saveKey, backupData);
          debugPrint('[SaveManager] Recovered from backup after crash');
        }
      }
      await _prefs?.remove(_saveKeyTemp);
    } else if (hasTemp) {
      // 임시 파일과 메인 파일 모두 있음 = 정상 저장 후 임시 파일 삭제 안 됨
      await _prefs?.remove(_saveKeyTemp);
    }
  }

  /// 게임 저장 (원자적 쓰기 적용)
  Future<bool> saveGame(SaveData data) async {
    try {
      final jsonString = jsonEncode(data.toJson());

      // 1. 임시 키에 먼저 저장 (쓰기 시작 마커)
      await _prefs?.setString(_saveKeyTemp, jsonString);

      // 2. 기존 데이터가 있으면 백업 생성
      final existingData = _prefs?.getString(_saveKey);
      if (existingData != null) {
        await _prefs?.setString(_saveKeyBackup, existingData);
      }

      // 3. 실제 키에 저장
      await _prefs?.setString(_saveKey, jsonString);

      // 4. 임시 키 삭제 (쓰기 완료 마커)
      await _prefs?.remove(_saveKeyTemp);

      debugPrint('[SaveManager] Game saved successfully (atomic write)');
      return true;
    } catch (e) {
      debugPrint('[SaveManager] Failed to save game: $e');

      // 저장 실패 시 백업에서 복구 시도
      await _tryRestoreFromBackup();
      return false;
    }
  }

  /// 백업에서 복구 시도
  Future<void> _tryRestoreFromBackup() async {
    final backupData = _prefs?.getString(_saveKeyBackup);
    if (backupData != null) {
      try {
        // 백업이 유효한지 확인
        jsonDecode(backupData);
        await _prefs?.setString(_saveKey, backupData);
        debugPrint('[SaveManager] Restored from backup after save failure');
      } catch (_) {
        debugPrint('[SaveManager] Backup data is also corrupted');
      }
    }
    await _prefs?.remove(_saveKeyTemp);
  }

  /// 게임 로드 (손상 시 백업 시도)
  SaveData? loadGame() {
    try {
      final jsonString = _prefs?.getString(_saveKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SaveData.fromJson(json);
    } catch (e) {
      debugPrint('[SaveManager] Failed to load game: $e');

      // 메인 데이터 손상 시 백업에서 로드 시도
      return _loadFromBackup();
    }
  }

  /// 백업에서 로드
  SaveData? _loadFromBackup() {
    try {
      final backupString = _prefs?.getString(_saveKeyBackup);
      if (backupString == null) return null;

      debugPrint('[SaveManager] Loading from backup...');
      final json = jsonDecode(backupString) as Map<String, dynamic>;
      return SaveData.fromJson(json);
    } catch (e) {
      debugPrint('[SaveManager] Backup also corrupted: $e');
      return null;
    }
  }

  /// 세이브 데이터 삭제
  Future<bool> deleteSave() async {
    try {
      await _prefs?.remove(_saveKey);
      debugPrint('Save data deleted');
      return true;
    } catch (e) {
      debugPrint('Failed to delete save: $e');
      return false;
    }
  }

  /// 현재 게임 상태로 SaveData 생성
  static SaveData createSaveData({
    required int currentFloor,
    required int currentHearts,
    required double health,
    required double maxHealth,
    required int score,
    required Duration playTime,
    required int enemiesKilled,
    required int itemsCollected,
    required int gold,
    required List<InventorySlot> inventory,
    Item? equippedWeapon,
    Item? equippedArmor,
  }) {
    final inventoryItems = <String, int>{};
    for (final slot in inventory) {
      inventoryItems[slot.item.id] = slot.quantity;
    }

    return SaveData(
      currentFloor: currentFloor,
      currentHearts: currentHearts,
      health: health,
      maxHealth: maxHealth,
      score: score,
      playTimeSeconds: playTime.inSeconds,
      enemiesKilled: enemiesKilled,
      itemsCollected: itemsCollected,
      gold: gold,
      inventoryItems: inventoryItems,
      equippedWeaponId: equippedWeapon?.id,
      equippedArmorId: equippedArmor?.id,
      savedAt: DateTime.now(),
    );
  }

  /// 설정 저장
  Future<void> saveSettings(GameSettings settings) async {
    try {
      final jsonString = jsonEncode(settings.toJson());
      await _prefs?.setString(_settingsKey, jsonString);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  /// 설정 로드
  GameSettings loadSettings() {
    try {
      final jsonString = _prefs?.getString(_settingsKey);
      if (jsonString == null) return const GameSettings();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameSettings.fromJson(json);
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      return const GameSettings();
    }
  }
}

/// 게임 설정
class GameSettings {
  const GameSettings({
    this.bgmVolume = 0.7,
    this.sfxVolume = 1.0,
    this.bgmEnabled = true,
    this.sfxEnabled = true,
    this.vibrationEnabled = true,
    this.showDamageNumbers = true,
  });

  final double bgmVolume;
  final double sfxVolume;
  final bool bgmEnabled;
  final bool sfxEnabled;
  final bool vibrationEnabled;
  final bool showDamageNumbers;

  Map<String, dynamic> toJson() {
    return {
      'bgmVolume': bgmVolume,
      'sfxVolume': sfxVolume,
      'bgmEnabled': bgmEnabled,
      'sfxEnabled': sfxEnabled,
      'vibrationEnabled': vibrationEnabled,
      'showDamageNumbers': showDamageNumbers,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      bgmVolume: (json['bgmVolume'] as num?)?.toDouble() ?? 0.7,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      bgmEnabled: json['bgmEnabled'] as bool? ?? true,
      sfxEnabled: json['sfxEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      showDamageNumbers: json['showDamageNumbers'] as bool? ?? true,
    );
  }

  GameSettings copyWith({
    double? bgmVolume,
    double? sfxVolume,
    bool? bgmEnabled,
    bool? sfxEnabled,
    bool? vibrationEnabled,
    bool? showDamageNumbers,
  }) {
    return GameSettings(
      bgmVolume: bgmVolume ?? this.bgmVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showDamageNumbers: showDamageNumbers ?? this.showDamageNumbers,
    );
  }
}
