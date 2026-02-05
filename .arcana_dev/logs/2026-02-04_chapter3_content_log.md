# Development Log: 챕터 3 컨텐츠 구현

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

스토리 플랜에 따라 "침묵의 성당 (The Silent Cathedral)" 챕터 3 컨텐츠 구현.

### 1. 대화 시퀀스 (lib/data/dialogues/chapter3_dialogues.dart)

#### NPC 대화
- `voiceless_nun_first`: 말 없는 수녀 첫 만남 (필담 형식)
- `voiceless_nun_default`: 말 없는 수녀 기본 대화
- `apostate_priest_first`: 배교한 사제 첫 만남 (보스 정보 제공)
- `apostate_priest_default`: 배교한 사제 기본 대화

#### 환경 스토리텔링
- `ch3_confessional`: 고해실 발견 - 기억 단편 (주인공의 목소리)
- `ch3_confession_hallucination`: 고백 강요 환청 (Hearts <= 2)

#### 보스 대화
- `ch3_silencia_encounter`: 실렌시아 조우
- `ch3_silencia_phase2`: 페이즈 2 전환 (심판)
- `ch3_silencia_phase3`: 페이즈 3 전환 (침묵) - 무음 연출
- `ch3_silencia_defeat`: 처치 후 대화 + 아이템 획득
- `ch3_memory_recovery`: 기억 회복 컷씬 (첫 번째 기억)
- `ch3_epilogue`: 다음 챕터 암시 (피의 정원)

### 2. 챕터 3 아이템 (lib/data/model/item.dart)

| 아이템 | ID | 설명 |
|--------|-----|------|
| 첫 번째 기억 조각 | `memory_fragment_1` | 스토리 아이템 (고해실) |
| 실렌시아의 눈물 | `silencia_tear` | 보스 드롭 |
| 침묵의 성당의 아르카나 | `arcana_silent_cathedral` | 챕터 클리어 보상 |

### 3. 챕터 3 NPC (lib/data/model/npc.dart)

| NPC | ID | 역할 |
|-----|-----|------|
| 말 없는 수녀 | `voiceless_nun` | 스토리 NPC, 필담 대화 |
| 배교한 사제 | `apostate_priest` | 스토리 NPC, 보스 정보 제공 |

### 4. 마더 실렌시아 보스 (lib/game/enemies/boss_silencia.dart)

#### 기본 정보
- HP: 1000
- 공격력: 30
- 방어력: 12
- 속도: 35

#### 3페이즈 시스템
**Phase 1: 자비의 가면 (HP 100%~70%)**
- 느린 이동 (0.7배)
- 치유 오라 (실제로는 데미지)
- 축복의 손길 (속박)

**Phase 2: 심판의 손 (HP 70%~35%)**
- 보통 이동 (1.0배)
- 빛의 기둥 (범위 공격)
- 심판의 선언 (광역 데미지)

**Phase 3: 침묵의 진실 (HP 35%~0%)**
- 빠른 이동 (1.2배)
- 침묵의 일격 (무음 공격)
- 침묵의 파동 (광역)
- **특수: 모든 사운드 음소거**

#### 비주얼
- 부유하는 성녀 (90x120)
- 금빛 가면 (오른쪽 절반)
- 부러진 6개의 날개
- 페이즈별 색상 변화:
  - 자비: 흰색 로브, 초록 오라
  - 심판: 황금 로브, 황금 오라
  - 침묵: 회색 로브, 회색 오라 + 가면 금

### 5. 트리거 연결 (lib/game/arcana_game.dart)

#### 보스 조우
```dart
case 3: startDialogue('ch3_silencia_encounter');
```

#### 보스 처치
```dart
case 3: startDialogue('ch3_silencia_defeat');
```

#### 대화 체인
```
ch3_silencia_defeat → (1.5초) → ch3_memory_recovery → (2초) → ch3_epilogue
```

#### 환청 시스템
```dart
case 3:
  if (gameState.heartCount <= 2) {
    startDialogue('ch3_confession_hallucination');
  }
```

#### 보스 상태 체크
```dart
void _checkSilenciaState() {
  // 페이즈 2 전환 대화 (심판)
  if (boss.isInJudgmentPhase) startDialogue('ch3_silencia_phase2');
  // 페이즈 3 전환 대화 (침묵)
  if (boss.isInSilencePhase) startDialogue('ch3_silencia_phase3');
}
```

### 6. NPC 배치 (lib/game/managers/dungeon_manager.dart)

```dart
// 챕터 3 시작 방: 말 없는 수녀
if (room.type == RoomType.start && _currentFloor == 3) {
  add(NpcComponent(npcData: Npcs.voicelessNun, position: ...));
}

// 챕터 3 일반 방: 배교한 사제 (한 번만)
if (room.type == RoomType.normal && _currentFloor == 3) {
  add(NpcComponent(npcData: Npcs.apostatePriest, position: ...));
}

// 보스
case 3: add(BossSilencia(position: bossPos));
```

## 변경 파일

### 신규
- lib/data/dialogues/chapter3_dialogues.dart
- lib/game/enemies/boss_silencia.dart

### 수정
- lib/game/arcana_game.dart (챕터 3 대화 등록, 트리거)
- lib/game/managers/dungeon_manager.dart (실렌시아 보스 스폰, NPC 배치)
- lib/data/model/item.dart (챕터 3 아이템 추가)
- lib/data/model/npc.dart (말 없는 수녀, 배교한 사제 추가)

## 스토리 흐름

```
[챕터 3: 침묵의 성당 입구]
     │
     ▼
[예배당: 말 없는 수녀 조우]
     │ - 필담 대화
     │ - "당신도 죄인인가요?"
     │ - 성당 구조 힌트
     │
     ▼
[던전 탐색]
     │
     ├── [배교한 사제 조우]
     │   - 실렌시아 배경 스토리
     │   - "소리가 사라질 때 시작돼"
     │
     ├── [환청] (Hearts <= 2)
     │   ch3_confession_hallucination
     │   "네 죄를 말해라..."
     │
     ▼
[성소: 실렌시아 조우]
     │ - ch3_silencia_encounter
     │   "내가 신이 되었다"
     │
     ▼
[보스전]
     │
     ├── [HP 70%] → ch3_silencia_phase2
     │   "심판을 내리겠다!"
     │
     ├── [HP 35%] → ch3_silencia_phase3
     │   "이것이... 진정한 침묵..."
     │   ★ 모든 소리 음소거
     │
     ▼
[실렌시아 처치]
     │ - ch3_silencia_defeat
     │   "신은 침묵한 게 아니었어..."
     │   - 눈물 + 아르카나 획득
     │
     ▼ (1.5초 후)
[기억 회복]
     │ - ch3_memory_recovery
     │   - 비 오는 밤
     │   - 사랑하는 사람을 죽였다
     │
     ▼ (2초 후)
[에필로그]
     - ch3_epilogue
     - "피의 정원에서 그녀가 기다린다"
     - "세 개의 심장은 세 번의 죄"
```

## 테스트 결과
- 정적 분석: 통과 (info/warning만, 오류 없음)
- Windows 빌드: 성공

## 챕터별 보스 매핑 (완료)
| 층 | 챕터 | 보스 | 테마 |
|----|------|------|------|
| 1 | 잊혀진 숲 | 이그드라 | 망각/슬픔 |
| 2 | 무너진 성채 | 발두르 | 집착/광기 |
| 3 | 침묵의 성당 | 실렌시아 | 신앙/침묵 |
| 4+ | (미구현) | 슬라임 | 임시 |

## 다음 단계
- [ ] 챕터 4 컨텐츠 구현 (피의 정원)
- [ ] 페이즈 3 실제 오디오 음소거 연동
- [ ] 고해실 환경 트리거 연결

---
*Log by: Claude Agent (Scribe Role)*
