# Development Log: 챕터 2 컨텐츠 구현

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

스토리 플랜에 따라 "무너진 성채 (The Crumbling Citadel)" 챕터 2 컨텐츠 구현.

### 1. 대화 시퀀스 (lib/data/dialogues/chapter2_dialogues.dart)

#### NPC 대화
- `blind_knight_first`: 눈먼 기사 첫 만남
- `blind_knight_default`: 눈먼 기사 기본 대화
- `ash_merchant_ch2`: 재의 상인 챕터 2 재등장 (펜던트 복선 회수)

#### 환경 스토리텔링
- `ch2_throne_discovery`: 왕좌의 방 발견, 왕관 조각 획득
- `ch2_betrayal_hallucination`: 배신의 환각 (Hearts <= 2일 때)
- `ch2_queen_ghost`: 왕비의 환영 (Hearts == 1일 때만)

#### 보스 대화
- `ch2_baldur_encounter`: 발두르 조우
- `ch2_baldur_phase2`: 페이즈 2 전환 (광기)
- `ch2_baldur_phase3`: 페이즈 3 전환 (절망)
- `ch2_baldur_defeat`: 처치 후 대화 + 아이템 획득
- `ch2_epilogue`: 다음 챕터 암시 (침묵의 성당)

### 2. 챕터 2 아이템 (lib/data/model/item.dart)

| 아이템 | ID | 설명 |
|--------|-----|------|
| 깨진 왕관 조각 | `broken_crown_shard` | 스토리 아이템 (왕좌의 방) |
| 발두르의 눈물 | `baldur_tear` | 보스 드롭 |
| 무너진 성채의 아르카나 | `arcana_crumbling_citadel` | 챕터 클리어 보상 |

### 3. 챕터 2 NPC (lib/data/model/npc.dart)

| NPC | ID | 역할 |
|-----|-----|------|
| 눈먼 기사 | `blind_knight` | 스토리 NPC, 보스 정보 제공 |
| 재의 상인 (업데이트) | `ash_merchant` | 챕터 2 조건부 대화 추가 |

### 4. 발두르 보스 (lib/game/enemies/boss_baldur.dart)

#### 기본 정보
- HP: 800
- 공격력: 25
- 방어력: 10
- 속도: 40

#### 3페이즈 시스템
**Phase 1: 왕의 위엄 (HP 100%~60%)**
- 느린 이동 (0.8배)
- 2연속 슬래시 콤보
- 왕의 칙령 (범위 공격)

**Phase 2: 광기의 폭군 (HP 60%~30%)**
- 빠른 이동 (1.3배)
- 4연속 슬래시 콤보
- 분신 소환 이펙트

**Phase 3: 텅 빈 껍데기 (HP 30%~0%)**
- 불안정한 이동
- 울부짖음 (전체 화면 공격)
- 자해 폭발 (자해 + 광역 피해)

#### 비주얼
- 갑옷 입은 왕 (80x100)
- 페이즈별 색상 변화:
  - 위엄: 회색 갑옷, 금색 왕관
  - 광기: 핏빛 갑옷, 붉은 오라
  - 절망: 어두운 회색, 보라 오라
- 검은 눈물이 흐르는 효과

### 5. 에필로그 자동 연결

- 보스 처치 대화(`ch1_yggdra_defeat`) → 에필로그(`ch1_epilogue`) 자동 연결
- `lastCompletedSequenceId` 추적 시스템 추가

## 변경 파일

### 신규
- lib/data/dialogues/chapter2_dialogues.dart
- lib/game/enemies/boss_baldur.dart

### 수정
- lib/game/arcana_game.dart (챕터 2 대화 등록, 에필로그 체인)
- lib/game/managers/dungeon_manager.dart (발두르 보스 스폰)
- lib/game/managers/dialogue_manager.dart (lastCompletedSequenceId 추가)
- lib/data/model/item.dart (챕터 2 아이템 추가)
- lib/data/model/npc.dart (눈먼 기사, 재의 상인 업데이트)

## 스토리 흐름

```
[챕터 1 완료]
     │
     ▼
[챕터 2: 무너진 성채 입구]
     │ - 재의 상인 재등장 (펜던트 복선)
     │
     ▼
[외성: 눈먼 기사 조우]
     │ - 발두르/과거 정보 획득
     │
     ▼
[내성: 왕좌의 방]
     │ - 깨진 왕관 조각 획득
     │ - 벽화 스토리텔링
     │
     ├── [환각] (Hearts <= 2)
     │   "네 친구도 널 버릴 거야..."
     │
     ├── [왕비의 환영] (Hearts == 1)
     │   "당신도 누군가를 사랑했나요?"
     │
     ▼
[탑 정상: 발두르 조우]
     │ - "사랑했다. 그게 전부야."
     │
     ▼
[보스전]
     │ Phase 1: 위엄 → Phase 2: 광기 → Phase 3: 절망
     │
     ▼
[발두르 처치]
     │ - "넌 나와 같아..."
     │ - 눈물 + 아르카나 획득
     │
     ▼
[에필로그]
     - "침묵의 성당에서..."
```

## 테스트 결과
- 빌드 성공 (Windows Release)
- 정적 분석 통과

## 챕터별 보스 매핑
| 층 | 챕터 | 보스 | 테마 |
|----|------|------|------|
| 1 | 잊혀진 숲 | 이그드라 | 망각/슬픔 |
| 2 | 무너진 성채 | 발두르 | 집착/광기 |
| 3+ | (미구현) | 슬라임 | 임시 |

## 다음 단계
- [ ] 챕터 2 환청/환영 트리거 연결
- [ ] 챕터 2 NPC 배치 (눈먼 기사)
- [ ] 챕터 3 컨텐츠 구현

---
*Log by: Claude Agent (Scribe Role)*
