/// Arcana: The Three Hearts - 맵 데이터 모델
/// GDD 10장: 맵/던전 시스템 데이터 정의
library;

import 'package:flutter/material.dart';

/// 타일 타입
enum TileType {
  empty,       // 빈 공간 (이동 불가)
  floor,       // 바닥 (이동 가능)
  wall,        // 벽 (이동 불가)
  water,       // 물 (위험)
  lava,        // 용암 (위험)
  door,        // 문
  chest,       // 상자
  playerSpawn, // 플레이어 스폰
  bossSpawn,   // 보스 스폰
  enemySpawn,  // 적 스폰
  npc,         // NPC
  treasure,    // 보물
  quest,       // 퀘스트 오브젝트
  vine,        // 덩굴 장애물
  light,       // 광원
  powerCore,   // 파워 코어
  hiddenItem,  // 숨겨진 아이템
  altar,       // 제단
  memory,      // 기억 조각
  checkpoint,  // 체크포인트
  endingChoice,// 엔딩 선택
}

/// 조명 설정
class LightingConfig {
  const LightingConfig({
    this.ambientColor = 0xFF1A1A2E,
    this.ambientIntensity = 0.5,
    this.fogEnabled = false,
    this.fogColor = 0xFF000000,
    this.fogDensity = 0.0,
    this.playerLightRadius,
    this.darknessDamage = false,
    this.darknessDamageRate = 0,
  });

  final int ambientColor;
  final double ambientIntensity;
  final bool fogEnabled;
  final int fogColor;
  final double fogDensity;
  final int? playerLightRadius;
  final bool darknessDamage;
  final int darknessDamageRate;

  Color get ambientColorObj => Color(ambientColor);
  Color get fogColorObj => Color(fogColor);

  factory LightingConfig.fromJson(Map<String, dynamic> json) {
    return LightingConfig(
      ambientColor: _parseColor(json['ambient_color'] as String?) ?? 0xFF1A1A2E,
      ambientIntensity: (json['ambient_intensity'] as num?)?.toDouble() ?? 0.5,
      fogEnabled: json['fog_enabled'] as bool? ?? false,
      fogColor: _parseColor(json['fog_color'] as String?) ?? 0xFF000000,
      fogDensity: (json['fog_density'] as num?)?.toDouble() ?? 0.0,
      playerLightRadius: json['player_light_radius'] as int?,
      darknessDamage: json['darkness_damage'] as bool? ?? false,
      darknessDamageRate: json['darkness_damage_rate'] as int? ?? 0,
    );
  }

  static int? _parseColor(String? colorStr) {
    if (colorStr == null) return null;
    final hex = colorStr.replaceFirst('0x', '').replaceFirst('#', '');
    return int.tryParse(hex, radix: 16);
  }
}

/// 스폰 포인트
class SpawnPoint {
  const SpawnPoint({
    required this.x,
    required this.y,
    required this.entityId,
    this.count = 1,
    this.wanderRadius = 0,
    this.respawnTime,
    this.questLink,
  });

  final int x;
  final int y;
  final String entityId;
  final int count;
  final int wanderRadius;
  final int? respawnTime;
  final String? questLink;

  factory SpawnPoint.fromJson(Map<String, dynamic> json, String entityId) {
    return SpawnPoint(
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
      entityId: entityId,
      count: json['count'] as int? ?? 1,
      wanderRadius: json['wander_radius'] as int? ?? 0,
      respawnTime: json['respawn_time'] as int?,
      questLink: json['quest_link'] as String?,
    );
  }
}

/// 보스 정보
class BossInfo {
  const BossInfo({
    required this.id,
    required this.name,
    required this.position,
    this.arenaRadius = 5,
    this.triggerDistance = 3,
    this.specialMechanic,
    this.phases = 1,
  });

  final String id;
  final String name;
  final (int, int) position;
  final int arenaRadius;
  final int triggerDistance;
  final String? specialMechanic;
  final int phases;

  factory BossInfo.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>? ?? {};
    return BossInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Boss',
      position: (
        pos['x'] as int? ?? 0,
        pos['y'] as int? ?? 0,
      ),
      arenaRadius: json['arena_radius'] as int? ?? 5,
      triggerDistance: json['trigger_distance'] as int? ?? 3,
      specialMechanic: json['special_mechanic'] as String?,
      phases: json['phases'] as int? ?? 1,
    );
  }
}

/// 보물 상자
class TreasureInfo {
  const TreasureInfo({
    required this.x,
    required this.y,
    required this.contents,
    this.rarity = 'common',
  });

  final int x;
  final int y;
  final List<String> contents;
  final String rarity;

  factory TreasureInfo.fromJson(Map<String, dynamic> json) {
    return TreasureInfo(
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
      contents: (json['contents'] as List<dynamic>?)?.cast<String>() ?? [],
      rarity: json['rarity'] as String? ?? 'common',
    );
  }
}

/// 숨겨진 아이템
class HiddenItemInfo {
  const HiddenItemInfo({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.requiredFor,
    this.discoveryHint,
    this.requirements,
  });

  final String id;
  final String name;
  final int x;
  final int y;
  final String? requiredFor;
  final String? discoveryHint;
  final String? requirements;

  factory HiddenItemInfo.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>? ?? json;
    return HiddenItemInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Item',
      x: pos['x'] as int? ?? json['x'] as int? ?? 0,
      y: pos['y'] as int? ?? json['y'] as int? ?? 0,
      requiredFor: json['required_for'] as String?,
      discoveryHint: json['discovery_hint'] as String?,
      requirements: json['requires_all_fragments'] == true
          ? 'all_fragments'
          : json['requirements'] as String?,
    );
  }
}

/// NPC 정보
class MapNpcInfo {
  const MapNpcInfo({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.questLink,
    this.shopEnabled = false,
    this.dialogueTriggerDistance = 2,
  });

  final String id;
  final String name;
  final int x;
  final int y;
  final String? questLink;
  final bool shopEnabled;
  final int dialogueTriggerDistance;

  factory MapNpcInfo.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>? ?? {};
    return MapNpcInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown NPC',
      x: pos['x'] as int? ?? json['x'] as int? ?? 0,
      y: pos['y'] as int? ?? json['y'] as int? ?? 0,
      questLink: json['quest_link'] as String?,
      shopEnabled: json['shop_enabled'] as bool? ?? false,
      dialogueTriggerDistance: json['dialogue_trigger_distance'] as int? ?? 2,
    );
  }
}

/// 위험 지역
class HazardInfo {
  const HazardInfo({
    required this.type,
    required this.positions,
    this.damage = 0,
    this.slowEffect = 0,
    this.blocksPath = false,
  });

  final String type;
  final List<(int, int)> positions;
  final int damage;
  final double slowEffect;
  final bool blocksPath;

  factory HazardInfo.fromJson(Map<String, dynamic> json) {
    final positionsJson = json['positions'] as List<dynamic>? ?? [];
    return HazardInfo(
      type: json['type'] as String? ?? 'unknown',
      positions: positionsJson
          .whereType<Map<String, dynamic>>()
          .map((p) => (p['x'] as int? ?? 0, p['y'] as int? ?? 0))
          .toList(),
      damage: json['damage'] as int? ?? 0,
      slowEffect: (json['slow_effect'] as num?)?.toDouble() ?? 0,
      blocksPath: json['blocks_path'] as bool? ?? false,
    );
  }
}

/// 문 정보
class DoorInfo {
  const DoorInfo({
    required this.id,
    required this.x,
    required this.y,
    this.requiredKey,
    this.locked = false,
    this.hidden = false,
    this.condition,
  });

  final String id;
  final int x;
  final int y;
  final String? requiredKey;
  final bool locked;
  final bool hidden;
  final String? condition;

  factory DoorInfo.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>? ?? {};
    return DoorInfo(
      id: json['id'] as String? ?? '',
      x: pos['x'] as int? ?? json['x'] as int? ?? 0,
      y: pos['y'] as int? ?? json['y'] as int? ?? 0,
      requiredKey: json['required_key'] as String?,
      locked: json['locked'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      condition: json['condition'] as String?,
    );
  }
}

/// 퀘스트 오브젝트
class QuestObjectInfo {
  const QuestObjectInfo({
    required this.type,
    required this.id,
    required this.positions,
    this.hp,
    this.blocksPath = false,
    this.questLink,
    this.interactTime,
    this.glowEffect = false,
  });

  final String type;
  final String id;
  final List<(int, int, String?)> positions; // x, y, optional data
  final int? hp;
  final bool blocksPath;
  final String? questLink;
  final double? interactTime;
  final bool glowEffect;

  factory QuestObjectInfo.fromJson(Map<String, dynamic> json) {
    final positionsJson = json['positions'] as List<dynamic>? ?? [];
    return QuestObjectInfo(
      type: json['type'] as String? ?? 'unknown',
      id: json['id'] as String? ?? '',
      positions: positionsJson.whereType<Map<String, dynamic>>().map((p) => (
        p['x'] as int? ?? 0,
        p['y'] as int? ?? 0,
        p['lore_id'] as String? ?? p['memory_id'] as String?,
      )).toList(),
      hp: json['hp'] as int?,
      blocksPath: json['blocks_path'] as bool? ?? false,
      questLink: json['quest_link'] as String?,
      interactTime: (json['interact_time'] as num?)?.toDouble(),
      glowEffect: json['glow_effect'] as bool? ?? false,
    );
  }
}

/// 맵 데이터 클래스
class MapData {
  const MapData({
    required this.id,
    required this.name,
    this.nameEn,
    required this.chapter,
    required this.width,
    required this.height,
    this.tileSize = 32,
    required this.layout,
    required this.tileLegend,
    this.tileset,
    this.bgm,
    this.ambientSfx,
    this.lighting = const LightingConfig(),
    this.playerSpawn = const (0, 0),
    this.boss,
    this.enemySpawns = const [],
    this.treasures = const [],
    this.hiddenItems = const [],
    this.npcs = const [],
    this.hazards = const [],
    this.doors = const [],
    this.questObjects = const [],
  });

  final String id;
  final String name;
  final String? nameEn;
  final int chapter;
  final int width;
  final int height;
  final int tileSize;
  final List<String> layout;
  final Map<String, TileType> tileLegend;
  final String? tileset;
  final String? bgm;
  final String? ambientSfx;
  final LightingConfig lighting;
  final (int, int) playerSpawn;
  final BossInfo? boss;
  final List<SpawnPoint> enemySpawns;
  final List<TreasureInfo> treasures;
  final List<HiddenItemInfo> hiddenItems;
  final List<MapNpcInfo> npcs;
  final List<HazardInfo> hazards;
  final List<DoorInfo> doors;
  final List<QuestObjectInfo> questObjects;

  /// 특정 좌표의 타일 타입 얻기
  TileType getTileAt(int x, int y) {
    if (y < 0 || y >= layout.length) return TileType.wall;
    if (x < 0 || x >= layout[y].length) return TileType.wall;

    final char = layout[y][x];
    return tileLegend[char] ?? TileType.wall;
  }

  /// 이동 가능 여부 확인
  bool isWalkable(int x, int y) {
    final tile = getTileAt(x, y);
    switch (tile) {
      case TileType.floor:
      case TileType.playerSpawn:
      case TileType.enemySpawn:
      case TileType.bossSpawn:
      case TileType.npc:
      case TileType.treasure:
      case TileType.door:
      case TileType.quest:
      case TileType.light:
      case TileType.hiddenItem:
      case TileType.altar:
      case TileType.memory:
      case TileType.checkpoint:
      case TileType.endingChoice:
        return true;
      default:
        return false;
    }
  }

  factory MapData.fromJson(Map<String, dynamic> json, int chapter) {
    // 레이아웃 파싱
    final layoutRaw = json['layout'] as List<dynamic>? ?? [];
    final layout = layoutRaw.cast<String>();

    // 그리드 정보
    final grid = json['grid'] as Map<String, dynamic>? ?? {};

    // 플레이어 스폰
    final spawnJson = json['player_spawn'] as Map<String, dynamic>? ?? {};
    final playerSpawn = (
      spawnJson['x'] as int? ?? 1,
      spawnJson['y'] as int? ?? 1,
    );

    // 보스
    final bossJson = json['boss'] as Map<String, dynamic>?;

    // 적 스폰
    final enemiesJson = json['enemies'] as List<dynamic>? ?? [];
    final enemySpawns = <SpawnPoint>[];
    for (final enemy in enemiesJson) {
      if (enemy is Map<String, dynamic>) {
        final entityId = enemy['id'] as String? ?? '';
        final spawnZones = enemy['spawn_zones'] as List<dynamic>? ?? [];
        for (final zone in spawnZones) {
          if (zone is Map<String, dynamic>) {
            enemySpawns.add(SpawnPoint.fromJson(zone, entityId));
          }
        }
      }
    }

    // 보물
    final treasuresJson = json['treasures'] as List<dynamic>? ?? [];

    // 숨겨진 아이템
    final hiddenJson = json['hidden_items'] as List<dynamic>? ?? [];

    // NPC
    final npcsJson = json['npcs'] as List<dynamic>? ?? [];

    // 위험 지역
    final hazardsJson = json['hazards'] as List<dynamic>? ?? [];

    // 문
    final doorsJson = json['doors'] as List<dynamic>? ?? [];

    // 퀘스트 오브젝트
    final questJson = json['quest_objects'] as List<dynamic>? ?? [];

    // 조명
    final lightingJson = json['lighting'] as Map<String, dynamic>? ?? {};

    return MapData(
      id: 'chapter_$chapter',
      name: json['name'] as String? ?? 'Unknown Map',
      nameEn: json['name_en'] as String?,
      chapter: chapter,
      width: grid['width'] as int? ?? (layout.isNotEmpty ? layout[0].length : 50),
      height: grid['height'] as int? ?? layout.length,
      tileSize: grid['tile_size'] as int? ?? 32,
      layout: layout,
      tileLegend: _defaultTileLegend,
      tileset: json['tileset'] as String?,
      bgm: json['bgm'] as String?,
      ambientSfx: json['ambient_sfx'] as String?,
      lighting: LightingConfig.fromJson(lightingJson),
      playerSpawn: playerSpawn,
      boss: bossJson != null ? BossInfo.fromJson(bossJson) : null,
      enemySpawns: enemySpawns,
      treasures: treasuresJson
          .whereType<Map<String, dynamic>>()
          .map((e) => TreasureInfo.fromJson(e))
          .toList(),
      hiddenItems: hiddenJson
          .whereType<Map<String, dynamic>>()
          .map((e) => HiddenItemInfo.fromJson(e))
          .toList(),
      npcs: npcsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => MapNpcInfo.fromJson(e))
          .toList(),
      hazards: hazardsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => HazardInfo.fromJson(e))
          .toList(),
      doors: doorsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => DoorInfo.fromJson(e))
          .toList(),
      questObjects: questJson
          .whereType<Map<String, dynamic>>()
          .map((e) => QuestObjectInfo.fromJson(e))
          .toList(),
    );
  }

  static const Map<String, TileType> _defaultTileLegend = {
    '#': TileType.wall,
    '.': TileType.floor,
    'S': TileType.playerSpawn,
    'B': TileType.bossSpawn,
    'E': TileType.enemySpawn,
    'T': TileType.treasure,
    '~': TileType.water,
    'V': TileType.vine,
    'Q': TileType.quest,
    'M': TileType.npc,
    'D': TileType.door,
    'L': TileType.light,
    'P': TileType.powerCore,
    'H': TileType.hiddenItem,
    'R': TileType.altar,
    'F': TileType.memory,
    'C': TileType.checkpoint,
    'W': TileType.endingChoice,
  };
}

/// 맵 설정 전체
class MapsConfig {
  const MapsConfig({
    required this.maps,
    required this.tileLegend,
    required this.globalSettings,
  });

  final Map<int, MapData> maps; // chapter -> MapData
  final Map<String, TileType> tileLegend;
  final Map<String, dynamic> globalSettings;

  /// 챕터 맵 가져오기
  MapData? getChapterMap(int chapter) => maps[chapter];

  /// 모든 맵 목록
  List<MapData> get allMaps => maps.values.toList();

  factory MapsConfig.fromJson(Map<String, dynamic> json) {
    final maps = <int, MapData>{};

    // 타일 범례 파싱
    final legendJson = json['tile_legend'] as Map<String, dynamic>? ?? {};
    final tileLegend = <String, TileType>{};
    for (final entry in legendJson.entries) {
      tileLegend[entry.key] = _parseTileType(entry.value as String);
    }

    // 챕터별 맵 파싱
    final chapterKeys = [
      'chapter_1_forest',
      'chapter_2_cave',
      'chapter_3_fortress',
      'chapter_4_garden',
      'chapter_5_abyss',
      'chapter_6_throne',
    ];

    for (int i = 0; i < chapterKeys.length; i++) {
      final key = chapterKeys[i];
      final chapterJson = json[key] as Map<String, dynamic>?;
      if (chapterJson != null) {
        maps[i + 1] = MapData.fromJson(chapterJson, i + 1);
      }
    }

    return MapsConfig(
      maps: maps,
      tileLegend: tileLegend,
      globalSettings: json['global_settings'] as Map<String, dynamic>? ?? {},
    );
  }

  static TileType _parseTileType(String type) {
    switch (type.toLowerCase()) {
      case 'wall':
        return TileType.wall;
      case 'floor':
        return TileType.floor;
      case 'player_spawn':
        return TileType.playerSpawn;
      case 'boss':
        return TileType.bossSpawn;
      case 'enemy_spawn':
        return TileType.enemySpawn;
      case 'treasure':
        return TileType.treasure;
      case 'water_hazard':
        return TileType.water;
      case 'vine_obstacle':
        return TileType.vine;
      case 'quest_object':
        return TileType.quest;
      case 'npc':
        return TileType.npc;
      case 'door':
        return TileType.door;
      case 'light_source':
        return TileType.light;
      case 'power_core':
        return TileType.powerCore;
      case 'hidden_item':
        return TileType.hiddenItem;
      case 'rose_altar':
        return TileType.altar;
      case 'memory_fragment':
        return TileType.memory;
      case 'checkpoint_or_choice':
        return TileType.checkpoint;
      case 'ending_choice':
        return TileType.endingChoice;
      default:
        return TileType.floor;
    }
  }
}
