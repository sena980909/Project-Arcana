/// Arcana: The Three Hearts - 스킬 데이터 모델
library;

/// 스킬 타입
enum SkillType {
  projectile, // 투사체
  area, // 범위 공격
  buff, // 버프
  dash, // 대시 계열
  summon, // 소환
}

/// 스킬 데이터
class SkillData {
  const SkillData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.manaCost,
    required this.cooldown,
    required this.damage,
    this.range = 100,
    this.radius = 0,
    this.duration = 0,
    this.projectileSpeed = 300,
    this.projectileCount = 1,
    this.buffEffect = const {},
    this.spriteKey = '',
    this.sfxKey = '',
  });

  final String id;
  final String name;
  final String description;
  final SkillType type;
  final int manaCost;
  final double cooldown;
  final double damage;
  final double range;
  final double radius; // 범위 공격 반경
  final double duration; // 버프 지속시간
  final double projectileSpeed;
  final int projectileCount;
  final Map<String, double> buffEffect; // 버프 효과 (예: {'speed': 1.5, 'damage': 1.2})
  final String spriteKey;
  final String sfxKey;

  factory SkillData.fromJson(Map<String, dynamic> json) {
    return SkillData(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      type: SkillType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'projectile'),
        orElse: () => SkillType.projectile,
      ),
      manaCost: json['manaCost'] as int? ?? 10,
      cooldown: (json['cooldown'] as num?)?.toDouble() ?? 5.0,
      damage: (json['damage'] as num?)?.toDouble() ?? 20,
      range: (json['range'] as num?)?.toDouble() ?? 100,
      radius: (json['radius'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      projectileSpeed: (json['projectileSpeed'] as num?)?.toDouble() ?? 300,
      projectileCount: json['projectileCount'] as int? ?? 1,
      buffEffect: (json['buffEffect'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      spriteKey: json['spriteKey'] as String? ?? '',
      sfxKey: json['sfxKey'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'manaCost': manaCost,
        'cooldown': cooldown,
        'damage': damage,
        'range': range,
        'radius': radius,
        'duration': duration,
        'projectileSpeed': projectileSpeed,
        'projectileCount': projectileCount,
        'buffEffect': buffEffect,
        'spriteKey': spriteKey,
        'sfxKey': sfxKey,
      };
}

/// 궁극기 데이터
class UltimateData {
  const UltimateData({
    required this.id,
    required this.name,
    required this.description,
    required this.heartType,
    required this.damage,
    this.radius = 150,
    this.duration = 0,
    this.effect = const {},
  });

  final String id;
  final String name;
  final String description;
  final String heartType; // courage, wisdom, love, unified
  final double damage;
  final double radius;
  final double duration;
  final Map<String, dynamic> effect;

  factory UltimateData.fromJson(Map<String, dynamic> json) {
    return UltimateData(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      heartType: json['heartType'] as String? ?? 'courage',
      damage: (json['damage'] as num?)?.toDouble() ?? 100,
      radius: (json['radius'] as num?)?.toDouble() ?? 150,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      effect: json['effect'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'heartType': heartType,
        'damage': damage,
        'radius': radius,
        'duration': duration,
        'effect': effect,
      };
}
