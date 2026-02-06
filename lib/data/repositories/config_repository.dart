/// Arcana: The Three Hearts - 설정 데이터 레포지토리
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/monster_data.dart';
import '../models/skill_data.dart';
import '../models/item_data.dart';
import '../models/game_state.dart';

/// 설정 데이터 레포지토리
/// JSON 파일에서 게임 설정 데이터를 로드합니다.
class ConfigRepository {
  ConfigRepository._();
  static final ConfigRepository instance = ConfigRepository._();

  // 캐시
  Map<String, MonsterData>? _monstersCache;
  Map<String, SkillData>? _skillsCache;
  Map<String, UltimateData>? _ultimatesCache;
  Map<String, ItemData>? _itemsCache;
  Map<String, MapData>? _mapsCache;

  bool _isInitialized = false;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.wait([
      _loadMonsters(),
      _loadSkills(),
      _loadItems(),
      _loadMaps(),
    ]);

    _isInitialized = true;
  }

  /// 몬스터 데이터 로드
  Future<void> _loadMonsters() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/monsters_config.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final monstersList = json['monsters'] as List<dynamic>;

      _monstersCache = {};
      for (final monsterJson in monstersList) {
        final monster = MonsterData.fromJson(monsterJson as Map<String, dynamic>);
        _monstersCache![monster.id] = monster;
      }
    } catch (e) {
      _monstersCache = {};
    }
  }

  /// 스킬 데이터 로드
  Future<void> _loadSkills() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/player_skills.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      // 스킬 로드
      final skillsList = json['skills'] as List<dynamic>;
      _skillsCache = {};
      for (final skillJson in skillsList) {
        final skill = SkillData.fromJson(skillJson as Map<String, dynamic>);
        _skillsCache![skill.id] = skill;
      }

      // 궁극기 로드
      final ultimatesList = json['ultimates'] as List<dynamic>;
      _ultimatesCache = {};
      for (final ultJson in ultimatesList) {
        final ult = UltimateData.fromJson(ultJson as Map<String, dynamic>);
        _ultimatesCache![ult.id] = ult;
      }
    } catch (e) {
      _skillsCache = {};
      _ultimatesCache = {};
    }
  }

  /// 아이템 데이터 로드
  Future<void> _loadItems() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/items_config.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final itemsList = json['items'] as List<dynamic>;

      _itemsCache = {};
      for (final itemJson in itemsList) {
        final item = ItemData.fromJson(itemJson as Map<String, dynamic>);
        _itemsCache![item.id] = item;
      }
    } catch (e) {
      _itemsCache = {};
    }
  }

  /// 맵 데이터 로드
  Future<void> _loadMaps() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/maps_config.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final mapsList = json['maps'] as List<dynamic>;

      _mapsCache = {};
      for (final mapJson in mapsList) {
        final map = MapData.fromJson(mapJson as Map<String, dynamic>);
        _mapsCache![map.id] = map;
      }
    } catch (e) {
      _mapsCache = {};
    }
  }

  // === Getters ===

  /// 모든 몬스터 데이터
  Map<String, MonsterData> get monsters => _monstersCache ?? {};

  /// ID로 몬스터 데이터 가져오기
  MonsterData? getMonster(String id) => _monstersCache?[id];

  /// 모든 스킬 데이터
  Map<String, SkillData> get skills => _skillsCache ?? {};

  /// ID로 스킬 데이터 가져오기
  SkillData? getSkill(String id) => _skillsCache?[id];

  /// 모든 궁극기 데이터
  Map<String, UltimateData> get ultimates => _ultimatesCache ?? {};

  /// 심장 타입으로 궁극기 가져오기
  UltimateData? getUltimateByHeart(String heartType) {
    return _ultimatesCache?.values.firstWhere(
      (u) => u.heartType == heartType,
      orElse: () => _ultimatesCache!.values.first,
    );
  }

  /// 모든 아이템 데이터
  Map<String, ItemData> get items => _itemsCache ?? {};

  /// ID로 아이템 데이터 가져오기
  ItemData? getItem(String id) => _itemsCache?[id];

  /// 타입별 아이템 목록
  List<ItemData> getItemsByType(ItemType type) {
    return _itemsCache?.values.where((item) => item.type == type).toList() ?? [];
  }

  /// 모든 맵 데이터
  Map<String, MapData> get maps => _mapsCache ?? {};

  /// ID로 맵 데이터 가져오기
  MapData? getMap(String id) => _mapsCache?[id];

  /// 챕터와 층으로 맵 가져오기
  MapData? getMapByChapterFloor(int chapter, int floor) {
    return _mapsCache?.values.firstWhere(
      (m) => m.chapter == chapter && m.floor == floor,
      orElse: () => _mapsCache!.values.first,
    );
  }

  /// 챕터의 모든 맵
  List<MapData> getMapsByChapter(int chapter) {
    return _mapsCache?.values.where((m) => m.chapter == chapter).toList() ?? [];
  }
}
