# Development Log: 스토리 트리거 시스템 구현

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

환청 시스템, NPC 상호작용, 보스 대화 트리거 구현.

### 1. 환청 시스템 (Hallucination System)

#### 발동 조건
- `Hearts < 3` (아직 심장을 모두 모으지 못한 상태)
- `heard_hallucination` 플래그가 없을 때 (한 번만 발생)
- 대화 중이 아닐 때

#### 발동 타이밍
- 최소 간격: 45초
- 최대 간격: 120초
- 랜덤 타이머로 발동

#### 대화 시퀀스
- `ch1_hallucination`: 의문의 목소리가 들림
- 완료 시 `heard_hallucination` 플래그 설정

### 2. NPC 상호작용 시스템

#### 상호작용 방법
- E키를 누르면 `onNpcInteract` 콜백 호출
- 64픽셀 내 가장 가까운 NPC 탐색
- NPC의 조건부 대화 시스템 활용

#### 대화 선택 로직
1. NPC의 `conditionalDialogues` 우선순위 순 체크
2. 조건 만족하는 첫 대화 시작
3. 없으면 `defaultDialogueId` 사용

### 3. 보스 대화 트리거

#### 보스 조우 (Boss Encounter)
- **트리거**: 보스방 진입 시
- **조건**: `yggdra_encounter_complete` 플래그 없음
- **딜레이**: 500ms 후 대화 시작
- **대화**: `ch1_yggdra_encounter`

#### 페이즈 2 전환
- **트리거**: HP 50% 이하 (분노 페이즈 진입)
- **조건**: 한 번만 실행
- **대화**: `ch1_yggdra_phase2`

#### 보스 처치
- **트리거**: 보스 사망 시 (`_onBossDefeated`)
- **딜레이**: 1000ms 후 대화 시작
- **대화**: `ch1_yggdra_defeat`
- **효과**: 승리 사운드 + 승리 BGM

## 변경 파일

### 수정
- lib/game/arcana_game.dart
  - 환청 시스템 추가 (`_updateHallucinationSystem`)
  - 보스 상태 체크 추가 (`_checkBossState`)
  - NPC 상호작용 처리 추가 (`_handleNpcInteract`)
  - 보스방 진입 시 대화 트리거
  - 보스 처치 시 대화 트리거

- lib/game/enemies/boss_yggdra.dart
  - `isInRagePhase` getter 추가

## 스토리 트리거 흐름

```
[게임 시작]
     │
     ├── [프롤로그] ─────────────────────────────────┐
     │                                               │
     ▼                                               │
[숲 탐험]                                            │
     │                                               │
     ├── [환청 발생] (Hearts < 3, 45~120초 랜덤)     │
     │        │                                      │
     │        ▼                                      │
     │   ch1_hallucination                           │
     │                                               │
     ├── [NPC 발견] ─► E키 ─► NPC 대화              │
     │                                               │
     ▼                                               │
[보스방 진입]                                        │
     │                                               │
     ├── ch1_yggdra_encounter (조우 대화)            │
     │                                               │
     ▼                                               │
[전투 시작]                                          │
     │                                               │
     ├── HP 50% 이하 ─► ch1_yggdra_phase2           │
     │                                               │
     ▼                                               │
[보스 처치]                                          │
     │                                               │
     └── ch1_yggdra_defeat (처치 대화 + 아이템)      │
              │                                      │
              ▼                                      │
         [챕터 1 완료] ◄────────────────────────────┘
```

## 테스트 결과
- 빌드 성공 (Windows Release)
- 정적 분석 통과

## 완료된 단계
- [x] 환청 시스템 구현
- [x] NPC 상호작용 → 대화 시작 연결
- [x] 보스 조우/처치 대화 트리거 연결

## 다음 단계
- [ ] 에필로그 자동 연결 (보스 처치 대화 → 에필로그)
- [ ] 챕터 2 컨텐츠 구현
- [ ] 테스트용 NPC 배치 (재의 상인)

---
*Log by: Claude Agent (Scribe Role)*
