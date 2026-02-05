# Development Log: NPC/대화 시스템 구현

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

GDD Phase 4 "메타 시스템" 중 NPC 상호작용 및 조건부 대화 시스템 구현.

### 1. 데이터 모델 생성

#### lib/data/model/dialogue.dart
- `DialogueTrigger`: 대화 트리거 (아이템 지급, 플래그 설정 등)
- `DialogueCondition`: 대화 표시 조건 (챕터, 심장, 아이템, 플래그)
- `DialogueChoice`: 대화 선택지
- `DialogueNode`: 대화 노드 (화자, 대사, 선택지, 트리거)
- `DialogueSequence`: 대화 시퀀스 (여러 노드 묶음)
- `Speaker`: 화자 정보
- `Speakers`: 사전 정의된 화자 목록 (릴리아나, 볼칸, 엘리아스, 상인)

#### lib/data/model/npc.dart
- `ConditionalDialogue`: 조건부 대화 매핑
- `NpcType`: NPC 타입 열거형 (story, merchant, blacksmith, healer, quest)
- `NpcData`: NPC 데이터 (이름, 타입, 스프라이트, 기본/조건부 대화)
- `Npcs`: 사전 정의된 NPC 목록 (릴리아나, 볼칸, 상인, 엘리아스)

### 2. 게임 상태 확장

#### lib/providers/game_state_provider.dart
- `currentChapter`: 현재 챕터 (1-6)
- `heartsAcquired`: 획득한 심장 목록 [bool, bool, bool]
- `flags`: 스토리 플래그 맵
- `heartCount` getter: 획득한 심장 개수
- `hasHeart(int)`: 특정 심장 보유 확인
- `getFlag(String)`: 플래그 확인
- `acquireHeart(int)`: 심장 획득 메서드
- `setFlag(String, bool)`: 플래그 설정 메서드

### 3. 대화 관리자

#### lib/game/managers/dialogue_manager.dart
- `DialogueState`: 대화 상태 열거형 (idle, active, choosing, finished)
- `DialogueManager`: 대화 관리 클래스
  - 조건 체크 (`checkCondition`)
  - NPC와 대화 시작 (`startDialogueWithNpc`)
  - 대화 진행 (`advance`)
  - 선택지 선택 (`selectChoice`)
  - 트리거 실행 (`_executeTrigger`)
- `TestDialogues`: 테스트용 대화 데이터
  - 릴리아나 첫 만남 (`liliana_chapter1_intro`)
  - 릴리아나 기본 대화 (`liliana_default`)
  - 상인 기본 대화 (`merchant_default`)

### 4. NPC 컴포넌트

#### lib/game/characters/npc_component.dart
- `NpcComponent`: NPC 게임 컴포넌트
  - 플레이어 범위 감지 (CircleHitbox)
  - 상호작용 프롬프트 표시 ('E' 키 안내)
  - NPC 타입별 색상 구분
  - 상호작용 쿨다운

### 5. 대화 UI 오버레이

#### lib/ui/overlays/dialogue_overlay.dart
- `DialogueOverlay`: 대화 UI 위젯
  - 반투명 배경
  - 다크 판타지 스타일 대화 박스
  - 화자 이름 (골드 색상)
  - 대사 텍스트
  - 선택지 버튼 (번호 + 텍스트)
  - 진행 안내 텍스트
- `DialogueOverlayController`: 대화 상태 관리 위젯

### 6. 플레이어 수정

#### lib/game/characters/player.dart
- `onNpcInteract` 콜백 추가
- E 키 입력 시 NPC 상호작용 호출

## 변경 파일

### 신규
- lib/data/model/dialogue.dart
- lib/data/model/npc.dart
- lib/game/managers/dialogue_manager.dart
- lib/game/characters/npc_component.dart
- lib/ui/overlays/dialogue_overlay.dart

### 수정
- lib/providers/game_state_provider.dart
- lib/game/characters/player.dart

## 조건부 대화 시스템 동작

```
[NPC 상호작용]
       │
       ▼
┌─────────────────────┐
│ 조건부 대화 순회    │
│ (우선순위 높은 순)  │
└────────┬────────────┘
         │
    ┌────▼────┐
    │조건 충족?│
    └────┬────┘
     예  │  아니오
     ▼   └─→ 다음 조건 체크
┌────────────┐
│ 해당 대화  │
│ 시퀀스 시작│
└────────────┘
         │
         ▼ (모두 불충족 시)
┌────────────────┐
│ 기본 대화 시작 │
└────────────────┘
```

## 테스트 결과
- 빌드 성공 (Windows)
- 정적 분석: info 레벨 이슈만 존재 (error 0개)

## 다음 단계
- [ ] ArcanaGame에 DialogueManager 완전 통합
- [ ] NPC를 던전/맵에 배치
- [ ] 심장 게이지/스킬 시스템 완성
- [ ] 챕터 1 컨텐츠 구현

---
*Log by: Claude Agent (Scribe Role)*
