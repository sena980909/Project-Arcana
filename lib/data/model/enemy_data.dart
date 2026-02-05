/// Arcana: The Three Hearts - 적 데이터 모델
/// 적 스탯 및 드롭 테이블 정의
library;

import 'item.dart';

/// 적 타입
enum EnemyType {
  slime,      // 슬라임 (기본)
  goblin,     // 고블린
  skeleton,   // 스켈레톤
  boss,       // 보스
}

/// 적 데이터 클래스
class EnemyData {
  const EnemyData({
    required this.type,
    required this.name,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.detectRange,
    required this.attackRange,
    required this.attackCooldown,
    this.dropTable = const [],
    this.expReward = 0,
    this.goldReward = 0,
  });

  /// 적 타입
  final EnemyType type;

  /// 이름
  final String name;

  /// 최대 체력
  final double maxHealth;

  /// 공격력
  final double attack;

  /// 방어력
  final double defense;

  /// 이동 속도
  final double speed;

  /// 플레이어 감지 범위
  final double detectRange;

  /// 공격 범위
  final double attackRange;

  /// 공격 쿨다운 (초)
  final double attackCooldown;

  /// 드롭 테이블
  final List<DropEntry> dropTable;

  /// 경험치 보상
  final int expReward;

  /// 골드 보상
  final int goldReward;
}

/// 드롭 테이블 항목
class DropEntry {
  const DropEntry({
    required this.item,
    required this.dropRate,
    this.minQuantity = 1,
    this.maxQuantity = 1,
  });

  /// 드롭 아이템
  final Item item;

  /// 드롭 확률 (0.0 ~ 1.0)
  final double dropRate;

  /// 최소 드롭 수량
  final int minQuantity;

  /// 최대 드롭 수량
  final int maxQuantity;
}

/// 사전 정의된 적 데이터
class Enemies {
  Enemies._();

  /// 슬라임 (기본 적)
  static const slime = EnemyData(
    type: EnemyType.slime,
    name: '슬라임',
    maxHealth: 30,
    attack: 5,
    defense: 1,
    speed: 40,
    detectRange: 120,
    attackRange: 32,
    attackCooldown: 1.5,
    dropTable: [
      DropEntry(item: Items.healthPotion, dropRate: 0.3),
    ],
    expReward: 10,
    goldReward: 5,
  );

  /// 고블린
  static const goblin = EnemyData(
    type: EnemyType.goblin,
    name: '고블린',
    maxHealth: 50,
    attack: 10,
    defense: 3,
    speed: 60,
    detectRange: 150,
    attackRange: 40,
    attackCooldown: 1.2,
    dropTable: [
      DropEntry(item: Items.healthPotion, dropRate: 0.4),
      DropEntry(item: Items.woodenSword, dropRate: 0.1),
    ],
    expReward: 20,
    goldReward: 10,
  );

  /// 스켈레톤
  static const skeleton = EnemyData(
    type: EnemyType.skeleton,
    name: '스켈레톤',
    maxHealth: 40,
    attack: 12,
    defense: 2,
    speed: 50,
    detectRange: 180,
    attackRange: 48,
    attackCooldown: 1.0,
    dropTable: [
      DropEntry(item: Items.healthPotion, dropRate: 0.3),
      DropEntry(item: Items.ironSword, dropRate: 0.05),
      DropEntry(item: Items.leatherArmor, dropRate: 0.05),
    ],
    expReward: 25,
    goldReward: 15,
  );

  /// 이그드라 (Chapter 1 보스)
  static const igdra = EnemyData(
    type: EnemyType.boss,
    name: '오염된 세계수 이그드라',
    maxHealth: 500,
    attack: 25,
    defense: 10,
    speed: 30,
    detectRange: 300,
    attackRange: 64,
    attackCooldown: 2.0,
    dropTable: [
      DropEntry(item: Items.flameSword, dropRate: 0.5),
      DropEntry(item: Items.largeHealthPotion, dropRate: 1.0, minQuantity: 2, maxQuantity: 3),
    ],
    expReward: 200,
    goldReward: 100,
  );
}
