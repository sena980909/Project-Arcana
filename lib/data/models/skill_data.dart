/// Arcana: The Three Hearts - 스킬 데이터 모델
/// GDD 7장: 스킬 시스템 데이터 정의
library;

import 'package:flutter/material.dart';

/// 스킬 타입
enum SkillType {
  basic,    // 기본 공격
  active,   // 액티브 스킬
  dash,     // 대시/회피
  ultimate, // 궁극기
  passive,  // 패시브
}

/// 스킬 카테고리
enum SkillCategory {
  melee,        // 근접 공격
  ranged,       // 원거리 공격
  dashAttack,   // 대시 공격
  defense,      // 방어
  heavyAttack,  // 강공격
  aoeAttack,    // 광역 공격
  utility,      // 유틸리티
  movement,     // 이동
  buffUltimate, // 버프 궁극기
  defenseUltimate, // 방어 궁극기
  attackUltimate,  // 공격 궁극기
  fusionUltimate,  // 융합 궁극기
  survival,     // 생존
  offense,      // 공격
  sustain,      // 지속
  heart,        // 심장
}

/// 히트박스 타입
enum HitboxType {
  arc,        // 부채꼴
  rectangle,  // 사각형
  circle,     // 원형
  semicircle, // 반원
  line,       // 선형
  fullScreen, // 전체 화면
}

/// 스킬 히트박스 데이터
class SkillHitbox {
  const SkillHitbox({
    required this.type,
    this.radius,
    this.width,
    this.height,
    this.angle,
    this.angles,
  });

  final HitboxType type;
  final double? radius;
  final double? width;
  final double? height;
  final double? angle;
  final List<double>? angles;

  factory SkillHitbox.fromJson(Map<String, dynamic> json) {
    return SkillHitbox(
      type: _parseHitboxType(json['type'] as String? ?? 'circle'),
      radius: (json['radius'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble() ??
             (json['width_min'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      angle: (json['angle'] as num?)?.toDouble(),
      angles: (json['angles'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  static HitboxType _parseHitboxType(String type) {
    switch (type.toUpperCase()) {
      case 'ARC':
        return HitboxType.arc;
      case 'RECTANGLE':
        return HitboxType.rectangle;
      case 'CIRCLE':
        return HitboxType.circle;
      case 'SEMICIRCLE':
        return HitboxType.semicircle;
      case 'LINE':
        return HitboxType.line;
      case 'FULL_SCREEN':
        return HitboxType.fullScreen;
      default:
        return HitboxType.circle;
    }
  }
}

/// 스킬 피드백 (이펙트, 사운드 등)
class SkillFeedback {
  const SkillFeedback({
    this.hitStopDuration = 0,
    this.hitStopPerHit = false,
    this.screenShakeIntensity = 0,
    this.screenShakeDuration = 0.1,
    this.hitSound,
    this.castSound,
    this.hitEffect,
  });

  final double hitStopDuration;
  final bool hitStopPerHit;
  final double screenShakeIntensity;
  final double screenShakeDuration;
  final String? hitSound;
  final String? castSound;
  final String? hitEffect;

  factory SkillFeedback.fromJson(Map<String, dynamic> json) {
    final hitStop = json['hit_stop'] as Map<String, dynamic>?;
    final screenShake = json['screen_shake'] as Map<String, dynamic>?;

    return SkillFeedback(
      hitStopDuration: (hitStop?['duration'] as num?)?.toDouble() ?? 0,
      hitStopPerHit: hitStop?['per_hit'] as bool? ?? false,
      screenShakeIntensity: (screenShake?['intensity'] as num?)?.toDouble() ?? 0,
      screenShakeDuration: (screenShake?['duration'] as num?)?.toDouble() ?? 0.1,
      hitSound: json['hit_sound'] as String?,
      castSound: json['cast_sound'] as String?,
      hitEffect: json['hit_effect'] as String?,
    );
  }
}

/// 스킬 효과
class SkillEffect {
  const SkillEffect({
    required this.type,
    this.value,
    this.duration,
    this.chance,
    this.description,
  });

  final String type;
  final double? value;
  final double? duration;
  final double? chance;
  final String? description;

  factory SkillEffect.fromJson(Map<String, dynamic> json) {
    return SkillEffect(
      type: json['type'] as String? ?? '',
      value: (json['force'] as num?)?.toDouble() ??
             (json['damage'] as num?)?.toDouble() ??
             (json['amount'] as num?)?.toDouble() ??
             (json['percent'] as num?)?.toDouble() ??
             (json['reduction'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      chance: (json['chance'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }
}

/// 스킬 데이터 클래스
class SkillData {
  const SkillData({
    required this.id,
    required this.name,
    this.nameEn,
    required this.type,
    this.category,
    this.damage = 0,
    this.manaCost = 0,
    this.cooldown = 0,
    this.range = 0,
    this.castTime = 0,
    this.unlockLevel = 1,
    this.hitbox,
    this.feedback,
    this.effects = const [],
    this.description,
    this.iconPath,
    // 콤보 관련
    this.comboHits,
    this.comboDamage,
    this.comboWindow,
    // 궁극기 관련
    this.heartGaugeCost = 0,
    this.unlockCondition,
    this.heartAssociation,
    this.ultimateDuration,
    // 대시 관련
    this.dashDistance,
    this.dashSpeed,
    this.invincibleStart,
    this.invincibleDuration,
    this.charges,
    // 완벽 회피
    this.perfectDodgeWindow,
    this.perfectDodgeHeartGain = 0,
  });

  final String id;
  final String name;
  final String? nameEn;
  final SkillType type;
  final SkillCategory? category;
  final double damage;
  final double manaCost;
  final double cooldown;
  final double range;
  final double castTime;
  final int unlockLevel;
  final SkillHitbox? hitbox;
  final SkillFeedback? feedback;
  final List<SkillEffect> effects;
  final String? description;
  final String? iconPath;

  // 콤보 관련
  final int? comboHits;
  final List<double>? comboDamage;
  final double? comboWindow;

  // 궁극기 관련
  final double heartGaugeCost;
  final String? unlockCondition;
  final String? heartAssociation;
  final double? ultimateDuration;

  // 대시 관련
  final double? dashDistance;
  final double? dashSpeed;
  final double? invincibleStart;
  final double? invincibleDuration;
  final int? charges;

  // 완벽 회피
  final double? perfectDodgeWindow;
  final double perfectDodgeHeartGain;

  /// JSON에서 스킬 데이터 생성
  factory SkillData.fromJson(Map<String, dynamic> json, SkillType type) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final hitboxJson = json['hitbox'] as Map<String, dynamic>?;
    final feedbackJson = json['feedback'] as Map<String, dynamic>?;
    final effectsJson = json['effects'] as List<dynamic>? ?? [];
    final mechanics = json['mechanics'] as Map<String, dynamic>? ?? {};
    final input = json['input'] as Map<String, dynamic>? ?? {};
    final perfectDodge = json['perfect_dodge'] as Map<String, dynamic>? ?? {};
    final dashSkill = json['dash_skill'] as Map<String, dynamic>?;

    // 궁극기 특수 처리
    final effectsMap = json['effects'] as Map<String, dynamic>?;

    return SkillData(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      type: type,
      category: _parseCategory(json['category'] as String?),
      damage: (stats['damage'] as num?)?.toDouble() ?? 0,
      manaCost: (stats['mana_cost'] as num?)?.toDouble() ?? 0,
      cooldown: (stats['cooldown'] as num?)?.toDouble() ?? 0,
      range: (stats['range'] as num?)?.toDouble() ?? 0,
      castTime: (input['cast_time'] as num?)?.toDouble() ?? 0,
      unlockLevel: json['unlock_level'] as int? ?? 1,
      hitbox: hitboxJson != null ? SkillHitbox.fromJson(hitboxJson) : null,
      feedback: feedbackJson != null ? SkillFeedback.fromJson(feedbackJson) : null,
      effects: effectsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => SkillEffect.fromJson(e))
          .toList(),
      description: json['description'] as String?,
      iconPath: (json['assets'] as Map<String, dynamic>?)?['icon'] as String?,
      // 콤보
      comboHits: stats['combo_hits'] as int?,
      comboDamage: (stats['combo_damage'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      comboWindow: (stats['combo_window'] as num?)?.toDouble(),
      // 궁극기
      heartGaugeCost: (stats['heart_gauge_cost'] as num?)?.toDouble() ?? 0,
      unlockCondition: json['unlock_condition'] as String?,
      heartAssociation: json['heart_association'] as String?,
      ultimateDuration: (stats['duration'] as num?)?.toDouble() ??
                        (effectsMap?['duration'] as num?)?.toDouble(),
      // 대시
      dashDistance: (stats['distance'] as num?)?.toDouble() ??
                    (mechanics['dash_distance'] as num?)?.toDouble(),
      dashSpeed: (mechanics['dash_speed'] as num?)?.toDouble(),
      invincibleStart: (mechanics['invincible_frames'] as Map<String, dynamic>?)?['start'] as double?,
      invincibleDuration: (mechanics['invincible_frames'] as Map<String, dynamic>?)?['duration'] as double?,
      charges: stats['charges'] as int?,
      // 완벽 회피
      perfectDodgeWindow: (perfectDodge['window'] as num?)?.toDouble(),
      perfectDodgeHeartGain: (perfectDodge['rewards'] as Map<String, dynamic>?)?['heart_gauge'] as double? ?? 0,
    );
  }

  static SkillCategory? _parseCategory(String? category) {
    if (category == null) return null;
    switch (category.toUpperCase()) {
      case 'MELEE':
      case 'MELEE_CHARGE':
        return SkillCategory.melee;
      case 'RANGED_ATTACK':
        return SkillCategory.ranged;
      case 'DASH_ATTACK':
        return SkillCategory.dashAttack;
      case 'DEFENSE':
        return SkillCategory.defense;
      case 'HEAVY_ATTACK':
        return SkillCategory.heavyAttack;
      case 'AOE_ATTACK':
      case 'SPINNING_AOE':
        return SkillCategory.aoeAttack;
      case 'UTILITY':
        return SkillCategory.utility;
      case 'MOVEMENT':
        return SkillCategory.movement;
      case 'BUFF_ULTIMATE':
        return SkillCategory.buffUltimate;
      case 'DEFENSE_ULTIMATE':
        return SkillCategory.defenseUltimate;
      case 'ATTACK_ULTIMATE':
        return SkillCategory.attackUltimate;
      case 'FUSION_ULTIMATE':
        return SkillCategory.fusionUltimate;
      case 'SURVIVAL':
        return SkillCategory.survival;
      case 'OFFENSE':
        return SkillCategory.offense;
      case 'SUSTAIN':
        return SkillCategory.sustain;
      case 'HEART':
        return SkillCategory.heart;
      default:
        return null;
    }
  }
}

/// 마나/심장 게이지 리소스 설정
class ResourceSystemConfig {
  const ResourceSystemConfig({
    required this.maxMana,
    required this.manaRegenPerSecond,
    required this.manaRegenOnHit,
    required this.manaRegenOnKill,
    required this.maxHeartGauge,
    required this.heartGainOnDamageDealt,
    required this.heartGainOnDamageTaken,
    required this.heartGainOnPerfectDodge,
    required this.heartGaugeRequiredForUltimate,
  });

  final double maxMana;
  final double manaRegenPerSecond;
  final double manaRegenOnHit;
  final double manaRegenOnKill;
  final double maxHeartGauge;
  final double heartGainOnDamageDealt;
  final double heartGainOnDamageTaken;
  final double heartGainOnPerfectDodge;
  final double heartGaugeRequiredForUltimate;

  factory ResourceSystemConfig.fromJson(Map<String, dynamic> json) {
    final mana = json['mana'] as Map<String, dynamic>? ?? {};
    final heart = json['heart_gauge'] as Map<String, dynamic>? ?? {};

    return ResourceSystemConfig(
      maxMana: (mana['max'] as num?)?.toDouble() ?? 100,
      manaRegenPerSecond: (mana['regen_per_second'] as num?)?.toDouble() ?? 2,
      manaRegenOnHit: (mana['regen_on_hit'] as num?)?.toDouble() ?? 5,
      manaRegenOnKill: (mana['regen_on_kill'] as num?)?.toDouble() ?? 15,
      maxHeartGauge: (heart['max'] as num?)?.toDouble() ?? 100,
      heartGainOnDamageDealt: (heart['gain_on_damage_dealt'] as num?)?.toDouble() ?? 1,
      heartGainOnDamageTaken: (heart['gain_on_damage_taken'] as num?)?.toDouble() ?? 3,
      heartGainOnPerfectDodge: (heart['gain_on_perfect_dodge'] as num?)?.toDouble() ?? 10,
      heartGaugeRequiredForUltimate: (heart['required_for_ultimate'] as num?)?.toDouble() ?? 100,
    );
  }

  static const defaultConfig = ResourceSystemConfig(
    maxMana: 100,
    manaRegenPerSecond: 2,
    manaRegenOnHit: 5,
    manaRegenOnKill: 15,
    maxHeartGauge: 100,
    heartGainOnDamageDealt: 1,
    heartGainOnDamageTaken: 3,
    heartGainOnPerfectDodge: 10,
    heartGaugeRequiredForUltimate: 100,
  );
}

/// 스킬 설정 전체
class SkillsConfig {
  const SkillsConfig({
    required this.resourceSystem,
    required this.basicAttacks,
    required this.activeSkills,
    required this.dashSkill,
    required this.ultimateSkills,
    required this.passiveSkills,
  });

  final ResourceSystemConfig resourceSystem;
  final List<SkillData> basicAttacks;
  final List<SkillData> activeSkills;
  final SkillData? dashSkill;
  final List<SkillData> ultimateSkills;
  final List<SkillData> passiveSkills;

  /// 모든 스킬 목록
  List<SkillData> get allSkills => [
    ...basicAttacks,
    ...activeSkills,
    if (dashSkill != null) dashSkill!,
    ...ultimateSkills,
    ...passiveSkills,
  ];

  /// ID로 스킬 찾기
  SkillData? findById(String id) {
    return allSkills.where((s) => s.id == id).firstOrNull;
  }

  /// 기본 스킬 설정
  static final defaultConfig = SkillsConfig(
    resourceSystem: ResourceSystemConfig.defaultConfig,
    basicAttacks: [
      const SkillData(
        id: 'basic_attack',
        name: '기본 공격',
        description: '기본 근접 공격',
        type: SkillType.basic,
        category: SkillCategory.melee,
        damage: 20,
        manaCost: 0,
        cooldown: 0.4,
      ),
    ],
    activeSkills: [
      const SkillData(
        id: 'heavy_attack',
        name: '강공격',
        description: '강력한 일격',
        type: SkillType.active,
        category: SkillCategory.heavyAttack,
        damage: 50,
        manaCost: 20,
        cooldown: 2.0,
      ),
    ],
    dashSkill: const SkillData(
      id: 'dash',
      name: '대시',
      description: '빠르게 이동',
      type: SkillType.dash,
      category: SkillCategory.movement,
      damage: 0,
      manaCost: 15,
      cooldown: 1.5,
    ),
    ultimateSkills: [
      const SkillData(
        id: 'ultimate_body',
        name: '육체의 분노',
        description: '심장 게이지를 소모하여 강력한 공격',
        type: SkillType.ultimate,
        category: SkillCategory.attackUltimate,
        damage: 150,
        manaCost: 0,
        heartGaugeCost: 100,
        cooldown: 0,
      ),
    ],
    passiveSkills: const [],
  );

  factory SkillsConfig.fromJson(Map<String, dynamic> json) {
    final resourceJson = json['resource_system'] as Map<String, dynamic>? ?? {};
    final basicJson = json['basic_attacks'] as Map<String, dynamic>? ?? {};
    final activeJson = json['active_skills'] as Map<String, dynamic>? ?? {};
    final dashJson = json['dash_skill'] as Map<String, dynamic>? ?? {};
    final ultimateJson = json['ultimate_skills'] as Map<String, dynamic>? ?? {};
    final passiveJson = json['passive_skills'] as Map<String, dynamic>? ?? {};

    return SkillsConfig(
      resourceSystem: ResourceSystemConfig.fromJson(resourceJson),
      basicAttacks: basicJson.values
          .whereType<Map<String, dynamic>>()
          .map((e) => SkillData.fromJson(e, SkillType.basic))
          .toList(),
      activeSkills: activeJson.values
          .whereType<Map<String, dynamic>>()
          .map((e) => SkillData.fromJson(e, SkillType.active))
          .toList(),
      dashSkill: dashJson.isNotEmpty
          ? SkillData.fromJson(
              dashJson.values.first as Map<String, dynamic>,
              SkillType.dash,
            )
          : null,
      ultimateSkills: ultimateJson.values
          .whereType<Map<String, dynamic>>()
          .map((e) => SkillData.fromJson(e, SkillType.ultimate))
          .toList(),
      passiveSkills: passiveJson.values
          .whereType<Map<String, dynamic>>()
          .map((e) => SkillData.fromJson(e, SkillType.passive))
          .toList(),
    );
  }
}
