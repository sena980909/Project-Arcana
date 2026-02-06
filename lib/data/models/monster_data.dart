/// Arcana: The Three Hearts - 몬스터 데이터 모델
library;

/// 몬스터 공격 패턴
class AttackPattern {
  const AttackPattern({
    required this.name,
    required this.damage,
    required this.range,
    required this.telegraphDuration,
    required this.attackDuration,
    required this.cooldown,
    this.shape = 'circle',
    this.width = 0,
    this.height = 0,
    this.angle = 0,
  });

  final String name;
  final double damage;
  final double range;
  final double telegraphDuration; // 텔레그래프 표시 시간
  final double attackDuration; // 공격 지속 시간
  final double cooldown;
  final String shape; // circle, rectangle, arc
  final double width;
  final double height;
  final double angle; // arc 형태일 때 각도

  factory AttackPattern.fromJson(Map<String, dynamic> json) {
    return AttackPattern(
      name: json['name'] as String? ?? 'attack',
      damage: (json['damage'] as num?)?.toDouble() ?? 10,
      range: (json['range'] as num?)?.toDouble() ?? 30,
      telegraphDuration: (json['telegraphDuration'] as num?)?.toDouble() ?? 0.5,
      attackDuration: (json['attackDuration'] as num?)?.toDouble() ?? 0.3,
      cooldown: (json['cooldown'] as num?)?.toDouble() ?? 2.0,
      shape: json['shape'] as String? ?? 'circle',
      width: (json['width'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      angle: (json['angle'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'damage': damage,
        'range': range,
        'telegraphDuration': telegraphDuration,
        'attackDuration': attackDuration,
        'cooldown': cooldown,
        'shape': shape,
        'width': width,
        'height': height,
        'angle': angle,
      };
}

/// 몬스터 데이터
class MonsterData {
  const MonsterData({
    required this.id,
    required this.name,
    required this.hp,
    required this.damage,
    required this.speed,
    required this.detectionRange,
    required this.attackRange,
    this.spritePrefix = 'goblin',
    this.aiType = 'chase',
    this.attackPatterns = const [],
    this.goldReward = 10,
    this.expReward = 5,
    this.isBoss = false,
  });

  final String id;
  final String name;
  final double hp;
  final double damage;
  final double speed;
  final double detectionRange;
  final double attackRange;
  final String spritePrefix;
  final String aiType; // chase, patrol, stationary, ranged
  final List<AttackPattern> attackPatterns;
  final int goldReward;
  final int expReward;
  final bool isBoss;

  factory MonsterData.fromJson(Map<String, dynamic> json) {
    final patternsJson = json['attackPatterns'] as List<dynamic>? ?? [];
    return MonsterData(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown',
      hp: (json['hp'] as num?)?.toDouble() ?? 30,
      damage: (json['damage'] as num?)?.toDouble() ?? 5,
      speed: (json['speed'] as num?)?.toDouble() ?? 50,
      detectionRange: (json['detectionRange'] as num?)?.toDouble() ?? 120,
      attackRange: (json['attackRange'] as num?)?.toDouble() ?? 30,
      spritePrefix: json['spritePrefix'] as String? ?? 'goblin',
      aiType: json['aiType'] as String? ?? 'chase',
      attackPatterns: patternsJson
          .map((e) => AttackPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      goldReward: json['goldReward'] as int? ?? 10,
      expReward: json['expReward'] as int? ?? 5,
      isBoss: json['isBoss'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hp': hp,
        'damage': damage,
        'speed': speed,
        'detectionRange': detectionRange,
        'attackRange': attackRange,
        'spritePrefix': spritePrefix,
        'aiType': aiType,
        'attackPatterns': attackPatterns.map((e) => e.toJson()).toList(),
        'goldReward': goldReward,
        'expReward': expReward,
        'isBoss': isBoss,
      };
}
