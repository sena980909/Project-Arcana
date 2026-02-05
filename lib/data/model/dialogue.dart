/// Arcana: The Three Hearts - 대화 데이터 모델
/// NPC 대화 시스템용 데이터 정의
library;

/// 대화 트리거 타입
enum TriggerType {
  giveItem,     // 아이템 지급
  setFlag,      // 스토리 플래그 설정
  unlockShop,   // 상점 해금
  heal,         // 체력 회복
  startQuest,   // 퀘스트 시작
  giveGold,     // 골드 지급
}

/// 대화 트리거 (특수 효과)
class DialogueTrigger {
  const DialogueTrigger({
    required this.type,
    this.itemId,
    this.flagName,
    this.flagValue,
    this.amount,
  });

  /// 트리거 타입
  final TriggerType type;

  /// 아이템 ID (giveItem용)
  final String? itemId;

  /// 플래그 이름 (setFlag용)
  final String? flagName;

  /// 플래그 값 (setFlag용)
  final bool? flagValue;

  /// 수량/금액 (giveItem, giveGold, heal용)
  final int? amount;

  /// JSON에서 생성
  factory DialogueTrigger.fromJson(Map<String, dynamic> json) {
    return DialogueTrigger(
      type: TriggerType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TriggerType.setFlag,
      ),
      itemId: json['item_id'] as String?,
      flagName: json['flag_name'] as String?,
      flagValue: json['flag_value'] as bool?,
      amount: json['amount'] as int?,
    );
  }
}

/// 대화 조건
class DialogueCondition {
  const DialogueCondition({
    this.minChapter,
    this.maxChapter,
    this.heartsRequired,
    this.specificHeart,
    this.hasItem,
    this.flagRequired,
    this.flagValue,
  });

  /// 최소 챕터
  final int? minChapter;

  /// 최대 챕터
  final int? maxChapter;

  /// 필요 심장 개수
  final int? heartsRequired;

  /// 특정 심장 필요 (1, 2, 3)
  final int? specificHeart;

  /// 필요 아이템 ID
  final String? hasItem;

  /// 필요 플래그 이름
  final String? flagRequired;

  /// 플래그 값 (기본 true)
  final bool? flagValue;

  /// JSON에서 생성
  factory DialogueCondition.fromJson(Map<String, dynamic> json) {
    return DialogueCondition(
      minChapter: json['chapter'] as int? ?? json['min_chapter'] as int?,
      maxChapter: json['max_chapter'] as int?,
      heartsRequired: json['hearts_required'] as int?,
      specificHeart: json['specific_heart'] as int?,
      hasItem: json['has_item'] as String?,
      flagRequired: json['flag'] as String?,
      flagValue: json['flag_value'] as bool?,
    );
  }

  /// 조건 없음
  static const none = DialogueCondition();

  /// 조건이 비어있는지 확인
  bool get isEmpty =>
      minChapter == null &&
      maxChapter == null &&
      heartsRequired == null &&
      specificHeart == null &&
      hasItem == null &&
      flagRequired == null;
}

/// 대화 선택지
class DialogueChoice {
  const DialogueChoice({
    required this.text,
    this.nextId,
    this.trigger,
    this.condition,
  });

  /// 선택지 텍스트
  final String text;

  /// 다음 대화 노드 ID (null이면 대화 종료)
  final String? nextId;

  /// 선택 시 트리거
  final DialogueTrigger? trigger;

  /// 표시 조건 (조건 불충족 시 숨김)
  final DialogueCondition? condition;

  /// JSON에서 생성
  factory DialogueChoice.fromJson(Map<String, dynamic> json) {
    return DialogueChoice(
      text: json['text'] as String,
      nextId: json['next_id'] as String?,
      trigger: json['trigger'] != null
          ? DialogueTrigger.fromJson(json['trigger'] as Map<String, dynamic>)
          : null,
      condition: json['condition'] != null
          ? DialogueCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 대화 노드
class DialogueNode {
  const DialogueNode({
    required this.id,
    required this.speakerId,
    required this.text,
    this.portrait,
    this.choices,
    this.nextId,
    this.trigger,
  });

  /// 노드 고유 ID
  final String id;

  /// 화자 ID
  final String speakerId;

  /// 대사 텍스트
  final String text;

  /// 초상화 이미지 경로
  final String? portrait;

  /// 선택지 목록 (null이면 자동 진행)
  final List<DialogueChoice>? choices;

  /// 다음 노드 ID (선택지 없을 때)
  final String? nextId;

  /// 노드 표시 시 트리거
  final DialogueTrigger? trigger;

  /// 선택지가 있는지 확인
  bool get hasChoices => choices != null && choices!.isNotEmpty;

  /// JSON에서 생성
  factory DialogueNode.fromJson(Map<String, dynamic> json) {
    return DialogueNode(
      id: json['id'] as String,
      speakerId: json['speaker_id'] as String,
      text: json['text'] as String,
      portrait: json['portrait'] as String?,
      choices: json['choices'] != null
          ? (json['choices'] as List)
              .map((c) => DialogueChoice.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
      nextId: json['next_id'] as String?,
      trigger: json['trigger'] != null
          ? DialogueTrigger.fromJson(json['trigger'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 대화 시퀀스 (여러 노드로 구성)
class DialogueSequence {
  const DialogueSequence({
    required this.id,
    required this.nodes,
  });

  /// 시퀀스 ID
  final String id;

  /// 노드 목록
  final List<DialogueNode> nodes;

  /// 시작 노드
  DialogueNode get startNode => nodes.first;

  /// ID로 노드 찾기
  DialogueNode? getNodeById(String nodeId) {
    try {
      return nodes.firstWhere((n) => n.id == nodeId);
    } catch (_) {
      return null;
    }
  }

  /// JSON에서 생성
  factory DialogueSequence.fromJson(Map<String, dynamic> json) {
    return DialogueSequence(
      id: json['id'] as String,
      nodes: (json['nodes'] as List)
          .map((n) => DialogueNode.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 화자 정보
class Speaker {
  const Speaker({
    required this.id,
    required this.name,
    this.defaultPortrait,
  });

  /// 화자 ID
  final String id;

  /// 표시 이름
  final String name;

  /// 기본 초상화
  final String? defaultPortrait;
}

/// 사전 정의된 화자 목록
class Speakers {
  Speakers._();

  static const player = Speaker(
    id: 'player',
    name: '???',
  );

  static const liliana = Speaker(
    id: 'liliana',
    name: '릴리아나',
    defaultPortrait: 'portraits/liliana.png',
  );

  static const volkan = Speaker(
    id: 'volkan',
    name: '볼칸',
    defaultPortrait: 'portraits/volkan.png',
  );

  static const elias = Speaker(
    id: 'elias',
    name: '엘리아스',
    defaultPortrait: 'portraits/elias.png',
  );

  static const merchant = Speaker(
    id: 'merchant',
    name: '상인',
    defaultPortrait: 'portraits/merchant.png',
  );

  static const system = Speaker(
    id: 'system',
    name: '',
  );

  static const List<Speaker> all = [
    player,
    liliana,
    volkan,
    elias,
    merchant,
    system,
  ];

  static Speaker? findById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
