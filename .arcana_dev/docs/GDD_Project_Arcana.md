# Project Arcana: The Three Hearts
## Game Design Document (GDD)
### 프로그래머를 위한 기획 문서

**버전**: 1.0
**최종 수정일**: 2026-02-03
**작성자**: Lead Designer

---

## 목차

1. [게임 개요](#1-게임-개요)
2. [핵심 컨셉](#2-핵심-컨셉)
3. [기술 스택](#3-기술-스택)
4. [시스템 아키텍처](#4-시스템-아키텍처)
5. [핵심 게임플레이 루프](#5-핵심-게임플레이-루프)
6. [전투 시스템](#6-전투-시스템)
7. [스킬 시스템](#7-스킬-시스템)
8. [몬스터/보스 시스템](#8-몬스터보스-시스템)
9. [아이템 시스템](#9-아이템-시스템)
10. [맵/던전 시스템](#10-맵던전-시스템)
11. [NPC/대화 시스템](#11-npc대화-시스템)
12. [스토리/엔딩 시스템](#12-스토리엔딩-시스템)
13. [UI/UX 가이드라인](#13-uiux-가이드라인)
14. [데이터 파일 참조](#14-데이터-파일-참조)
15. [구현 우선순위](#15-구현-우선순위)
16. [테스트 체크리스트](#16-테스트-체크리스트)

---

## 1. 게임 개요

### 1.1 기본 정보

| 항목 | 내용 |
|------|------|
| **게임명** | Project Arcana: The Three Hearts |
| **장르** | 다크 판타지 로그라이크 액션 RPG |
| **플랫폼** | Windows (Steam), Web |
| **엔진** | Flutter + Flame Engine |
| **타겟 플레이 시간** | 1회 클리어 40-60분, 트루 엔딩 90-120분 |
| **타겟 유저** | 하데스, 데드셀 등 로그라이크 액션 게임 팬 |

### 1.2 게임 컨셉 한 줄 요약

> "잊혀진 자들의 왕국에서, 세 개의 심장을 찾아 인간성을 되찾는 망각의 여정"

### 1.3 핵심 셀링 포인트

1. **세 개의 심장 시스템**: 심장 = 인간성의 은유적 표현
2. **다크 판타지 스토리**: 감정적 깊이가 있는 서사
3. **듀얼 엔딩**: 숨겨진 아이템 수집에 따른 분기
4. **텔레그래프 기반 전투**: 모든 공격에 예고 동작

---

## 2. 핵심 컨셉

### 2.1 세 개의 심장 (Three Hearts)

게임의 핵심 테마이자 메카닉. 각 심장은 인간성의 일부를 상징함.

| 심장 | 상징 | 획득 시점 | 효과 |
|------|------|-----------|------|
| **첫 번째 심장** | 기억 (Memory) / 과거 | Chapter 2 보스 클리어 | 궁극기 1 해금, 최대 HP +50 |
| **두 번째 심장** | 수용 (Acceptance) / 현재 | Chapter 4 보스 클리어 | 궁극기 2 해금, 최대 마나 +30 |
| **세 번째 심장** | 의지 (Will) / 미래 | Chapter 5 보스 클리어 | 궁극기 3 해금, 공격력 +15% |

### 2.2 인간성 게이지 (Humanity Gauge)

- 심장 획득 수에 따라 1~4단계
- 단계가 높을수록 NPC 대화 옵션 확장
- 일부 숨겨진 상호작용 해금

### 2.3 듀얼 엔딩 조건

```
[일반 엔딩]
- 조건: 6챕터 최종 보스 클리어
- 결과: 주인공이 세계에서 잊혀짐

[트루 엔딩]
- 조건: 약속의 반지 + 첫 번째 기억의 결정 보유 상태로 최종 보스 클리어
- 결과: 릴리아나 구원, 주인공 기억 회복
```

**숨겨진 아이템 위치**:
- `약속의 반지`: Chapter 4 맵 (49, 1) - 숨겨진 정원 구석
- `첫 번째 기억의 결정`: Chapter 5 맵 (5, 5) - 기억의 제단

---

## 3. 기술 스택

### 3.1 개발 환경

```yaml
Framework: Flutter 3.x
Game Engine: Flame 1.x
Language: Dart
State Management: Riverpod
Audio: flame_audio
Animation: flame (SpriteAnimation)
Data Format: JSON
```

### 3.2 권장 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── app/                      # 앱 설정, 라우팅
├── config/                   # 상수, 에셋 경로
├── data/                     # 데이터 모델, 리포지토리
│   ├── models/              # 데이터 클래스
│   │   ├── monster.dart
│   │   ├── skill.dart
│   │   ├── item.dart
│   │   └── dialogue.dart
│   └── repositories/        # JSON 로딩, 데이터 접근
├── game/                     # Flame 게임 코어
│   ├── components/          # 게임 컴포넌트
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── projectiles/
│   │   └── effects/
│   ├── systems/             # 게임 시스템
│   │   ├── combat_system.dart
│   │   ├── skill_system.dart
│   │   └── spawn_system.dart
│   └── arcana_game.dart     # 메인 게임 클래스
├── providers/                # Riverpod 프로바이더
└── ui/                       # Flutter UI 위젯
    ├── screens/
    ├── widgets/
    └── overlays/

assets/
├── data/                     # JSON 데이터 파일
├── images/                   # 스프라이트, 배경
├── audio/                    # BGM, SFX
└── fonts/                    # 폰트
```

---

## 4. 시스템 아키텍처

### 4.1 전체 시스템 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   UI Layer  │  │  Overlays   │  │   State (Riverpod)  │  │
│  │  (Screens)  │◄─┤  (HUD, etc) │◄─┤   - GameState       │  │
│  └─────────────┘  └─────────────┘  │   - PlayerState     │  │
│         │                │         │   - InventoryState  │  │
│         ▼                ▼         └─────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    Flame GameWidget                  │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │    │
│  │  │  Player  │  │ Enemies  │  │   Game Systems   │   │    │
│  │  │Component │  │Component │  │  - CombatSystem  │   │    │
│  │  └──────────┘  └──────────┘  │  - SkillSystem   │   │    │
│  │        │             │       │  - SpawnSystem   │   │    │
│  │        ▼             ▼       │  - AISystem      │   │    │
│  │  ┌─────────────────────────┐ └──────────────────┘   │    │
│  │  │    Collision System     │                        │    │
│  │  │    (Hitbox/Hurtbox)     │                        │    │
│  │  └─────────────────────────┘                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                           │                                  │
│  ┌────────────────────────▼────────────────────────────┐    │
│  │                  Data Layer                          │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │    │
│  │  │  JSON Files  │  │ Repositories │  │  Models   │  │    │
│  │  │  (assets/)   │──│  (Loaders)   │──│  (Dart)   │  │    │
│  │  └──────────────┘  └──────────────┘  └───────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 핵심 클래스 설계

#### GameState (전역 게임 상태)

```dart
class GameState {
  int currentChapter;           // 1-6
  bool[] heartsAcquired;        // [false, false, false]
  List<String> inventory;       // 아이템 ID 목록
  Map<String, bool> flags;      // 스토리 플래그
  int gold;
  Duration playTime;

  // 엔딩 조건 체크
  bool canGetTrueEnding() {
    return inventory.contains('promise_ring') &&
           inventory.contains('first_memory_crystal');
  }
}
```

#### PlayerState (플레이어 상태)

```dart
class PlayerState {
  int maxHp;
  int currentHp;
  int maxMana;
  int currentMana;
  int heartGauge;              // 0-100

  int baseAttack;
  int baseDefense;
  double critChance;
  double critDamage;

  String weaponId;
  String armorId;
  String accessoryId;
  List<String> equippedSkills; // 최대 4개

  // 스탯 계산 (장비 + 버프 포함)
  int get totalAttack => ...;
  int get totalDefense => ...;
}
```

---

## 5. 핵심 게임플레이 루프

### 5.1 메인 루프 플로우

```
[게임 시작]
     │
     ▼
┌─────────────┐
│   메인 허브  │◄──────────────────────────────┐
│  (망각의 방) │                               │
└──────┬──────┘                               │
       │ 던전 선택                             │
       ▼                                      │
┌─────────────┐     ┌─────────────┐          │
│ 챕터 N 던전 │────►│   전투 중   │          │
└──────┬──────┘     └──────┬──────┘          │
       │                   │                  │
       │    ┌──────────────┼──────────────┐  │
       │    ▼              ▼              ▼  │
       │ [승리]        [패배]        [도주]  │
       │    │              │              │  │
       │    ▼              ▼              │  │
       │ ┌──────┐    ┌──────────┐         │  │
       │ │ 보상 │    │ 허브 귀환 │◄────────┘  │
       │ │ 획득 │    │ (일부 손실)│            │
       │ └──┬───┘    └──────────┘            │
       │    │                                │
       │    ▼                                │
       │ ┌────────────┐                      │
       │ │ 보스 처치? │                      │
       │ └──────┬─────┘                      │
       │    예 │  아니오                      │
       │       │    └────────────────────────┤
       ▼       ▼                             │
┌─────────────────┐                          │
│ 챕터 클리어     │                          │
│ (심장 획득 등)  │──────────────────────────┘
└─────────────────┘
       │
       ▼ (Chapter 6 클리어 시)
┌─────────────────┐
│    엔딩 분기    │
└─────────────────┘
```

### 5.2 던전 런 플로우 (단일 챕터)

```
[던전 진입]
     │
     ▼
┌─────────────┐
│  방 1 (일반) │─── 몬스터 1-3마리 스폰
└──────┬──────┘
       │ 클리어
       ▼
┌─────────────┐
│  방 2 (일반) │─── 몬스터 2-4마리 스폰
└──────┬──────┘
       │ 클리어
       ▼
┌─────────────────┐
│  방 3 (엘리트) │─── 엘리트 몬스터 1마리 + 일반 1-2마리
└────────┬────────┘
         │ 클리어
         ▼
    [중간 보상]
         │
         ▼
┌─────────────┐
│  방 4 (일반) │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  방 5 (보스방)  │─── 챕터 보스 등장
└────────┬────────┘
         │ 클리어
         ▼
   [챕터 클리어]
```

### 5.3 전투 프레임워크

매 프레임(16.67ms @ 60fps)마다:

```dart
void update(double dt) {
  // 1. 입력 처리
  handleInput();

  // 2. AI 업데이트 (적)
  updateEnemyAI(dt);

  // 3. 스킬/공격 업데이트
  updateSkills(dt);
  updateProjectiles(dt);

  // 4. 물리/이동
  updateMovement(dt);

  // 5. 충돌 감지
  checkCollisions();

  // 6. 데미지 계산
  processDamage();

  // 7. 상태 효과 틱
  updateStatusEffects(dt);

  // 8. 사망 체크
  checkDeaths();

  // 9. UI 업데이트
  updateUI();
}
```

---

## 6. 전투 시스템

### 6.1 데미지 공식

```dart
// 기본 데미지 계산
int calculateDamage({
  required int baseDamage,
  required int attackerAttack,
  required int defenderDefense,
  required double skillMultiplier,
  required bool isCritical,
  required double critDamage,
}) {
  // 1. 기본 데미지 = (기본 + 공격력) * 스킬 배율
  double damage = (baseDamage + attackerAttack) * skillMultiplier;

  // 2. 방어력 적용 (감소율 = 방어력 / (방어력 + 100))
  double reduction = defenderDefense / (defenderDefense + 100);
  damage *= (1 - reduction);

  // 3. 크리티컬 적용
  if (isCritical) {
    damage *= critDamage;
  }

  // 4. 최소 데미지 보장
  return max(1, damage.round());
}
```

### 6.2 히트박스/허트박스 시스템

```dart
// 모든 전투 엔티티는 두 종류의 박스를 가짐
class CombatEntity {
  // 허트박스: 피격 판정 영역 (항상 활성)
  RectangleHitbox hurtbox;

  // 히트박스: 공격 판정 영역 (공격 시에만 활성)
  RectangleHitbox? activeHitbox;

  // 무적 프레임 (피격 후 일시적 무적)
  double iFrameDuration = 0.0;
}
```

### 6.3 텔레그래프 시스템 (핵심!)

**모든 적 공격은 반드시 텔레그래프(예고 동작)를 가져야 함**

```dart
class EnemyAttack {
  String attackId;
  double telegraphDuration;    // 예고 시간 (0.3~2.5초)
  String telegraphAnimation;   // 예고 애니메이션 이름
  String telegraphVfx;         // 예고 이펙트 (범위 표시 등)
  Color warningColor;          // 범위 표시 색상

  // 실제 공격 데이터
  int damage;
  double attackDuration;
  HitboxData hitbox;
}
```

**텔레그래프 시간 가이드라인**:

| 공격 유형 | 텔레그래프 시간 | 예시 |
|-----------|----------------|------|
| 빠른 공격 | 0.3 ~ 0.5초 | 일반 근접 공격 |
| 보통 공격 | 0.6 ~ 1.0초 | 강공격, 돌진 |
| 강력한 공격 | 1.0 ~ 1.5초 | 광역기, 보스 스킬 |
| 즉사급 공격 | 1.5 ~ 2.5초 | 보스 궁극기 |

### 6.4 회피/무적 시스템

```dart
class DashSystem {
  // 대시 기본 설정
  double dashDistance = 100.0;
  double dashDuration = 0.2;    // 대시 지속 시간
  double iFrameStart = 0.05;    // 무적 시작 시점 (대시 후 0.05초)
  double iFrameEnd = 0.18;      // 무적 종료 시점
  double cooldown = 0.8;        // 대시 쿨다운

  // 완벽 회피 (Perfect Dodge)
  double perfectDodgeWindow = 0.1;  // 적 공격 히트 0.1초 전~후

  void onPerfectDodge() {
    // 1. 시간 슬로우 (0.3초간 50% 속도)
    gameRef.timeScale = 0.5;
    Future.delayed(Duration(milliseconds: 300), () {
      gameRef.timeScale = 1.0;
    });

    // 2. 심장 게이지 +10
    playerState.heartGauge += 10;

    // 3. 다음 공격 크리티컬 보장
    playerState.guaranteedCritical = true;
  }
}
```

### 6.5 상태 이상 시스템

```dart
enum StatusEffect {
  burn,       // 화상: 3초간 0.5초마다 최대HP 2% 데미지
  bleed,      // 출혈: 4초간 0.5초마다 고정 5 데미지
  poison,     // 중독: 5초간 1초마다 최대HP 3% 데미지
  slow,       // 둔화: 3초간 이동속도 30% 감소
  stun,       // 기절: 1-2초간 행동 불가
  curse,      // 저주: 5초간 받는 데미지 25% 증가
  weakness,   // 허약: 5초간 주는 데미지 20% 감소
  freeze,     // 빙결: 2초간 행동 불가 + 받는 데미지 50% 증가
}
```

---

## 7. 스킬 시스템

### 7.1 스킬 슬롯 구조

```
[항상 장착]
- 기본 공격 (3타 콤보)
- 대시 (shadow_step)

[선택 장착 - 4슬롯]
- 스킬 1 (액티브)
- 스킬 2 (액티브)
- 스킬 3 (액티브)
- 스킬 4 (액티브)

[심장 궁극기 - 자동 해금]
- 첫 번째 심장 궁극기 (heart_of_memory)
- 두 번째 심장 궁극기 (heart_of_acceptance)
- 세 번째 심장 궁극기 (heart_of_will)
- 삼위일체 (three_hearts_unity) - 3심장 모두 획득 시
```

### 7.2 스킬 데이터 로딩

```dart
// JSON에서 스킬 로딩
class SkillRepository {
  Future<List<Skill>> loadSkills() async {
    final json = await rootBundle.loadString('assets/data/player_skills.json');
    final data = jsonDecode(json);

    List<Skill> skills = [];

    // 기본 공격
    for (var s in data['basic_attacks']) {
      skills.add(Skill.fromJson(s, SkillType.basic));
    }

    // 액티브 스킬
    for (var s in data['active_skills']) {
      skills.add(Skill.fromJson(s, SkillType.active));
    }

    // 궁극기
    for (var s in data['ultimates']) {
      skills.add(Skill.fromJson(s, SkillType.ultimate));
    }

    // 패시브
    for (var s in data['passives']) {
      skills.add(Skill.fromJson(s, SkillType.passive));
    }

    return skills;
  }
}
```

### 7.3 스킬 사용 로직

```dart
class SkillSystem {
  bool canUseSkill(Skill skill, PlayerState player) {
    // 1. 쿨다운 체크
    if (skill.currentCooldown > 0) return false;

    // 2. 마나/심장 게이지 체크
    if (skill.type == SkillType.ultimate) {
      if (player.heartGauge < skill.cost) return false;
    } else {
      if (player.currentMana < skill.cost) return false;
    }

    // 3. 해금 조건 체크 (궁극기)
    if (skill.type == SkillType.ultimate) {
      if (!checkUnlockCondition(skill, player)) return false;
    }

    return true;
  }

  void useSkill(Skill skill, PlayerState player) {
    // 1. 비용 차감
    if (skill.type == SkillType.ultimate) {
      player.heartGauge -= skill.cost;
    } else {
      player.currentMana -= skill.cost;
    }

    // 2. 쿨다운 시작
    skill.currentCooldown = skill.cooldown;

    // 3. 스킬 효과 발동
    executeSkillEffect(skill);
  }
}
```

### 7.4 심장 게이지 충전

```dart
class HeartGaugeSystem {
  void onDamageDealt(int damage) {
    // 데미지 10당 1 충전
    playerState.heartGauge += (damage / 10).floor();
  }

  void onDamageTaken(int damage) {
    // 받은 데미지 5당 1 충전
    playerState.heartGauge += (damage / 5).floor();
  }

  void onPerfectDodge() {
    // 완벽 회피 시 10 충전
    playerState.heartGauge += 10;
  }

  void onKill() {
    // 적 처치 시 5 충전
    playerState.heartGauge += 5;
  }
}
```

---

## 8. 몬스터/보스 시스템

### 8.1 몬스터 데이터 구조

```dart
class Monster {
  String id;
  String name;
  MonsterType type;        // normal, elite, boss
  int chapter;

  // 기본 스탯
  int baseHp;
  int baseAttack;
  int baseDefense;
  double moveSpeed;

  // AI 설정
  double detectionRange;
  double attackRange;
  BehaviorTree behaviorTree;

  // 공격 패턴
  List<AttackPattern> attacks;

  // 드롭 테이블
  List<DropEntry> drops;

  // 비주얼
  String spriteSheet;
  Map<String, AnimationData> animations;
}
```

### 8.2 AI 행동 트리

```dart
// JSON의 decision_tree를 행동 트리로 변환
class BehaviorTree {
  BehaviorNode root;

  static BehaviorTree fromJson(List<dynamic> decisionTree) {
    // decision_tree 배열을 우선순위 순서대로 처리
    // 각 노드는 condition과 action을 가짐

    var children = <BehaviorNode>[];
    for (var decision in decisionTree) {
      children.add(
        SequenceNode([
          ConditionNode(decision['condition']),
          ActionNode(decision['action']),
        ])
      );
    }

    return BehaviorTree(SelectorNode(children));
  }
}

// 예시: 화염 정령 AI
/*
  1. HP < 30% → 자폭 시도
  2. 거리 > 150 → 접근
  3. 거리 < 50 → 후퇴
  4. 기본 → 근접 공격
*/
```

### 8.3 보스 페이즈 시스템

```dart
class BossController extends EnemyController {
  int currentPhase = 1;
  List<BossPhase> phases;

  @override
  void update(double dt) {
    super.update(dt);

    // 페이즈 전환 체크
    checkPhaseTransition();
  }

  void checkPhaseTransition() {
    for (var phase in phases) {
      if (phase.phaseNumber > currentPhase) {
        bool shouldTransition = false;

        // HP 기반 전환
        if (phase.trigger['hp_threshold'] != null) {
          double threshold = phase.trigger['hp_threshold'];
          if (currentHpPercent <= threshold) {
            shouldTransition = true;
          }
        }

        if (shouldTransition) {
          startPhaseTransition(phase);
          break;
        }
      }
    }
  }

  void startPhaseTransition(BossPhase newPhase) {
    // 1. 현재 행동 중단
    cancelCurrentAction();

    // 2. 전환 애니메이션 재생
    playAnimation(newPhase.transitionAnimation);

    // 3. 전환 중 무적
    isInvulnerable = true;

    // 4. 애니메이션 완료 후
    onAnimationComplete = () {
      currentPhase = newPhase.phaseNumber;

      // 스탯 변경 적용
      applyStatChanges(newPhase.statChanges);

      // 새 스킬 해금
      for (var skill in newPhase.unlockedSkills) {
        enableAttack(skill);
      }

      isInvulnerable = false;
    };
  }
}
```

### 8.4 특수 보스 메카닉

#### 그림자 자아 (Chapter 5)

```dart
class ShadowSelfBoss extends BossController {
  // 특수 속성: 죽일 수 없음
  @override
  bool get canBeKilled => false;

  // 승리 조건: 접근하여 통합
  double integrationRange = 30.0;
  double integrationProgress = 0.0;
  double integrationRequired = 3.0;  // 3초간 접근 유지

  @override
  void update(double dt) {
    super.update(dt);

    double distanceToPlayer = position.distanceTo(player.position);

    if (distanceToPlayer <= integrationRange) {
      integrationProgress += dt;

      // UI에 진행도 표시
      showIntegrationBar(integrationProgress / integrationRequired);

      if (integrationProgress >= integrationRequired) {
        onIntegrationComplete();
      }
    } else {
      // 범위 벗어나면 리셋
      integrationProgress = 0;
    }
  }

  void onIntegrationComplete() {
    // 보스 무력화
    isDefeated = true;

    // 특수 연출
    playAnimation('integration_success');

    // 세 번째 심장 획득
    gameState.acquireHeart(3);
  }
}
```

#### 망각의 화신 (Final Boss) - 엔딩 분기

```dart
class AvatarOfOblivionBoss extends BossController {
  @override
  void onDefeated() {
    // 최종 선택 분기
    if (gameState.canGetTrueEnding()) {
      // 선택지 UI 표시
      showEndingChoice();
    } else {
      // 일반 엔딩 직행
      triggerNormalEnding();
    }
  }

  void showEndingChoice() {
    // 선택지:
    // 1. "릴리아나를 용서한다" → 트루 엔딩
    // 2. "망각 속으로 사라진다" → 일반 엔딩
    overlayManager.show('ending_choice', {
      'options': [
        {'text': '릴리아나를 용서한다', 'action': 'true_ending'},
        {'text': '망각 속으로 사라진다', 'action': 'normal_ending'},
      ]
    });
  }
}
```

---

## 9. 아이템 시스템

### 9.1 아이템 카테고리

| 카테고리 | 설명 | 저장 방식 |
|----------|------|-----------|
| weapons | 무기 - 공격력, 특수 효과 | 장비 슬롯 (1개) |
| armors | 방어구 - 방어력, HP | 장비 슬롯 (1개) |
| accessories | 악세서리 - 다양한 효과 | 장비 슬롯 (1개) |
| consumables | 소비템 - 회복, 버프 | 인벤토리 (스택) |
| materials | 재료 - 제작용 | 인벤토리 (스택) |
| special | 특수 아이템 - 심장, 스토리 | 특수 저장소 |

### 9.2 장비 스탯 계산

```dart
class EquipmentSystem {
  PlayerStats calculateTotalStats(PlayerState player) {
    var stats = PlayerStats.base(player);

    // 무기 스탯
    if (player.weaponId != null) {
      var weapon = itemRepo.getItem(player.weaponId);
      stats.attack += weapon.stats['attack'] ?? 0;
      stats.critChance += weapon.stats['crit_chance'] ?? 0;
      stats.critDamage += weapon.stats['crit_damage'] ?? 0;

      // 특수 효과
      applySpecialEffect(weapon.specialEffect, stats);
    }

    // 방어구 스탯
    if (player.armorId != null) {
      var armor = itemRepo.getItem(player.armorId);
      stats.defense += armor.stats['defense'] ?? 0;
      stats.maxHp += armor.stats['max_hp'] ?? 0;
    }

    // 악세서리 스탯
    if (player.accessoryId != null) {
      var accessory = itemRepo.getItem(player.accessoryId);
      applyAccessoryEffects(accessory, stats);
    }

    return stats;
  }
}
```

### 9.3 드롭 시스템

```dart
class DropSystem {
  List<ItemDrop> calculateDrops(Monster monster) {
    var drops = <ItemDrop>[];

    for (var entry in monster.drops) {
      // 확률 체크
      if (random.nextDouble() < entry.chance) {
        // 수량 결정
        int quantity = random.nextInt(entry.maxQuantity - entry.minQuantity + 1)
                       + entry.minQuantity;

        drops.add(ItemDrop(
          itemId: entry.itemId,
          quantity: quantity,
        ));
      }
    }

    // 골드 드롭
    drops.add(ItemDrop(
      type: 'gold',
      quantity: monster.goldDrop,
    ));

    return drops;
  }
}
```

### 9.4 제작 시스템

```dart
class CraftingSystem {
  bool canCraft(CraftingRecipe recipe, Inventory inventory) {
    for (var material in recipe.materials) {
      int owned = inventory.getQuantity(material.itemId);
      if (owned < material.quantity) {
        return false;
      }
    }

    if (inventory.gold < recipe.goldCost) {
      return false;
    }

    return true;
  }

  void craft(CraftingRecipe recipe, Inventory inventory) {
    // 재료 소모
    for (var material in recipe.materials) {
      inventory.removeItem(material.itemId, material.quantity);
    }
    inventory.gold -= recipe.goldCost;

    // 결과물 지급
    inventory.addItem(recipe.resultItemId, 1);
  }
}
```

---

## 10. 맵/던전 시스템

### 10.1 맵 데이터 구조

```dart
class GameMap {
  String id;
  String name;
  int chapter;

  int width;
  int height;
  int tileSize;

  String asciiLayout;          // ASCII 맵 레이아웃
  Map<String, TileType> legend; // ASCII 문자 → 타일 타입 매핑

  List<SpawnPoint> spawnPoints;
  List<HiddenItem> hiddenItems;

  String backgroundImage;
  String tileset;
  String bgmId;
  String ambienceId;
}
```

### 10.2 ASCII 맵 파싱

```dart
class MapParser {
  GameMapData parse(GameMap mapConfig) {
    var tiles = <List<Tile>>[];
    var lines = mapConfig.asciiLayout.trim().split('\n');

    for (int y = 0; y < lines.length; y++) {
      var row = <Tile>[];
      for (int x = 0; x < lines[y].length; x++) {
        String char = lines[y][x];
        TileType type = mapConfig.legend[char] ?? TileType.empty;

        row.add(Tile(
          x: x,
          y: y,
          type: type,
          walkable: type.isWalkable,
          sprite: getTileSprite(type, mapConfig.tileset),
        ));
      }
      tiles.add(row);
    }

    return GameMapData(
      tiles: tiles,
      width: mapConfig.width,
      height: mapConfig.height,
      tileSize: mapConfig.tileSize,
    );
  }
}
```

### 10.3 타일 타입

```dart
enum TileType {
  empty('.', walkable: true),
  wall('#', walkable: false),
  water('~', walkable: false, hazard: true),
  lava('L', walkable: false, hazard: true, damage: 10),
  pit('O', walkable: false, instant_death: true),
  door('D', walkable: true, interactive: true),
  chest('C', walkable: true, interactive: true),
  npc('N', walkable: true, interactive: true),
  hiddenPath('?', walkable: true, hidden: true),
  spawn('S', walkable: true),
  bossSpawn('B', walkable: true),
  exit('E', walkable: true, interactive: true),
}
```

### 10.4 숨겨진 아이템 시스템

```dart
class HiddenItemSystem {
  void checkHiddenItems(Vector2 playerPosition, GameMap map) {
    for (var hidden in map.hiddenItems) {
      if (!hidden.found) {
        double distance = playerPosition.distanceTo(hidden.position);

        if (distance <= hidden.detectionRadius) {
          // 발견 연출
          showDiscoveryEffect(hidden.position);

          // 아이템 획득
          inventory.addItem(hidden.itemId, 1);

          hidden.found = true;

          // 특수 아이템인 경우 대사/연출
          if (hidden.itemId == 'promise_ring') {
            showSpecialItemDialogue('promise_ring');
          } else if (hidden.itemId == 'first_memory_crystal') {
            showSpecialItemDialogue('first_memory_crystal');
          }
        }
      }
    }
  }
}
```

---

## 11. NPC/대화 시스템

### 11.1 대화 데이터 구조

```dart
class DialogueNode {
  String id;
  String speakerId;
  String text;
  String? portrait;
  String? voiceClip;

  List<DialogueChoice>? choices;
  String? nextId;              // 선택지 없으면 자동 진행

  DialogueTrigger? trigger;    // 특수 효과 트리거
}

class DialogueChoice {
  String text;
  String? nextId;
  DialogueTrigger? trigger;
  ChoiceCondition? condition;  // 조건부 표시
}

class DialogueTrigger {
  String type;                 // 'give_item', 'start_quest', 'unlock_shop' 등
  Map<String, dynamic> params;
}
```

### 11.2 조건부 대화 시스템

```dart
class DialogueConditionChecker {
  bool checkConditions(Map<String, dynamic> conditions, GameState state) {
    // 챕터 조건
    if (conditions.containsKey('chapter')) {
      if (state.currentChapter < conditions['chapter']) return false;
    }
    if (conditions.containsKey('max_chapter')) {
      if (state.currentChapter > conditions['max_chapter']) return false;
    }

    // 심장 조건
    if (conditions.containsKey('hearts_required')) {
      int required = conditions['hearts_required'];
      if (state.heartsAcquired.where((h) => h).length < required) return false;
    }
    if (conditions.containsKey('specific_heart')) {
      int heartIndex = conditions['specific_heart'] - 1;
      if (!state.heartsAcquired[heartIndex]) return false;
    }

    // 아이템 조건
    if (conditions.containsKey('has_item')) {
      if (!state.inventory.contains(conditions['has_item'])) return false;
    }

    // 플래그 조건
    if (conditions.containsKey('flag')) {
      if (state.flags[conditions['flag']] != true) return false;
    }

    return true;
  }

  String? selectDialogue(NPC npc, GameState state) {
    // 조건부 대화 우선 체크 (우선순위 순)
    for (var conditional in npc.conditionalDialogues) {
      if (checkConditions(conditional.conditions, state)) {
        return conditional.dialogueId;
      }
    }

    // 기본 대화
    return npc.defaultDialogueId;
  }
}
```

### 11.3 대화 UI 흐름

```
[NPC 상호작용]
     │
     ▼
┌─────────────────────┐
│ 조건 체크           │
│ (장, 아이템, 심장)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ 대화 시퀀스 시작    │
│ - 배경 어둡게       │
│ - 대화창 표시       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐     ┌──────────────┐
│ 대화 노드 표시      │────►│ 선택지 있음? │
└─────────────────────┘     └──────┬───────┘
           ▲                       │
           │               예      │  아니오
           │         ┌─────────────┴──────────────┐
           │         ▼                            ▼
           │  ┌─────────────┐            ┌───────────────┐
           │  │ 선택지 표시 │            │ 다음 노드로   │
           │  └──────┬──────┘            │ 자동 진행     │
           │         │ 선택              └───────┬───────┘
           │         ▼                           │
           │  ┌─────────────┐                    │
           └──│ 트리거 실행 │◄───────────────────┘
              │ (선택적)    │
              └──────┬──────┘
                     │
                     ▼
              [대화 종료 또는 다음 노드]
```

---

## 12. 스토리/엔딩 시스템

### 12.1 스토리 플래그 관리

```dart
class StoryFlagManager {
  Map<String, bool> flags = {};

  // 주요 플래그 목록
  static const List<String> majorFlags = [
    'met_liliana',              // 릴리아나와 첫 만남
    'learned_truth',            // 진실을 알게 됨
    'forgave_liliana',          // 릴리아나를 용서함
    'found_promise_ring',       // 약속의 반지 발견
    'found_memory_crystal',     // 기억의 결정 발견
    'volkan_trust',             // 볼칸의 신뢰 획득
    'elias_full_lore',          // 엘리아스의 모든 이야기 들음
  ];

  void setFlag(String flag, bool value) {
    flags[flag] = value;
    onFlagChanged?.call(flag, value);
  }
}
```

### 12.2 엔딩 시퀀스

```dart
class EndingManager {
  void startEnding(String endingType) {
    switch (endingType) {
      case 'normal_ending':
        playNormalEnding();
        break;
      case 'true_ending':
        playTrueEnding();
        break;
    }
  }

  void playNormalEnding() {
    // 1. 컷신: 주인공이 망각 속으로 사라짐
    cutsceneManager.play('ending_normal_1');

    // 2. 에필로그 대화
    dialogueManager.startSequence('normal_ending_epilogue');

    // 3. 엔딩 크레딧
    showCredits(endingType: 'normal');

    // 4. 타이틀로 복귀 (+ New Game+ 해금)
    unlockNewGamePlus();
  }

  void playTrueEnding() {
    // 1. 컷신: 릴리아나 용서, 기억 회복
    cutsceneManager.play('ending_true_1');

    // 2. 약속의 반지 사용 연출
    cutsceneManager.play('ending_true_ring');

    // 3. 기억 회복 연출
    cutsceneManager.play('ending_true_memory');

    // 4. 에필로그 대화 (더 긴 버전)
    dialogueManager.startSequence('true_ending_epilogue');

    // 5. 엔딩 크레딧 (+ 추가 스태프롤)
    showCredits(endingType: 'true');

    // 6. 히든 콘텐츠 해금
    unlockSecretContent();
  }
}
```

### 12.3 챕터별 스토리 이벤트

| 챕터 | 주요 이벤트 | 획득 심장 |
|------|-------------|-----------|
| 1 | 망각의 왕국 진입, 릴리아나 첫 등장 | - |
| 2 | 기억의 파편 수집, 과거 회상 | 첫 번째 심장 |
| 3 | 릴리아나의 진실 일부 공개 | - |
| 4 | 약속의 반지 획득 가능, 정원의 비밀 | 두 번째 심장 |
| 5 | 그림자 자아와의 대면, 내면 통합 | 세 번째 심장 |
| 6 | 최종 대결, 엔딩 분기 | - |

---

## 13. UI/UX 가이드라인

### 13.1 HUD 레이아웃

```
┌────────────────────────────────────────────────────────┐
│ [HP Bar]████████████░░░░  [Mana Bar]████████░░░░       │
│ [Heart Gauge]███████░░░░░░░░░░░░░░░░░░░░               │
├────────────────────────────────────────────────────────┤
│                                                        │
│                                                        │
│                    [게임 화면]                          │
│                                                        │
│                                                        │
├────────────────────────────────────────────────────────┤
│ [스킬1] [스킬2] [스킬3] [스킬4]    [대시]    [궁극기]   │
│   Q       W       E       R        Space      F        │
└────────────────────────────────────────────────────────┘
```

### 13.2 색상 팔레트

```dart
class GameColors {
  // 주요 색상
  static const primary = Color(0xFF2D1B4E);      // 다크 퍼플
  static const secondary = Color(0xFF8B4513);    // 브라운
  static const accent = Color(0xFFFFD700);       // 골드

  // HP/상태 색상
  static const hpFull = Color(0xFF4CAF50);       // 초록
  static const hpLow = Color(0xFFF44336);        // 빨강
  static const mana = Color(0xFF2196F3);         // 파랑
  static const heartGauge = Color(0xFF9C27B0);   // 보라

  // 희귀도 색상
  static const common = Color(0xFFAAAAAA);       // 회색
  static const uncommon = Color(0xFF4CAF50);     // 초록
  static const rare = Color(0xFF2196F3);         // 파랑
  static const epic = Color(0xFF9C27B0);         // 보라
  static const legendary = Color(0xFFFF9800);    // 오렌지

  // 데미지 텍스트
  static const normalDamage = Color(0xFFFFFFFF); // 흰색
  static const criticalDamage = Color(0xFFFFD700); // 금색
  static const heal = Color(0xFF4CAF50);         // 초록
}
```

### 13.3 텔레그래프 시각적 표현

```dart
class TelegraphVisuals {
  // 위험 영역 표시
  static void showDangerZone({
    required Vector2 center,
    required double radius,
    required double duration,
    required Color color,
  }) {
    // 1. 바닥에 원형/사각형 표시
    // 2. 색상: 빨간색 계열, 투명도 30-50%
    // 3. 가장자리 펄스 애니메이션
    // 4. duration 동안 점점 진해짐
  }

  // 선형 공격 표시 (레이저, 돌진 등)
  static void showLinearDanger({
    required Vector2 start,
    required Vector2 end,
    required double width,
    required double duration,
  }) {
    // 1. 시작점에서 끝점까지 직사각형
    // 2. 화살표로 방향 표시
    // 3. 점선 → 실선으로 변화
  }

  // 보스 특수 공격 경고
  static void showBossWarning(String attackName) {
    // 1. 화면 중앙 상단에 경고 텍스트
    // 2. "! [공격명] !" 형태
    // 3. 빨간색 깜빡임
  }
}
```

### 13.4 데미지 숫자 표시

```dart
class DamagePopup {
  void showDamage(Vector2 position, int damage, DamageType type) {
    String text = damage.toString();
    Color color;
    double scale;

    switch (type) {
      case DamageType.normal:
        color = Colors.white;
        scale = 1.0;
        break;
      case DamageType.critical:
        color = Colors.gold;
        scale = 1.3;
        text = '$damage!';
        break;
      case DamageType.heal:
        color = Colors.green;
        scale = 1.0;
        text = '+$damage';
        break;
    }

    // 애니메이션: 위로 떠오르며 페이드 아웃
    // 지속 시간: 0.8초
  }
}
```

---

## 14. 데이터 파일 참조

### 14.1 데이터 파일 목록

| 파일 경로 | 설명 | 크기 |
|-----------|------|------|
| `assets/data/maps_config.json` | 챕터 1-6 맵 데이터 | 약 2,500줄 |
| `assets/data/monsters_config.json` | 몬스터/보스 데이터 | 약 3,500줄 |
| `assets/data/player_skills.json` | 플레이어 스킬 데이터 | 약 1,000줄 |
| `assets/data/items_config.json` | 아이템 전체 데이터 | 약 2,000줄 |
| `assets/data/npc_dialogues.json` | NPC 대화 데이터 | 약 1,500줄 |

### 14.2 데이터 로딩 매니저

```dart
class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  late MonstersConfig monstersConfig;
  late PlayerSkillsConfig skillsConfig;
  late ItemsConfig itemsConfig;
  late MapsConfig mapsConfig;
  late DialoguesConfig dialoguesConfig;

  Future<void> loadAllData() async {
    await Future.wait([
      _loadMonsters(),
      _loadSkills(),
      _loadItems(),
      _loadMaps(),
      _loadDialogues(),
    ]);
  }

  Future<void> _loadMonsters() async {
    final json = await rootBundle.loadString('assets/data/monsters_config.json');
    monstersConfig = MonstersConfig.fromJson(jsonDecode(json));
  }

  // ... 기타 로딩 메서드
}
```

### 14.3 JSON 스키마 검증

프로그래머는 JSON 파일 로딩 시 스키마 검증을 권장함:

```dart
// 예: 몬스터 데이터 검증
void validateMonsterData(Map<String, dynamic> data) {
  assert(data.containsKey('id'), 'Monster must have id');
  assert(data.containsKey('name'), 'Monster must have name');
  assert(data.containsKey('base_stats'), 'Monster must have base_stats');
  assert(data['base_stats'].containsKey('hp'), 'Stats must have hp');
  // ...
}
```

---

## 15. 구현 우선순위

### Phase 1: 코어 시스템 (2-3주)

**Priority: CRITICAL**

1. [ ] 플레이어 이동 및 충돌
2. [ ] 기본 공격 시스템 (3타 콤보)
3. [ ] 대시 및 무적 프레임
4. [ ] 기본 적 AI (접근 → 공격)
5. [ ] 데미지 계산 공식
6. [ ] HP/사망 시스템

### Phase 2: 전투 확장 (2-3주)

**Priority: HIGH**

1. [ ] 스킬 시스템 (4슬롯)
2. [ ] 마나 시스템
3. [ ] 텔레그래프 시스템
4. [ ] 상태 이상 효과
5. [ ] 완벽 회피 메카닉
6. [ ] 심장 게이지 시스템

### Phase 3: 콘텐츠 (3-4주)

**Priority: HIGH**

1. [ ] 챕터 1-3 맵 구현
2. [ ] 챕터 1-3 몬스터 구현
3. [ ] 보스 AI 및 페이즈 시스템
4. [ ] 아이템 드롭 시스템
5. [ ] 인벤토리 UI

### Phase 4: 메타 시스템 (2주)

**Priority: MEDIUM**

1. [ ] 허브 월드 (망각의 방)
2. [ ] NPC 상호작용
3. [ ] 대화 시스템
4. [ ] 상점 시스템
5. [ ] 제작 시스템

### Phase 5: 스토리 & 후반 콘텐츠 (2-3주)

**Priority: MEDIUM**

1. [ ] 챕터 4-6 구현
2. [ ] 심장 획득 이벤트
3. [ ] 궁극기 시스템
4. [ ] 숨겨진 아이템 시스템
5. [ ] 엔딩 분기 시스템

### Phase 6: 폴리시 (1-2주)

**Priority: LOW**

1. [ ] 사운드/음악 통합
2. [ ] 파티클 효과
3. [ ] 화면 흔들림/히트스톱
4. [ ] UI 애니메이션
5. [ ] 밸런스 조정

---

## 16. 테스트 체크리스트

### 16.1 전투 테스트

- [ ] 기본 공격 3타 콤보가 자연스럽게 연결되는가
- [ ] 대시 무적 프레임이 정확히 0.05~0.18초인가
- [ ] 완벽 회피 시 시간 슬로우 및 보상이 정상 작동하는가
- [ ] 모든 적 공격에 텔레그래프가 있는가
- [ ] 보스 페이즈 전환이 자연스러운가

### 16.2 시스템 테스트

- [ ] 심장 획득 시 해당 궁극기가 해금되는가
- [ ] 심장 게이지가 올바르게 충전되는가
- [ ] 아이템 장착 시 스탯이 정확히 반영되는가
- [ ] 소비 아이템 사용 효과가 정상 적용되는가

### 16.3 스토리 테스트

- [ ] 조건부 대화가 올바른 조건에서 표시되는가
- [ ] 숨겨진 아이템(약속의 반지, 기억의 결정)을 찾을 수 있는가
- [ ] 일반 엔딩 조건에서 일반 엔딩이 재생되는가
- [ ] 트루 엔딩 조건에서 트루 엔딩 선택지가 나타나는가

### 16.4 밸런스 테스트

- [ ] 챕터별 난이도 곡선이 적절한가
- [ ] 보스가 너무 쉽거나 어렵지 않은가
- [ ] 스킬 간 밸런스가 맞는가
- [ ] 장비 업그레이드 체감이 있는가

---

## 부록 A: 용어 사전

| 용어 | 설명 |
|------|------|
| **텔레그래프** | 공격 전 예고 동작/표시 |
| **히트박스** | 공격 판정 영역 |
| **허트박스** | 피격 판정 영역 |
| **무적 프레임 (i-frame)** | 데미지를 받지 않는 시간 |
| **페이즈** | 보스의 단계별 행동 패턴 |
| **심장 게이지** | 궁극기 사용을 위한 게이지 |
| **완벽 회피** | 공격 직전 회피 시 보너스 |

---

## 부록 B: 단축키 기본 설정

| 키 | 기능 |
|-----|------|
| WASD / 방향키 | 이동 |
| 마우스 좌클릭 / J | 기본 공격 |
| Space | 대시 |
| Q, W, E, R | 스킬 1, 2, 3, 4 |
| F | 궁극기 |
| Tab | 인벤토리 |
| Esc | 일시정지 |

---

## 문서 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|-----------|
| 1.0 | 2026-02-03 | 최초 작성 |

---

*이 문서는 기획 의도를 프로그래머에게 전달하기 위해 작성되었습니다.*
*구현 과정에서 기술적 제약에 따라 일부 내용이 변경될 수 있습니다.*
*변경 사항은 기획자와 협의 후 결정해 주세요.*
