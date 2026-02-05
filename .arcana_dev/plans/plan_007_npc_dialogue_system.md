# Plan: NPC/대화 시스템 구현

## 목표
GDD Phase 4에 따라 NPC 상호작용 및 조건부 대화 시스템 구현

## 설계

### 1. 데이터 모델 (lib/data/model/)

#### dialogue.dart
```dart
class DialogueNode {
  String id;
  String speakerId;
  String text;
  String? portrait;
  List<DialogueChoice>? choices;
  String? nextId;
  DialogueTrigger? trigger;
}

class DialogueChoice {
  String text;
  String? nextId;
  DialogueTrigger? trigger;
  Map<String, dynamic>? condition;
}

class DialogueTrigger {
  String type;  // 'give_item', 'set_flag', 'unlock_shop', etc.
  Map<String, dynamic> params;
}
```

#### npc.dart
```dart
class NpcData {
  String id;
  String name;
  String spriteSheet;
  String defaultDialogueId;
  List<ConditionalDialogue> conditionalDialogues;
}

class ConditionalDialogue {
  Map<String, dynamic> conditions;
  String dialogueId;
}
```

### 2. 게임 컴포넌트 (lib/game/)

#### npc_component.dart
- SpriteAnimationComponent 상속
- 플레이어 접근 시 상호작용 프롬프트 표시
- 상호작용 시 DialogueManager에 대화 시작 요청

#### dialogue_manager.dart
- 조건 체크 로직
- 대화 진행 상태 관리
- 트리거 실행

### 3. UI 오버레이 (lib/ui/overlays/)

#### dialogue_overlay.dart
- 반투명 배경
- 대화 박스 (화자 이름, 대사)
- 선택지 버튼
- 터치/클릭으로 진행

## 클래스 구조

```
lib/
├── data/
│   └── model/
│       ├── dialogue.dart      # 대화 데이터 모델
│       └── npc.dart           # NPC 데이터 모델
├── game/
│   ├── characters/
│   │   └── npc_component.dart # NPC 게임 컴포넌트
│   └── managers/
│       └── dialogue_manager.dart # 대화 관리자
└── ui/
    └── overlays/
        └── dialogue_overlay.dart # 대화 UI
```

## 사이드 이펙트
- ArcanaGame에 DialogueManager 추가 필요
- GameScreen에 DialogueOverlay 추가 필요
- GameState에 flags 맵 추가 필요

## 체크리스트
- [ ] dialogue.dart 모델 생성
- [ ] npc.dart 모델 생성
- [ ] dialogue_manager.dart 구현
- [ ] npc_component.dart 구현
- [ ] dialogue_overlay.dart 구현
- [ ] ArcanaGame에 통합
- [ ] 테스트용 NPC 및 대화 데이터 추가
