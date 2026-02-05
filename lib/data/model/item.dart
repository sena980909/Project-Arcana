/// Arcana: The Three Hearts - 아이템 데이터 모델
/// PRD 인벤토리 시스템용 아이템 정의
library;

import 'package:flutter/material.dart';

/// 아이템 타입
enum ItemType {
  weapon,     // 무기
  armor,      // 방어구
  consumable, // 소모품
  key,        // 열쇠/퀘스트 아이템
}

/// 아이템 희귀도
enum ItemRarity {
  common,    // 일반 (흰색)
  uncommon,  // 고급 (초록색)
  rare,      // 희귀 (파란색)
  epic,      // 영웅 (보라색)
  legendary, // 전설 (주황색)
}

/// 아이템 데이터 클래스
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = ItemRarity.common,
    this.attackBonus = 0,
    this.defenseBonus = 0,
    this.healthRestore = 0,
    this.stackable = false,
    this.maxStack = 1,
  });

  /// 고유 식별자
  final String id;

  /// 아이템 이름
  final String name;

  /// 아이템 설명
  final String description;

  /// 아이템 타입
  final ItemType type;

  /// 희귀도
  final ItemRarity rarity;

  /// 공격력 보너스 (무기)
  final int attackBonus;

  /// 방어력 보너스 (방어구)
  final int defenseBonus;

  /// 체력 회복량 (소모품)
  final int healthRestore;

  /// 중첩 가능 여부
  final bool stackable;

  /// 최대 중첩 수
  final int maxStack;

  /// 희귀도별 색상
  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
    }
  }

  /// 복사본 생성
  Item copyWith({
    String? id,
    String? name,
    String? description,
    ItemType? type,
    ItemRarity? rarity,
    int? attackBonus,
    int? defenseBonus,
    int? healthRestore,
    bool? stackable,
    int? maxStack,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      attackBonus: attackBonus ?? this.attackBonus,
      defenseBonus: defenseBonus ?? this.defenseBonus,
      healthRestore: healthRestore ?? this.healthRestore,
      stackable: stackable ?? this.stackable,
      maxStack: maxStack ?? this.maxStack,
    );
  }
}

/// 인벤토리 슬롯 (아이템 + 수량)
class InventorySlot {
  InventorySlot({
    required this.item,
    this.quantity = 1,
  });

  final Item item;
  int quantity;

  /// 아이템 추가 (중첩 가능한 경우)
  bool addQuantity(int amount) {
    if (!item.stackable) return false;
    if (quantity + amount > item.maxStack) return false;
    quantity += amount;
    return true;
  }

  /// 아이템 사용/제거
  bool removeQuantity(int amount) {
    if (quantity < amount) return false;
    quantity -= amount;
    return true;
  }
}

/// 사전 정의된 아이템 목록
class Items {
  Items._();

  // 무기
  static const woodenSword = Item(
    id: 'wooden_sword',
    name: '나무 검',
    description: '초보자용 나무 검. 공격력 +5',
    type: ItemType.weapon,
    rarity: ItemRarity.common,
    attackBonus: 5,
  );

  static const ironSword = Item(
    id: 'iron_sword',
    name: '철 검',
    description: '단단한 철로 만든 검. 공격력 +10',
    type: ItemType.weapon,
    rarity: ItemRarity.uncommon,
    attackBonus: 10,
  );

  static const flameSword = Item(
    id: 'flame_sword',
    name: '화염 검',
    description: '불꽃이 깃든 마법 검. 공격력 +20',
    type: ItemType.weapon,
    rarity: ItemRarity.rare,
    attackBonus: 20,
  );

  // 방어구
  static const leatherArmor = Item(
    id: 'leather_armor',
    name: '가죽 갑옷',
    description: '기본적인 가죽 갑옷. 방어력 +3',
    type: ItemType.armor,
    rarity: ItemRarity.common,
    defenseBonus: 3,
  );

  static const chainMail = Item(
    id: 'chain_mail',
    name: '사슬 갑옷',
    description: '금속 고리로 엮은 갑옷. 방어력 +7',
    type: ItemType.armor,
    rarity: ItemRarity.uncommon,
    defenseBonus: 7,
  );

  // 소모품
  static const healthPotion = Item(
    id: 'health_potion',
    name: '체력 포션',
    description: '체력을 30 회복합니다.',
    type: ItemType.consumable,
    rarity: ItemRarity.common,
    healthRestore: 30,
    stackable: true,
    maxStack: 10,
  );

  static const largeHealthPotion = Item(
    id: 'large_health_potion',
    name: '대형 체력 포션',
    description: '체력을 70 회복합니다.',
    type: ItemType.consumable,
    rarity: ItemRarity.uncommon,
    healthRestore: 70,
    stackable: true,
    maxStack: 5,
  );

  // 열쇠
  static const bossKey = Item(
    id: 'boss_key',
    name: '보스 열쇠',
    description: '보스 방의 문을 여는 열쇠.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // === 챕터 1: 잊혀진 숲 아이템 ===

  // 부서진 나뭇잎 펜던트 (스토리 아이템)
  static const brokenLeafPendant = Item(
    id: 'broken_leaf_pendant',
    name: '부서진 나뭇잎 펜던트',
    description: '한때 누군가의 소중한 물건이었던 것 같다. 희미하게 빛난다.',
    type: ItemType.key,
    rarity: ItemRarity.rare,
  );

  // 이그드라의 눈물 (보스 드롭)
  static const yggdraTear = Item(
    id: 'yggdra_tear',
    name: '이그드라의 눈물',
    description: '잊혀진 숲의 정령이 남긴 마지막 눈물. 슬픔과 해방의 감정이 담겨 있다.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // 잊혀진 숲의 아르카나 (챕터 클리어 보상)
  static const arcanaForgottenGrove = Item(
    id: 'arcana_forgotten_grove',
    name: '잊혀진 숲의 아르카나',
    description: '망각의 힘이 응축된 신비로운 결정체. 첫 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // === 챕터 4/5: 트루 엔딩 아이템 ===

  // 약속의 반지 (트루 엔딩 필수)
  static const promiseRing = Item(
    id: 'promise_ring',
    name: '약속의 반지',
    description: '영원한 약속을 상징하는 낡은 반지. 누구의 것이었을까?',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // 첫 번째 기억의 결정 (트루 엔딩 필수)
  static const firstMemoryCrystal = Item(
    id: 'first_memory_crystal',
    name: '첫 번째 기억의 결정',
    description: '가장 소중한 기억이 담긴 결정. 만지면 따뜻한 감정이 전해진다.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // === 챕터 2: 무너진 성채 아이템 ===

  // 깨진 왕관 조각 (스토리 아이템)
  static const brokenCrownShard = Item(
    id: 'broken_crown_shard',
    name: '깨진 왕관 조각',
    description: '한때 왕의 권위를 상징했을 왕관의 파편. 검은 얼룩이 묻어있다.',
    type: ItemType.key,
    rarity: ItemRarity.rare,
  );

  // 발두르의 눈물 (보스 드롭)
  static const baldurTear = Item(
    id: 'baldur_tear',
    name: '발두르의 눈물',
    description: '몰락한 왕이 남긴 검은 눈물의 결정. 슬픔과 광기가 응축되어 있다.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // 무너진 성채의 아르카나 (챕터 클리어 보상)
  static const arcanaCrumblingCitadel = Item(
    id: 'arcana_crumbling_citadel',
    name: '무너진 성채의 아르카나',
    description: '집착의 힘이 응축된 신비로운 결정체. 두 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // === 챕터 3: 침묵의 성당 아이템 ===

  // 첫 번째 기억 조각 (스토리 아이템)
  static const memoryFragment1 = Item(
    id: 'memory_fragment_1',
    name: '첫 번째 기억 조각',
    description: '고해실에서 발견한 기억의 파편. 비 오는 밤의 영상이 희미하게 떠오른다.',
    type: ItemType.key,
    rarity: ItemRarity.rare,
  );

  // 실렌시아의 눈물 (보스 드롭)
  static const silenciaTear = Item(
    id: 'silencia_tear',
    name: '실렌시아의 눈물',
    description: '침묵의 성녀가 남긴 황금빛 눈물. 신앙과 절망이 응축되어 있다.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // 침묵의 성당의 아르카나 (챕터 클리어 보상)
  static const arcanaSilentCathedral = Item(
    id: 'arcana_silent_cathedral',
    name: '침묵의 성당의 아르카나',
    description: '침묵의 힘이 응축된 신비로운 결정체. 세 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // === 챕터 4: 피의 정원 아이템 ===

  // 리리아나의 눈물 (보스 드롭)
  static const lilianaTear = Item(
    id: 'liliana_tear',
    name: '리리아나의 눈물',
    description: '사랑과 용서가 응축된 핏빛 결정. 따뜻하면서도 아프다.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // 피의 정원의 아르카나 (챕터 클리어 보상)
  static const arcanaBloodGarden = Item(
    id: 'arcana_blood_garden',
    name: '피의 정원의 아르카나',
    description: '사랑의 힘이 응축된 신비로운 결정체. 네 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // 리리아나의 반지 (스토리 아이템)
  static const lilianaRing = Item(
    id: 'liliana_ring',
    name: '리리아나의 반지',
    description: '두 사람의 영원한 사랑을 약속했던 반지. 희미하게 빛난다.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // === 챕터 5: 기억의 심연 아이템 ===

  // 현재의 심장 (그림자 통합 후 획득)
  static const heartOfPresent = Item(
    id: 'heart_of_present',
    name: '현재의 심장',
    description: '자기 자신을 받아들임으로써 얻은 심장. 두 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // 기억의 심연의 아르카나 (챕터 클리어 보상)
  static const arcanaAbyssOfMemory = Item(
    id: 'arcana_abyss_of_memory',
    name: '기억의 심연의 아르카나',
    description: '자아의 힘이 응축된 신비로운 결정체. 다섯 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // 그림자의 파편 (보스 드롭)
  static const shadowFragment = Item(
    id: 'shadow_fragment',
    name: '그림자의 파편',
    description: '그림자 자아가 남긴 검은 결정. 자기혐오와 죄책감이 응축되어 있다.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // === 챕터 6: 망각의 옥좌 아이템 ===

  // 미래의 심장 (트루 엔딩 - 세 개의 심장 완성)
  static const heartOfFuture = Item(
    id: 'heart_of_future',
    name: '미래의 심장',
    description: '구하겠다는 의지로 형성된 세 번째 심장. 세 개의 심장이 하나가 되었다.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // 망각의 옥좌의 아르카나 (챕터 클리어 보상)
  static const arcanaThroneOfOblivion = Item(
    id: 'arcana_throne_of_oblivion',
    name: '망각의 옥좌의 아르카나',
    description: '망각의 힘이 응축된 최후의 결정체. 여섯 번째 아르카나.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  // 망각의 눈물 (최종 보스 드롭)
  static const oblivionTear = Item(
    id: 'oblivion_tear',
    name: '망각의 눈물',
    description: '망각의 화신이 남긴 무색의 결정. 모든 기억과 망각이 응축되어 있다.',
    type: ItemType.key,
    rarity: ItemRarity.epic,
  );

  // 완전한 기억의 결정 (트루 엔딩 조건 아이템)
  static const completeMemoryCrystal = Item(
    id: 'complete_memory_crystal',
    name: '완전한 기억의 결정',
    description: '모든 기억이 복원된 완전한 결정. 과거, 현재, 미래가 하나로 어우러져 있다.',
    type: ItemType.key,
    rarity: ItemRarity.legendary,
  );

  /// 모든 아이템 목록
  static const List<Item> all = [
    woodenSword,
    ironSword,
    flameSword,
    leatherArmor,
    chainMail,
    healthPotion,
    largeHealthPotion,
    bossKey,
    // 챕터 1
    brokenLeafPendant,
    yggdraTear,
    arcanaForgottenGrove,
    // 챕터 2
    brokenCrownShard,
    baldurTear,
    arcanaCrumblingCitadel,
    // 챕터 3
    memoryFragment1,
    silenciaTear,
    arcanaSilentCathedral,
    // 챕터 4
    lilianaTear,
    arcanaBloodGarden,
    lilianaRing,
    // 챕터 5
    heartOfPresent,
    arcanaAbyssOfMemory,
    shadowFragment,
    // 챕터 6
    heartOfFuture,
    arcanaThroneOfOblivion,
    oblivionTear,
    completeMemoryCrystal,
    // 트루 엔딩
    promiseRing,
    firstMemoryCrystal,
  ];

  /// ID로 아이템 찾기
  static Item? findById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
