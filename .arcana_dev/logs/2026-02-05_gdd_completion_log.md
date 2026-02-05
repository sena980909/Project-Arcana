# Development Log: GDD 컨텐츠 완성 작업

**날짜:** 2026-02-05
**상태:** 완료

## 작업 내용

### 1. 렌더링 우선순위 문제 수정
- **문제**: 방 전환 후 캐릭터가 바닥 아래로 가라앉는 현상
- **원인**: Flame 엔진에서 컴포넌트 렌더링 순서(priority) 미설정
- **해결**: 각 컴포넌트에 명시적 priority 설정
  - `RoomComponent`: priority = 0 (바닥)
  - `DroppedItem`: priority = 70
  - `NpcComponent`: priority = 80
  - `BaseEnemy` / `DummyEnemy`: priority = 90
  - `ArcanaPlayer`: priority = 100

### 2. 보스 드롭 테이블 수정
- **boss_oblivion.dart**: 잘못된 아이템 드롭 수정
  - 기존: `arcanaAbyssOfMemory` (챕터 5 아이템)
  - 수정: `oblivionTear`, `arcanaThroneOfOblivion` (챕터 6 아이템)

### 3. 트루 엔딩 플래그 시스템 구현
트루 엔딩 조건 3가지 플래그를 대화 시스템에 통합:

| 플래그 | 설정 위치 | 설명 |
|--------|----------|------|
| `has_heart_of_past` | ch4_epilogue | 과거의 심장 획득 |
| `has_heart_of_present` | ch5_shadow_integration | 현재의 심장 획득 |
| `has_all_memory_crystals` | ch5_epilogue | 모든 기억 결정 완성 |

### 4. 대화 노드 확장
- **chapter4_dialogues.dart**: ep13 노드 추가 (과거의 심장 플래그)
- **chapter5_dialogues.dart**:
  - int_14 노드 추가 (현재의 심장 플래그)
  - epi_5, epi_6 노드 추가 (기억 결정 플래그)

## 변경 파일
- `lib/game/characters/player.dart`
- `lib/game/enemies/base_enemy.dart`
- `lib/game/enemies/dummy_enemy.dart`
- `lib/game/enemies/boss_oblivion.dart`
- `lib/game/characters/npc_component.dart`
- `lib/game/decorations/dropped_item.dart`
- `lib/game/maps/room_component.dart`
- `lib/data/dialogues/chapter4_dialogues.dart`
- `lib/data/dialogues/chapter5_dialogues.dart`
- `.arcana_dev/plans/plan_010_remaining_content.md`

## 검증 상태
- [x] 빌드 성공
- [ ] 전체 플레이 테스트 (사용자 테스트 필요)

## 현재 게임 완성도

### 완료된 시스템
- 6개 챕터 대화 시퀀스 (전체)
- 6개 보스 + 드롭 테이블
- 트루/노멀 엔딩 분기 시스템
- 하트 시스템 + 스킬 시스템
- 저장/로드 시스템
- 인벤토리 시스템
- NPC 상호작용 시스템
- 챕터별 BGM 시스템
- 스토리 아이템 대화 트리거

### 다음 단계
- 전체 게임 플로우 테스트 (Ch1 → Ch6)
- 엔딩 분기 테스트

## 이슈/해결
- **이슈**: 트루 엔딩 플래그가 설정되지 않음
- **해결**: 챕터 4, 5 대화에 DialogueTrigger 추가

---

# 추가 작업 (2026-02-05 오후)

## 5. 챕터별 BGM 시스템 구현
- **audio_manager.dart**: 챕터별 BGM 트랙 열거형 추가
  - `chapter1Dungeon` ~ `chapter6Dungeon`
  - `chapter1Boss` ~ `chapter6Boss`
  - `chapter3BossSilence` (무음)
  - `chapter6BossFinal` (최종 페이즈)
- 헬퍼 메서드 추가:
  - `getDungeonTrackForChapter(int)`
  - `getBossTrackForChapter(int)`
  - `playChapterDungeonBgm(int)`
  - `playChapterBossBgm(int)`
  - `playChapter3SilencePhase()`
  - `playFinalBossBgm()`

## 6. arcana_game.dart BGM 호출 수정
- 게임 시작 시 `playChapterDungeonBgm(initialFloor)`
- 재시작 시 `playChapterDungeonBgm(currentFloor)`
- 보스방 진입 시 `playChapterBossBgm(currentFloor)`
- 챕터 3 Phase 3 진입 시 `playChapter3SilencePhase()`
- 챕터 6 Phase 4 진입 시 `playFinalBossBgm()`

## 7. 스토리 아이템 대화 트리거 추가
- **arcana_game.dart**: `_triggerStoryItemDialogue()` 메서드 추가
- 각 챕터 대화 파일에 스토리 아이템 대화 시퀀스 추가:
  - ch1_item_pendant (부서진 나뭇잎 펜던트)
  - ch2_item_crown (깨진 왕관 조각)
  - ch3_item_memory (첫 번째 기억 조각)
  - ch4_item_ring (리리아나의 반지)
  - ch4_hidden_ring (약속의 반지 - 트루엔딩)
  - ch5_hidden_crystal (기억의 결정 - 트루엔딩)
  - ch5_item_shadow (그림자의 파편)
  - ch6_item_tear (망각의 눈물)

## 변경 파일 (추가)
- `lib/game/managers/audio_manager.dart`
- `lib/game/arcana_game.dart`
- `lib/data/dialogues/chapter1_dialogues.dart`
- `lib/data/dialogues/chapter2_dialogues.dart`
- `lib/data/dialogues/chapter3_dialogues.dart`
- `lib/data/dialogues/chapter4_dialogues.dart`
- `lib/data/dialogues/chapter5_dialogues.dart`
- `lib/data/dialogues/chapter6_dialogues.dart`

## 검증 상태
- [x] 빌드 성공
- [ ] 전체 플레이 테스트 (사용자 테스트 필요)

---

# 추가 작업 (2026-02-05 오후 2)

## 8. 숨겨진 아이템 배치 (트루 엔딩 필수)
- **dungeon_manager.dart**: `_spawnHiddenItemsForRoom()` 메서드 추가
  - **약속의 반지** (promise_ring): Ch4 일반방 오른쪽 상단 구석
  - **첫 번째 기억의 결정** (first_memory_crystal): Ch5 시작방 (5,5) 좌표

## 9. 챕터별 스토리 아이템 보물방 스폰
- **dungeon_manager.dart**: `_spawnTreasure()` 메서드 확장
  - Ch1: 부서진 나뭇잎 펜던트 + 체력 포션
  - Ch2: 깨진 왕관 조각 + 가죽 갑옷
  - Ch3: 첫 번째 기억 조각 + 철 검
  - Ch4: 리리아나의 반지 + 대형 체력 포션
  - Ch5: 그림자의 파편 + 화염 검
  - Ch6: 망각의 눈물은 보스 드롭으로만

## 변경 파일 (추가)
- `lib/game/managers/dungeon_manager.dart`

## GDD 기준 완료율
- **완료**: 약 95%
- **남은 항목**:
  - 환경 스토리텔링 (Low Priority)
  - 기억 회복 회상 장면 (Medium Priority)
  - 전체 플로우 테스트

---

# 추가 작업 (2026-02-05 오후 3)

## 10. 환경 스토리텔링 시스템 구현
- **story_object.dart**: 환경 오브젝트 컴포넌트 (이전에 생성됨)
  - StoryObjectType: mural, inscription, altar, statue, memorial
  - 플레이어 근접 시 자동 대화 시작
  - 빛나는 시각 효과

- **environment_dialogues.dart**: 환경 대화 시퀀스 (이전에 생성됨)
  - 챕터 1-6 각각 2개씩 환경 대화 (벽화/비문)
  - 총 12개 환경 스토리텔링 대화

- **arcana_game.dart**: 환경 대화 등록
  - `EnvironmentDialogues.all` 등록 추가

- **dungeon_manager.dart**: StoryObject 스폰 로직
  - `_spawnStoryObjectsForRoom()` 메서드 추가
  - 각 챕터 첫 번째 일반방에 환경 오브젝트 배치
  - 챕터별 2개씩 (mural/statue + inscription)

## 11. 기억 회복 회상 장면 확인
- **이미 구현됨**:
  - `ch3_memory_recovery`: 챕터 3 보스 처치 후 첫 번째 기억 회복
  - `ch5_memory_corridor`: 챕터 5 기억의 복도 회상
  - `ch5_shadow_integration`: 그림자 통합 회상
- **대화 플로우 연결 완료**:
  - ch3_silencia_defeat → ch3_memory_recovery → ch3_epilogue
  - ch5 시퀀스 전체 연결

## 변경 파일 (추가)
- `lib/game/arcana_game.dart` (환경 대화 등록)
- `lib/game/managers/dungeon_manager.dart` (StoryObject 스폰)

## 검증 상태
- [x] 빌드 성공
- [ ] 전체 플레이 테스트 (사용자 테스트 필요)

## GDD 기준 완료율 (갱신)
- **완료**: 약 98%
- **남은 항목**:
  - 전체 플로우 테스트 (Ch1 → Ch6)
  - 엔딩 분기 테스트 (노멀/트루)
