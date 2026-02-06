/// Arcana: The Three Hearts - 플레이어 상태 모델
library;

import 'item_data.dart';

/// 장착 장비
class Equipment {
  Equipment({
    this.weapon,
    this.armor,
    this.accessory1,
    this.accessory2,
  });

  String? weapon;
  String? armor;
  String? accessory1;
  String? accessory2;

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      weapon: json['weapon'] as String?,
      armor: json['armor'] as String?,
      accessory1: json['accessory1'] as String?,
      accessory2: json['accessory2'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'weapon': weapon,
        'armor': armor,
        'accessory1': accessory1,
        'accessory2': accessory2,
      };
}

/// 스킬 슬롯
class SkillSlots {
  SkillSlots({
    this.q,
    this.w,
    this.e,
    this.r,
  });

  String? q;
  String? w;
  String? e;
  String? r;

  factory SkillSlots.fromJson(Map<String, dynamic> json) {
    return SkillSlots(
      q: json['q'] as String?,
      w: json['w'] as String?,
      e: json['e'] as String?,
      r: json['r'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'q': q,
        'w': w,
        'e': e,
        'r': r,
      };

  String? getSkillAt(int index) {
    switch (index) {
      case 0:
        return q;
      case 1:
        return w;
      case 2:
        return e;
      case 3:
        return r;
      default:
        return null;
    }
  }

  void setSkillAt(int index, String? skillId) {
    switch (index) {
      case 0:
        q = skillId;
      case 1:
        w = skillId;
      case 2:
        e = skillId;
      case 3:
        r = skillId;
    }
  }
}

/// 심장 획득 상태
class HeartCollection {
  HeartCollection({
    this.courage = false,
    this.wisdom = false,
    this.love = false,
  });

  bool courage;
  bool wisdom;
  bool love;

  int get count => [courage, wisdom, love].where((e) => e).length;
  bool get hasAll => courage && wisdom && love;

  factory HeartCollection.fromJson(Map<String, dynamic> json) {
    return HeartCollection(
      courage: json['courage'] as bool? ?? false,
      wisdom: json['wisdom'] as bool? ?? false,
      love: json['love'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'courage': courage,
        'wisdom': wisdom,
        'love': love,
      };
}

/// 플레이어 상태 (저장용)
class PlayerState {
  PlayerState({
    this.hp = 100,
    this.maxHp = 100,
    this.mana = 100,
    this.maxMana = 100,
    this.gold = 0,
    this.heartGauge = 0,
    this.level = 1,
    this.exp = 0,
    List<InventoryItem>? inventory,
    Equipment? equipment,
    SkillSlots? skillSlots,
    HeartCollection? hearts,
    Map<String, double>? skillCooldowns,
  })  : inventory = inventory ?? [],
        equipment = equipment ?? Equipment(),
        skillSlots = skillSlots ?? SkillSlots(),
        hearts = hearts ?? HeartCollection(),
        skillCooldowns = skillCooldowns ?? {};

  double hp;
  double maxHp;
  double mana;
  double maxMana;
  int gold;
  int heartGauge;
  int level;
  int exp;
  List<InventoryItem> inventory;
  Equipment equipment;
  SkillSlots skillSlots;
  HeartCollection hearts;
  Map<String, double> skillCooldowns;

  /// 기본 스탯 (레벨, 장비 보정 전)
  double get baseAttackDamage => 25 + (level - 1) * 2;
  double get baseDefense => 0 + (level - 1) * 1;
  double get baseSpeed => 150;

  /// 다음 레벨까지 필요 경험치
  int get expToNextLevel => level * 100;

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      hp: (json['hp'] as num?)?.toDouble() ?? 100,
      maxHp: (json['maxHp'] as num?)?.toDouble() ?? 100,
      mana: (json['mana'] as num?)?.toDouble() ?? 100,
      maxMana: (json['maxMana'] as num?)?.toDouble() ?? 100,
      gold: json['gold'] as int? ?? 0,
      heartGauge: json['heartGauge'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      exp: json['exp'] as int? ?? 0,
      inventory: (json['inventory'] as List<dynamic>?)
              ?.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      equipment: json['equipment'] != null
          ? Equipment.fromJson(json['equipment'] as Map<String, dynamic>)
          : Equipment(),
      skillSlots: json['skillSlots'] != null
          ? SkillSlots.fromJson(json['skillSlots'] as Map<String, dynamic>)
          : SkillSlots(),
      hearts: json['hearts'] != null
          ? HeartCollection.fromJson(json['hearts'] as Map<String, dynamic>)
          : HeartCollection(),
      skillCooldowns: (json['skillCooldowns'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'hp': hp,
        'maxHp': maxHp,
        'mana': mana,
        'maxMana': maxMana,
        'gold': gold,
        'heartGauge': heartGauge,
        'level': level,
        'exp': exp,
        'inventory': inventory.map((e) => e.toJson()).toList(),
        'equipment': equipment.toJson(),
        'skillSlots': skillSlots.toJson(),
        'hearts': hearts.toJson(),
        'skillCooldowns': skillCooldowns,
      };

  PlayerState copyWith({
    double? hp,
    double? maxHp,
    double? mana,
    double? maxMana,
    int? gold,
    int? heartGauge,
    int? level,
    int? exp,
    List<InventoryItem>? inventory,
    Equipment? equipment,
    SkillSlots? skillSlots,
    HeartCollection? hearts,
    Map<String, double>? skillCooldowns,
  }) {
    return PlayerState(
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      gold: gold ?? this.gold,
      heartGauge: heartGauge ?? this.heartGauge,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      inventory: inventory ?? this.inventory,
      equipment: equipment ?? this.equipment,
      skillSlots: skillSlots ?? this.skillSlots,
      hearts: hearts ?? this.hearts,
      skillCooldowns: skillCooldowns ?? this.skillCooldowns,
    );
  }
}
