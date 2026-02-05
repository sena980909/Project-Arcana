/// Arcana: The Three Hearts - 대화 관리자
/// 대화 진행, 조건 체크, 트리거 실행
library;

import 'package:flutter/foundation.dart';

import '../../data/model/dialogue.dart';
import '../../data/model/npc.dart';
import '../../providers/game_state_provider.dart';

/// 대화 상태
enum DialogueState {
  idle,       // 대화 없음
  active,     // 대화 진행 중
  choosing,   // 선택지 표시 중
  finished,   // 대화 종료
}

/// 대화 관리자
class DialogueManager {
  DialogueManager({
    required this.gameState,
    required this.inventory,
    this.onDialogueStart,
    this.onDialogueEnd,
    this.onNodeChanged,
    this.onTriggerExecuted,
  });

  /// 게임 상태 참조
  final GameState gameState;

  /// 인벤토리 아이템 ID 목록
  final List<String> inventory;

  /// 대화 시작 콜백
  final VoidCallback? onDialogueStart;

  /// 대화 종료 콜백
  final VoidCallback? onDialogueEnd;

  /// 노드 변경 콜백
  final void Function(DialogueNode node)? onNodeChanged;

  /// 트리거 실행 콜백
  final void Function(DialogueTrigger trigger)? onTriggerExecuted;

  /// 현재 대화 상태
  DialogueState _state = DialogueState.idle;
  DialogueState get state => _state;

  /// 현재 대화 시퀀스
  DialogueSequence? _currentSequence;
  DialogueSequence? get currentSequence => _currentSequence;

  /// 현재 대화 노드
  DialogueNode? _currentNode;
  DialogueNode? get currentNode => _currentNode;

  /// 대화 활성화 여부
  bool get isActive => _state == DialogueState.active || _state == DialogueState.choosing;

  /// 마지막으로 완료된 대화 시퀀스 ID
  String? _lastCompletedSequenceId;
  String? get lastCompletedSequenceId => _lastCompletedSequenceId;

  /// 마지막 대화 진행 시간 (스팸 방지)
  DateTime? _lastAdvanceTime;

  /// 최소 대화 진행 간격
  static const Duration _minAdvanceInterval = Duration(milliseconds: 150);

  /// 로드된 대화 시퀀스들
  final Map<String, DialogueSequence> _sequences = {};

  /// 대화 시퀀스 등록
  void registerSequence(DialogueSequence sequence) {
    _sequences[sequence.id] = sequence;
  }

  /// 여러 시퀀스 등록
  void registerSequences(List<DialogueSequence> sequences) {
    for (final seq in sequences) {
      _sequences[seq.id] = seq;
    }
  }

  /// NPC와 대화 시작
  bool startDialogueWithNpc(NpcData npc) {
    final dialogueId = _selectDialogueForNpc(npc);
    if (dialogueId == null) {
      debugPrint('No dialogue found for NPC: ${npc.id}');
      return false;
    }
    return startDialogue(dialogueId);
  }

  /// NPC의 조건에 맞는 대화 선택
  String? _selectDialogueForNpc(NpcData npc) {
    // 우선순위 순으로 조건부 대화 체크
    final sortedConditional = List<ConditionalDialogue>.from(npc.conditionalDialogues)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final conditional in sortedConditional) {
      if (checkCondition(conditional.condition)) {
        return conditional.dialogueId;
      }
    }

    // 기본 대화 반환
    return npc.defaultDialogueId;
  }

  /// 대화 시작
  bool startDialogue(String sequenceId) {
    final sequence = _sequences[sequenceId];
    if (sequence == null) {
      debugPrint('Dialogue sequence not found: $sequenceId');
      return false;
    }

    _currentSequence = sequence;
    _currentNode = sequence.startNode;
    _state = _currentNode!.hasChoices
        ? DialogueState.choosing
        : DialogueState.active;

    // 시작 노드 트리거 실행
    if (_currentNode!.trigger != null) {
      _executeTrigger(_currentNode!.trigger!);
    }

    onDialogueStart?.call();
    onNodeChanged?.call(_currentNode!);

    return true;
  }

  /// 다음 대화로 진행
  void advance() {
    if (_currentNode == null || _currentSequence == null) return;

    // 스팸 방지: 최소 간격 체크
    final now = DateTime.now();
    if (_lastAdvanceTime != null) {
      final elapsed = now.difference(_lastAdvanceTime!);
      if (elapsed < _minAdvanceInterval) {
        return; // 너무 빠른 입력 무시
      }
    }
    _lastAdvanceTime = now;

    // 선택지가 있으면 진행 불가 (선택 필요)
    if (_currentNode!.hasChoices) {
      _state = DialogueState.choosing;
      return;
    }

    // 다음 노드로 이동
    final nextId = _currentNode!.nextId;
    if (nextId == null) {
      // 대화 종료
      _endDialogue();
      return;
    }

    final nextNode = _currentSequence!.getNodeById(nextId);
    if (nextNode == null) {
      debugPrint('Next node not found: $nextId');
      _endDialogue();
      return;
    }

    _moveToNode(nextNode);
  }

  /// 선택지 선택
  void selectChoice(int choiceIndex) {
    if (_currentNode == null || !_currentNode!.hasChoices) return;

    final visibleChoices = getVisibleChoices();
    if (choiceIndex < 0 || choiceIndex >= visibleChoices.length) return;

    final choice = visibleChoices[choiceIndex];

    // 선택지 트리거 실행
    if (choice.trigger != null) {
      _executeTrigger(choice.trigger!);
    }

    // 다음 노드로 이동
    if (choice.nextId == null) {
      _endDialogue();
      return;
    }

    final nextNode = _currentSequence!.getNodeById(choice.nextId!);
    if (nextNode == null) {
      debugPrint('Next node from choice not found: ${choice.nextId}');
      _endDialogue();
      return;
    }

    _moveToNode(nextNode);
  }

  /// 조건을 만족하는 선택지만 반환
  List<DialogueChoice> getVisibleChoices() {
    if (_currentNode == null || !_currentNode!.hasChoices) {
      return [];
    }

    return _currentNode!.choices!.where((choice) {
      if (choice.condition == null || choice.condition!.isEmpty) {
        return true;
      }
      return checkCondition(choice.condition!);
    }).toList();
  }

  /// 노드로 이동
  void _moveToNode(DialogueNode node) {
    _currentNode = node;
    _state = node.hasChoices ? DialogueState.choosing : DialogueState.active;

    // 노드 트리거 실행
    if (node.trigger != null) {
      _executeTrigger(node.trigger!);
    }

    onNodeChanged?.call(node);
  }

  /// 대화 종료
  void _endDialogue() {
    _state = DialogueState.finished;
    // 완료된 시퀀스 ID 저장 (null이 되기 전에)
    _lastCompletedSequenceId = _currentSequence?.id;
    _currentNode = null;
    _currentSequence = null;
    onDialogueEnd?.call();

    // 상태 리셋 (다음 프레임에서)
    Future.microtask(() {
      _state = DialogueState.idle;
    });
  }

  /// 대화 강제 종료
  void forceEnd() {
    _endDialogue();
  }

  /// 조건 체크
  bool checkCondition(DialogueCondition condition) {
    // 챕터 조건
    if (condition.minChapter != null) {
      if (gameState.currentChapter < condition.minChapter!) return false;
    }
    if (condition.maxChapter != null) {
      if (gameState.currentChapter > condition.maxChapter!) return false;
    }

    // 심장 개수 조건
    if (condition.heartsRequired != null) {
      if (gameState.heartCount < condition.heartsRequired!) return false;
    }

    // 특정 심장 조건
    if (condition.specificHeart != null) {
      if (!gameState.hasHeart(condition.specificHeart!)) return false;
    }

    // 아이템 보유 조건
    if (condition.hasItem != null) {
      if (!inventory.contains(condition.hasItem)) return false;
    }

    // 플래그 조건
    if (condition.flagRequired != null) {
      final requiredValue = condition.flagValue ?? true;
      final currentValue = gameState.getFlag(condition.flagRequired!);
      if (currentValue != requiredValue) return false;
    }

    return true;
  }

  /// 트리거 실행
  void _executeTrigger(DialogueTrigger trigger) {
    onTriggerExecuted?.call(trigger);

    switch (trigger.type) {
      case TriggerType.giveItem:
        debugPrint('Trigger: Give item ${trigger.itemId}');
        break;
      case TriggerType.setFlag:
        debugPrint('Trigger: Set flag ${trigger.flagName} = ${trigger.flagValue}');
        break;
      case TriggerType.unlockShop:
        debugPrint('Trigger: Unlock shop');
        break;
      case TriggerType.heal:
        debugPrint('Trigger: Heal ${trigger.amount}');
        break;
      case TriggerType.startQuest:
        debugPrint('Trigger: Start quest');
        break;
      case TriggerType.giveGold:
        debugPrint('Trigger: Give gold ${trigger.amount}');
        break;
    }
  }
}

/// 테스트용 대화 데이터
class TestDialogues {
  TestDialogues._();

  /// 릴리아나 첫 만남
  static final lilianaChapter1Intro = DialogueSequence(
    id: 'liliana_chapter1_intro',
    nodes: [
      const DialogueNode(
        id: 'l1_1',
        speakerId: 'liliana',
        text: '...당신도 이곳에 떨어졌군요.',
        nextId: 'l1_2',
      ),
      const DialogueNode(
        id: 'l1_2',
        speakerId: 'liliana',
        text: '여기는 망각의 왕국... 잊혀진 자들이 모이는 곳이에요.',
        nextId: 'l1_3',
      ),
      const DialogueNode(
        id: 'l1_3',
        speakerId: 'liliana',
        text: '당신의 이름은... 아, 이미 잊어버렸군요.',
        nextId: 'l1_4',
      ),
      const DialogueNode(
        id: 'l1_4',
        speakerId: 'player',
        text: '(나는 누구지...?)',
        nextId: 'l1_5',
      ),
      const DialogueNode(
        id: 'l1_5',
        speakerId: 'liliana',
        text: '기억을 되찾고 싶다면... 세 개의 심장을 찾아야 해요.',
        choices: [
          DialogueChoice(
            text: '세 개의 심장이 뭔가요?',
            nextId: 'l1_6a',
          ),
          DialogueChoice(
            text: '당신은 누구죠?',
            nextId: 'l1_6b',
          ),
        ],
      ),
      const DialogueNode(
        id: 'l1_6a',
        speakerId: 'liliana',
        text: '기억, 수용, 의지... 인간성을 구성하는 세 가지 조각이에요.',
        nextId: 'l1_end',
      ),
      const DialogueNode(
        id: 'l1_6b',
        speakerId: 'liliana',
        text: '저는... 그냥 이곳을 떠돌고 있을 뿐이에요.',
        nextId: 'l1_end',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'asked_liliana_identity',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'l1_end',
        speakerId: 'liliana',
        text: '부디 조심하세요. 이 왕국은 위험해요.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_liliana',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 릴리아나 기본 대화
  static final lilianaDefault = DialogueSequence(
    id: 'liliana_default',
    nodes: [
      const DialogueNode(
        id: 'ld_1',
        speakerId: 'liliana',
        text: '아직 갈 길이 멀어요. 힘내세요.',
      ),
    ],
  );

  /// 상인 기본 대화
  static final merchantDefault = DialogueSequence(
    id: 'merchant_default',
    nodes: [
      const DialogueNode(
        id: 'md_1',
        speakerId: 'merchant',
        text: '어서오게, 여행자여. 좋은 물건이 많다네.',
        choices: [
          DialogueChoice(
            text: '물건을 보여주세요.',
            nextId: 'md_shop',
            trigger: DialogueTrigger(type: TriggerType.unlockShop),
          ),
          DialogueChoice(
            text: '그만 둘게요.',
            nextId: null,
          ),
        ],
      ),
      const DialogueNode(
        id: 'md_shop',
        speakerId: 'merchant',
        text: '천천히 둘러보게나.',
      ),
    ],
  );

  /// 모든 테스트 대화 목록
  static List<DialogueSequence> get all => [
        lilianaChapter1Intro,
        lilianaDefault,
        merchantDefault,
      ];
}
