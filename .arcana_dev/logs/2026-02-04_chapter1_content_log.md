# Development Log: 챕터 1 컨텐츠 구현

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

스토리 플랜에 따라 "잊혀진 숲 (The Forgotten Grove)" 챕터 1 컨텐츠 구현.

### 1. 대화 시퀀스 (lib/data/dialogues/chapter1_dialogues.dart)

#### 프롤로그
- `ch1_prologue`: 깨어남, 기억 상실, 세 개의 심장 암시

#### 재의 상인 대화
- `ash_merchant_first`: 첫 만남 (숲 설명, 상점 제안, 힌트)
- `ash_merchant_default`: 기본 대화

#### 환경 스토리텔링
- `ch1_altar_discovery`: 제단 발견, 나뭇잎 펜던트 획득
- `ch1_hallucination`: 환청 (Hearts < 3일 때)

#### 보스 대화
- `ch1_yggdra_encounter`: 이그드라 조우 (슬픔의 독백)
- `ch1_yggdra_phase2`: 페이즈 2 전환 (분노 폭발)
- `ch1_yggdra_defeat`: 처치 후 해방 + 아이템 획득
- `ch1_epilogue`: 다음 챕터 암시

### 2. 챕터 1 아이템 (lib/data/model/item.dart)

| 아이템 | ID | 설명 |
|--------|-----|------|
| 부서진 나뭇잎 펜던트 | `broken_leaf_pendant` | 스토리 아이템 (제단 발견) |
| 이그드라의 눈물 | `yggdra_tear` | 보스 드롭 |
| 잊혀진 숲의 아르카나 | `arcana_forgotten_grove` | 챕터 클리어 보상 |
| 약속의 반지 | `promise_ring` | 트루 엔딩 필수 (Ch4) |
| 첫 번째 기억의 결정 | `first_memory_crystal` | 트루 엔딩 필수 (Ch5) |

### 3. 이그드라 보스 (lib/game/enemies/boss_yggdra.dart)

#### 기본 정보
- HP: 600
- 공격력: 20
- 방어력: 8
- 속도: 35

#### 페이즈 시스템
**Phase 1: 슬픔 (HP 100%~50%)**
- 느린 이동
- 눈물 탄막 공격 (5발 원형)
- 뿌리 근접 공격

**Phase 2: 분노 (HP 50%~0%)**
- 빠른 이동 (1.3배)
- 눈물 탄막 강화 (8발)
- 가시 소환 (플레이어 주변 4개)
- 돌진 공격

#### 비주얼
- 거대한 나무 형상 (100x120)
- 슬픔 페이즈: 짙은 녹색 + 파란 눈물
- 분노 페이즈: 어두운 갈색 + 붉은 오라

### 4. 재의 상인 NPC (lib/data/model/npc.dart)

- ID: `ash_merchant`
- 타입: merchant
- 조건부 대화: 첫 만남 우선

## 변경 파일

### 신규
- lib/data/dialogues/chapter1_dialogues.dart
- lib/game/enemies/boss_yggdra.dart

### 수정
- lib/data/model/item.dart (챕터 1 + 트루엔딩 아이템 추가)
- lib/data/model/npc.dart (재의 상인 추가)

## 스토리 플로우

```
[프롤로그] → [숲 입구: 재의 상인] → [숲 탐험]
                                        │
                    ┌───────────────────┴───────────────────┐
                    ▼                                       ▼
            [제단 발견]                           [환청 (Hearts<3)]
            펜던트 획득                                │
                    │                                  │
                    └───────────────────┬──────────────┘
                                        ▼
                              [이그드라 조우]
                              Phase 1: 슬픔
                                        │
                                        ▼ (HP 50%)
                              Phase 2: 분노
                                        │
                                        ▼ (HP 0%)
                              [이그드라 처치]
                              눈물 + 아르카나 획득
                                        │
                                        ▼
                              [에필로그]
                              "성채에서... 그가 기다린다..."
```

## 테스트 결과
- 빌드 성공 (Windows)
- 정적 분석 통과

## 다음 단계
- [ ] 챕터 1 던전에 이그드라 배치 (DungeonManager 수정)
- [ ] 프롤로그 대화 트리거 연결
- [ ] 환청 시스템 구현
- [ ] 챕터 2 컨텐츠 구현

---
*Log by: Claude Agent (Scribe Role)*
