# Development Log: 챕터 2 트리거 연결

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

챕터 2 환청/환영 시스템과 보스 대화 트리거를 ArcanaGame에 연결.

### 1. 챕터별 환청 시스템 (lib/game/arcana_game.dart)

#### 기존 환청 시스템 개선
- `_updateHallucinationSystem`: 챕터 공통 타이머 관리
- `_triggerChapterHallucination`: 챕터별 환청 분기

#### 챕터 2 환청 조건
| 조건 | 트리거 대화 | 플래그 |
|------|------------|--------|
| Hearts == 1 | `ch2_queen_ghost` | `seen_queen_ghost` |
| Hearts <= 2 | `ch2_betrayal_hallucination` | `heard_betrayal_hallucination` |

### 2. 보스 상태 체크 분리 (lib/game/arcana_game.dart)

#### 리팩토링 구조
```dart
void _checkBossState() {
  switch (_dungeonManager.currentFloor) {
    case 1: _checkYggdraState();
    case 2: _checkBaldurState();
  }
}
```

#### 발두르 페이즈 트리거
| 페이즈 | HP 범위 | 트리거 대화 |
|--------|---------|-------------|
| 광기 (Phase 2) | 60%~30% | `ch2_baldur_phase2` |
| 절망 (Phase 3) | 30%~0% | `ch2_baldur_phase3` |

### 3. 보스 조우/처치 대화 분기

#### 보스 조우 (보스방 진입 시)
```dart
switch (_dungeonManager.currentFloor) {
  case 1: startDialogue('ch1_yggdra_encounter');
  case 2: startDialogue('ch2_baldur_encounter');
}
```

#### 보스 처치 (보스 사망 시)
```dart
switch (_dungeonManager.currentFloor) {
  case 1: startDialogue('ch1_yggdra_defeat');
  case 2: startDialogue('ch2_baldur_defeat');
}
```

#### 대화 체인 (에필로그 자동 연결)
- `ch1_yggdra_defeat` → `ch1_epilogue`
- `ch2_baldur_defeat` → `ch2_epilogue`

### 4. 눈먼 기사 NPC 배치 (lib/game/managers/dungeon_manager.dart)

#### 챕터 2 시작 방 NPC 배치
```dart
if (room.type == RoomType.start && _currentFloor == 2) {
  // 재의 상인 (왼쪽)
  add(NpcComponent(npcData: Npcs.ashMerchant, position: center + Vector2(-60, 0)));
  // 눈먼 기사 (오른쪽)
  add(NpcComponent(npcData: Npcs.blindKnight, position: center + Vector2(60, 0)));
}
```

## 변경 파일

### 수정
- lib/game/arcana_game.dart
  - import `boss_baldur.dart` 추가
  - `_bossPhase3DialogueShown` 플래그 추가
  - `_handleDialogueChain`: 챕터 2 에필로그 체인 추가
  - `_onBossDefeated`: 층별 보스 처치 대화 분기
  - `_handleDoorEnter`: 층별 보스 조우 대화 분기
  - `_updateHallucinationSystem`: 리팩토링
  - `_triggerChapterHallucination`: 신규 (챕터별 환청)
  - `_checkBossState`: 층별 분기로 리팩토링
  - `_checkYggdraState`: 분리 (챕터 1 보스)
  - `_checkBaldurState`: 신규 (챕터 2 보스)

- lib/game/managers/dungeon_manager.dart
  - `_spawnNpcsForRoom`: 챕터 2 시작 방 NPC 추가

## 스토리 흐름 (완성)

```
[챕터 2: 무너진 성채 시작]
     │
     ▼
[시작 방: 재의 상인 + 눈먼 기사]
     │ - ash_merchant_ch2 (펜던트 복선)
     │ - blind_knight_first (발두르 정보)
     │
     ▼
[던전 탐색 중]
     │
     ├── [환청] (Hearts <= 2)
     │   ch2_betrayal_hallucination
     │   "네 친구도 널 버릴 거야..."
     │
     ├── [환영] (Hearts == 1)
     │   ch2_queen_ghost
     │   "당신도 누군가를 사랑했나요?"
     │
     ▼
[보스방 진입]
     │ - ch2_baldur_encounter
     │   "사랑했다. 그게 전부야."
     │
     ▼
[보스전]
     │
     ├── [HP 60%] → ch2_baldur_phase2
     │   "그녀가... 죽었어..."
     │
     ├── [HP 30%] → ch2_baldur_phase3
     │   "끝나게 해줘..."
     │
     ▼
[발두르 처치]
     │ - ch2_baldur_defeat
     │   "넌 나와 같아..."
     │
     ▼ (1.5초 후)
[에필로그]
     - ch2_epilogue
     - "침묵의 성당에서..."
```

## 테스트 결과
- 정적 분석: 통과 (info/warning만, 오류 없음)
- Windows 빌드: 성공

## 다음 단계
- [ ] 챕터 3 컨텐츠 구현 (침묵의 성당 - The Silent Cathedral)
- [ ] 챕터 3 보스 설계 및 구현
- [ ] 왕좌의 방 환경 스토리텔링 트리거 (ch2_throne_discovery)

---
*Log by: Claude Agent (Scribe Role)*
