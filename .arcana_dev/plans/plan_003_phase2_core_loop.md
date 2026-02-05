# 📋 Plan: Phase 2 - Core Loop

## 1. 개요
* **목표:** 게임의 핵심 루프 구현 (적 AI, 던전 생성, 인벤토리, 게임오버)
* **관련 PRD 섹션:** 7. 상세 개발 마일스톤 - Phase 2: Core Loop (4~6주차)

## 2. 작업 목록

### 2.1 적 AI (State Machine)
- [ ] EnemyState 열거형 정의 (Idle, Chase, Attack, Dead)
- [ ] 기본 Enemy 클래스 추상화
- [ ] 상태별 행동 구현:
  - Idle: 제자리 또는 랜덤 배회
  - Chase: 플레이어 감지 시 추적
  - Attack: 근접 시 공격
- [ ] 시야 범위 및 공격 범위 설정
- [ ] 슬라임 적 구현 (Chapter 1 기본 몬스터)

### 2.2 던전 생성 알고리즘
- [ ] Room 클래스 정의 (크기, 문 위치, 타일 데이터)
- [ ] RoomPrefab 정의 (사전 제작된 방 템플릿)
- [ ] DungeonGenerator 클래스:
  - BSP(Binary Space Partitioning) 또는 랜덤 워크 알고리즘
  - 방 연결 (복도 생성)
  - 시작 방, 보스 방 배치
- [ ] 적/아이템 스폰 포인트 설정

### 2.3 인벤토리 시스템
- [ ] Item 데이터 모델 정의
- [ ] ItemType 열거형 (Weapon, Armor, Consumable, Key)
- [ ] InventoryProvider (Riverpod) 구현
- [ ] 아이템 획득 로직
- [ ] 인벤토리 UI 화면
- [ ] 장비 장착/해제 기능

### 2.4 게임 오버 및 재시작
- [ ] GameState 관리 (Playing, Paused, GameOver, Victory)
- [ ] GameStateProvider (Riverpod) 구현
- [ ] 게임 오버 화면 UI
- [ ] 재시작 기능 (상태 초기화)
- [ ] 메인 메뉴로 돌아가기

### 2.5 아이템 드롭 시스템
- [ ] 적 사망 시 아이템 드롭
- [ ] 드롭 테이블 정의
- [ ] 바닥 아이템 컴포넌트
- [ ] 아이템 획득 (플레이어 충돌)

## 3. 설계 상세

### 새로 생성할 파일:
```
lib/
├── data/
│   └── model/
│       ├── item.dart              # 아이템 데이터 모델
│       ├── enemy_data.dart        # 적 데이터 모델
│       └── room.dart              # 방 데이터 모델
├── game/
│   ├── behaviors/
│   │   └── enemy_ai.dart          # 적 AI 상태 머신
│   ├── enemies/
│   │   ├── base_enemy.dart        # 적 기본 클래스
│   │   └── slime_enemy.dart       # 슬라임 적
│   ├── decorations/
│   │   └── dropped_item.dart      # 바닥 아이템
│   └── maps/
│       ├── room_prefabs.dart      # 방 프리팹 정의
│       └── dungeon_generator.dart # 던전 생성기
├── providers/
│   ├── game_state_provider.dart   # 게임 상태 관리
│   └── inventory_provider.dart    # 인벤토리 관리
└── ui/
    ├── components/
    │   └── item_slot.dart         # 아이템 슬롯 위젯
    └── screens/
        ├── inventory_screen.dart  # 인벤토리 화면
        └── game_over_screen.dart  # 게임 오버 화면
```

### 수정할 파일:
* `lib/game/arcana_game.dart` - 던전 생성기 연동, 게임 상태 관리
* `lib/game/characters/player.dart` - 아이템 획득, 사망 처리
* `lib/game/interface/game_hud.dart` - 인벤토리 버튼 추가
* `lib/ui/screens/game_screen.dart` - 게임 오버 오버레이

## 4. 상태 머신 설계 (적 AI)

```
[Idle] ---(플레이어 감지)---> [Chase]
  ^                            |
  |                            v
  +---(플레이어 벗어남)------- [Chase]
                               |
                     (공격 범위 진입)
                               |
                               v
                           [Attack]
                               |
                     (공격 후 쿨다운)
                               |
                               v
                           [Chase]

모든 상태 ---(체력 0)---> [Dead]
```

## 5. 던전 생성 알고리즘

### BSP (Binary Space Partitioning) 방식:
1. 전체 맵 영역을 재귀적으로 분할
2. 각 리프 노드에 방 생성
3. 인접한 방들을 복도로 연결
4. 시작 방(플레이어 스폰)과 보스 방 지정

### 방 타입:
- StartRoom: 플레이어 시작 위치
- NormalRoom: 일반 방 (적 + 아이템)
- TreasureRoom: 보물 방 (아이템만)
- BossRoom: 보스 방

## 6. 예상 리스크
* 던전 생성 알고리즘 복잡도 (디버깅 어려움)
* Riverpod와 Flame 연동 (상태 동기화)
* 적 AI 성능 (다수의 적 동시 처리)

## 7. 완료 조건
- [ ] 적이 플레이어를 감지하고 추적함
- [ ] 적이 공격 범위에서 공격함
- [ ] 던전이 매번 다르게 생성됨
- [ ] 아이템을 획득하면 인벤토리에 추가됨
- [ ] 플레이어 사망 시 게임 오버 화면 표시
- [ ] 재시작 버튼으로 게임 재시작 가능
