/// Arcana: The Three Hearts - 몬스터 데이터 모델
/// GDD 8장: 몬스터/보스 시스템 데이터 정의
library;

import 'package:flutter/material.dart';

/// 몬스터 타입
enum MonsterType {
  normal,  // 일반
  elite,   // 엘리트
  boss,    // 보스
}

/// 보스 페이즈 데이터
class BossPhase {
  const BossPhase({
    required this.phaseNumber,
    required this.hpThreshold,
    this.transitionAnimation,
    this.invincibleDuration = 2.0,
    this.statChanges = const {},
    this.unlockedSkills = const [],
    this.dialogue,
  });

  /// 페이즈 번호
  final int phaseNumber;

  /// HP 임계값 (0.0 ~ 1.0)
  final double hpThreshold;

  /// 전환 애니메이션
  final String? transitionAnimation;

  /// 전환 중 무적 시간
  final double invincibleDuration;

  /// 스탯 변경 (예: {'attack': 1.2, 'speed': 1.5})
  final Map<String, double> statChanges;

  /// 해금되는 스킬 ID 목록
  final List<String> unlockedSkills;

  /// 페이즈 전환 시 대사
  final String? dialogue;

  factory BossPhase.fromJson(Map<String, dynamic> json) {
    final trigger = json['trigger'] as Map<String, dynamic>? ?? {};
    final statChangesJson = json['stat_changes'] as Map<String, dynamic>? ?? {};

    return BossPhase(
      phaseNumber: json['phase_number'] as int? ?? 1,
      hpThreshold: (trigger['hp_threshold'] as num?)?.toDouble() ?? 0.5,
      transitionAnimation: json['transition_animation'] as String?,
      invincibleDuration: (json['invincible_duration'] as num?)?.toDouble() ?? 2.0,
      statChanges: statChangesJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      unlockedSkills: (json['unlocked_skills'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      dialogue: json['dialogue'] as String?,
    );
  }
}

/// 공격 패턴
class AttackPattern {
  const AttackPattern({
    required this.id,
    required this.name,
    required this.damage,
    required this.cooldown,
    this.range = 50,
    this.telegraphDuration = 0.5,
    this.telegraphType = TelegraphType.circle,
    this.hitboxWidth,
    this.hitboxHeight,
    this.hitboxRadius,
    this.effects = const [],
    this.projectileSpeed,
    this.isRanged = false,
  });

  final String id;
  final String name;
  final double damage;
  final double cooldown;
  final double range;
  final double telegraphDuration;
  final TelegraphType telegraphType;
  final double? hitboxWidth;
  final double? hitboxHeight;
  final double? hitboxRadius;
  final List<String> effects;
  final double? projectileSpeed;
  final bool isRanged;

  factory AttackPattern.fromJson(Map<String, dynamic> json) {
    return AttackPattern(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown Attack',
      damage: (json['damage'] as num?)?.toDouble() ?? 10,
      cooldown: (json['cooldown'] as num?)?.toDouble() ?? 1.0,
      range: (json['range'] as num?)?.toDouble() ?? 50,
      telegraphDuration: (json['telegraph_duration'] as num?)?.toDouble() ?? 0.5,
      telegraphType: _parseTelegraphType(json['telegraph_type'] as String?),
      hitboxWidth: (json['hitbox_width'] as num?)?.toDouble(),
      hitboxHeight: (json['hitbox_height'] as num?)?.toDouble(),
      hitboxRadius: (json['hitbox_radius'] as num?)?.toDouble(),
      effects: (json['effects'] as List<dynamic>?)?.cast<String>() ?? [],
      projectileSpeed: (json['projectile_speed'] as num?)?.toDouble(),
      isRanged: json['is_ranged'] as bool? ?? false,
    );
  }

  static TelegraphType _parseTelegraphType(String? type) {
    switch (type?.toLowerCase()) {
      case 'circle':
        return TelegraphType.circle;
      case 'rectangle':
        return TelegraphType.rectangle;
      case 'line':
        return TelegraphType.line;
      case 'cone':
        return TelegraphType.cone;
      default:
        return TelegraphType.circle;
    }
  }
}

/// 텔레그래프 타입
enum TelegraphType {
  circle,     // 원형
  rectangle,  // 사각형
  line,       // 선형
  cone,       // 부채꼴
}

/// 드롭 아이템 정보
class MonsterDrop {
  const MonsterDrop({
    required this.itemId,
    required this.chance,
    this.minQuantity = 1,
    this.maxQuantity = 1,
  });

  final String itemId;
  final double chance;
  final int minQuantity;
  final int maxQuantity;

  factory MonsterDrop.fromJson(Map<String, dynamic> json) {
    return MonsterDrop(
      itemId: json['item_id'] as String? ?? json['id'] as String? ?? '',
      chance: (json['chance'] as num?)?.toDouble() ??
              (json['drop_rate'] as num?)?.toDouble() ?? 0.1,
      minQuantity: json['min_quantity'] as int? ??
                   json['min'] as int? ?? 1,
      maxQuantity: json['max_quantity'] as int? ??
                   json['max'] as int? ?? 1,
    );
  }
}

/// AI 행동 결정
class AIDecision {
  const AIDecision({
    required this.condition,
    required this.action,
    this.priority = 0,
  });

  final String condition;
  final String action;
  final int priority;

  factory AIDecision.fromJson(Map<String, dynamic> json) {
    return AIDecision(
      condition: json['condition'] as String? ?? '',
      action: json['action'] as String? ?? 'idle',
      priority: json['priority'] as int? ?? 0,
    );
  }
}

/// 몬스터 데이터 클래스
class MonsterData {
  const MonsterData({
    required this.id,
    required this.name,
    this.nameEn,
    required this.type,
    this.chapter = 1,
    // 기본 스탯
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    // AI 설정
    required this.detectRange,
    required this.attackRange,
    this.attackCooldown = 1.0,
    // 드롭
    this.drops = const [],
    this.expReward = 0,
    this.goldReward = 0,
    // 비주얼
    this.spriteSheet,
    this.width = 32,
    this.height = 32,
    // 보스 전용
    this.phases = const [],
    this.attackPatterns = const [],
    this.specialMechanic,
    this.defeatCondition,
    // AI
    this.decisionTree = const [],
    // 설명
    this.description,
    this.flavorText,
  });

  final String id;
  final String name;
  final String? nameEn;
  final MonsterType type;
  final int chapter;

  // 기본 스탯
  final double maxHp;
  final double attack;
  final double defense;
  final double speed;

  // AI 설정
  final double detectRange;
  final double attackRange;
  final double attackCooldown;

  // 드롭
  final List<MonsterDrop> drops;
  final int expReward;
  final int goldReward;

  // 비주얼
  final String? spriteSheet;
  final double width;
  final double height;

  // 보스 전용
  final List<BossPhase> phases;
  final List<AttackPattern> attackPatterns;
  final String? specialMechanic;
  final String? defeatCondition;

  // AI
  final List<AIDecision> decisionTree;

  // 설명
  final String? description;
  final String? flavorText;

  /// 보스 여부
  bool get isBoss => type == MonsterType.boss;

  factory MonsterData.fromJson(Map<String, dynamic> json) {
    final baseStats = json['base_stats'] as Map<String, dynamic>? ?? {};
    final aiConfig = json['ai_config'] as Map<String, dynamic>? ?? {};
    final dropsJson = json['drops'] as List<dynamic>? ??
                      json['drop_table'] as List<dynamic>? ?? [];
    final rewards = json['rewards'] as Map<String, dynamic>? ?? {};
    final visualJson = json['visual'] as Map<String, dynamic>? ?? {};
    final phasesJson = json['phases'] as List<dynamic>? ?? [];
    final attacksJson = json['attack_patterns'] as List<dynamic>? ??
                        json['attacks'] as List<dynamic>? ?? [];
    final decisionJson = json['decision_tree'] as List<dynamic>? ?? [];

    return MonsterData(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      type: _parseMonsterType(json['type'] as String?),
      chapter: json['chapter'] as int? ?? 1,
      // 스탯
      maxHp: (baseStats['hp'] as num?)?.toDouble() ??
             (json['max_health'] as num?)?.toDouble() ?? 100,
      attack: (baseStats['attack'] as num?)?.toDouble() ??
              (json['attack'] as num?)?.toDouble() ?? 10,
      defense: (baseStats['defense'] as num?)?.toDouble() ??
               (json['defense'] as num?)?.toDouble() ?? 5,
      speed: (baseStats['speed'] as num?)?.toDouble() ??
             (baseStats['move_speed'] as num?)?.toDouble() ??
             (json['speed'] as num?)?.toDouble() ?? 50,
      // AI
      detectRange: (aiConfig['detect_range'] as num?)?.toDouble() ??
                   (json['detect_range'] as num?)?.toDouble() ?? 150,
      attackRange: (aiConfig['attack_range'] as num?)?.toDouble() ??
                   (json['attack_range'] as num?)?.toDouble() ?? 50,
      attackCooldown: (aiConfig['attack_cooldown'] as num?)?.toDouble() ??
                      (json['attack_cooldown'] as num?)?.toDouble() ?? 1.0,
      // 드롭
      drops: dropsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => MonsterDrop.fromJson(e))
          .toList(),
      expReward: rewards['exp'] as int? ??
                 json['exp_reward'] as int? ?? 10,
      goldReward: rewards['gold'] as int? ??
                  json['gold_reward'] as int? ?? 5,
      // 비주얼
      spriteSheet: visualJson['sprite_sheet'] as String? ??
                   json['sprite_sheet'] as String?,
      width: (visualJson['width'] as num?)?.toDouble() ?? 32,
      height: (visualJson['height'] as num?)?.toDouble() ?? 32,
      // 보스
      phases: phasesJson
          .whereType<Map<String, dynamic>>()
          .map((e) => BossPhase.fromJson(e))
          .toList(),
      attackPatterns: attacksJson
          .whereType<Map<String, dynamic>>()
          .map((e) => AttackPattern.fromJson(e))
          .toList(),
      specialMechanic: json['special_mechanic'] as String?,
      defeatCondition: json['defeat_condition'] as String?,
      // AI
      decisionTree: decisionJson
          .whereType<Map<String, dynamic>>()
          .map((e) => AIDecision.fromJson(e))
          .toList(),
      // 설명
      description: json['description'] as String?,
      flavorText: json['flavor_text'] as String?,
    );
  }

  static MonsterType _parseMonsterType(String? type) {
    switch (type?.toLowerCase()) {
      case 'normal':
        return MonsterType.normal;
      case 'elite':
        return MonsterType.elite;
      case 'boss':
        return MonsterType.boss;
      default:
        return MonsterType.normal;
    }
  }
}

/// 몬스터 설정 전체
class MonstersConfig {
  const MonstersConfig({
    required this.monsters,
    required this.bosses,
  });

  final List<MonsterData> monsters;
  final List<MonsterData> bosses;

  /// 모든 몬스터 목록
  List<MonsterData> get all => [...monsters, ...bosses];

  /// ID로 몬스터 찾기
  MonsterData? findById(String id) {
    return all.where((m) => m.id == id).firstOrNull;
  }

  /// 챕터별 몬스터 찾기
  List<MonsterData> getByChapter(int chapter) {
    return monsters.where((m) => m.chapter == chapter).toList();
  }

  /// 챕터 보스 찾기
  MonsterData? getBoss(int chapter) {
    return bosses.where((b) => b.chapter == chapter).firstOrNull;
  }

  factory MonstersConfig.fromJson(Map<String, dynamic> json) {
    final monstersJson = json['monsters'] as Map<String, dynamic>? ?? {};
    final bossesJson = json['bosses'] as Map<String, dynamic>? ?? {};

    // 챕터별로 분류된 경우 처리
    final List<MonsterData> allMonsters = [];
    final List<MonsterData> allBosses = [];

    // 몬스터 파싱
    for (final entry in monstersJson.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        // 단일 몬스터
        if (value.containsKey('id')) {
          allMonsters.add(MonsterData.fromJson(value));
        } else {
          // 챕터별 그룹
          for (final subEntry in value.entries) {
            if (subEntry.value is Map<String, dynamic>) {
              allMonsters.add(MonsterData.fromJson(subEntry.value as Map<String, dynamic>));
            }
          }
        }
      }
    }

    // 보스 파싱
    for (final entry in bossesJson.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic> && value.containsKey('id')) {
        final boss = MonsterData.fromJson(value);
        allBosses.add(boss);
      }
    }

    return MonstersConfig(
      monsters: allMonsters,
      bosses: allBosses,
    );
  }
}
