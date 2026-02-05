/// Arcana: The Three Hearts - NPC 데이터 모델
/// NPC 정의 및 조건부 대화 매핑
library;

import 'dialogue.dart';

/// 조건부 대화 매핑
class ConditionalDialogue {
  const ConditionalDialogue({
    required this.dialogueId,
    required this.condition,
    this.priority = 0,
  });

  /// 대화 시퀀스 ID
  final String dialogueId;

  /// 표시 조건
  final DialogueCondition condition;

  /// 우선순위 (높을수록 먼저 체크)
  final int priority;

  /// JSON에서 생성
  factory ConditionalDialogue.fromJson(Map<String, dynamic> json) {
    return ConditionalDialogue(
      dialogueId: json['dialogue_id'] as String,
      condition: DialogueCondition.fromJson(
        json['conditions'] as Map<String, dynamic>? ?? {},
      ),
      priority: json['priority'] as int? ?? 0,
    );
  }
}

/// NPC 타입
enum NpcType {
  story,      // 스토리 NPC
  merchant,   // 상인
  blacksmith, // 대장장이
  healer,     // 힐러
  quest,      // 퀘스트 NPC
}

/// NPC 데이터
class NpcData {
  const NpcData({
    required this.id,
    required this.name,
    required this.type,
    required this.spriteSheet,
    required this.defaultDialogueId,
    this.conditionalDialogues = const [],
    this.interactionRange = 48.0,
  });

  /// NPC 고유 ID
  final String id;

  /// NPC 이름
  final String name;

  /// NPC 타입
  final NpcType type;

  /// 스프라이트 시트 경로
  final String spriteSheet;

  /// 기본 대화 시퀀스 ID
  final String defaultDialogueId;

  /// 조건부 대화 목록 (우선순위 순)
  final List<ConditionalDialogue> conditionalDialogues;

  /// 상호작용 범위 (픽셀)
  final double interactionRange;

  /// JSON에서 생성
  factory NpcData.fromJson(Map<String, dynamic> json) {
    return NpcData(
      id: json['id'] as String,
      name: json['name'] as String,
      type: NpcType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NpcType.story,
      ),
      spriteSheet: json['sprite_sheet'] as String,
      defaultDialogueId: json['default_dialogue_id'] as String,
      conditionalDialogues: json['conditional_dialogues'] != null
          ? (json['conditional_dialogues'] as List)
              .map((c) => ConditionalDialogue.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      interactionRange: (json['interaction_range'] as num?)?.toDouble() ?? 48.0,
    );
  }
}

/// 사전 정의된 NPC 목록
class Npcs {
  Npcs._();

  // 릴리아나 - 주요 스토리 NPC
  static const liliana = NpcData(
    id: 'liliana',
    name: '릴리아나',
    type: NpcType.story,
    spriteSheet: 'npcs/liliana.png',
    defaultDialogueId: 'liliana_default',
    conditionalDialogues: [
      ConditionalDialogue(
        dialogueId: 'liliana_chapter1_intro',
        condition: DialogueCondition(maxChapter: 1),
        priority: 10,
      ),
      ConditionalDialogue(
        dialogueId: 'liliana_after_first_heart',
        condition: DialogueCondition(specificHeart: 1),
        priority: 5,
      ),
    ],
  );

  // 볼칸 - 대장장이
  static const volkan = NpcData(
    id: 'volkan',
    name: '볼칸',
    type: NpcType.blacksmith,
    spriteSheet: 'npcs/volkan.png',
    defaultDialogueId: 'volkan_default',
    conditionalDialogues: [
      ConditionalDialogue(
        dialogueId: 'volkan_first_meet',
        condition: DialogueCondition(
          flagRequired: 'met_volkan',
          flagValue: false,
        ),
        priority: 10,
      ),
    ],
  );

  // 상인
  static const merchant = NpcData(
    id: 'merchant',
    name: '떠돌이 상인',
    type: NpcType.merchant,
    spriteSheet: 'npcs/merchant.png',
    defaultDialogueId: 'merchant_default',
  );

  // 엘리아스 - 지식의 NPC
  static const elias = NpcData(
    id: 'elias',
    name: '엘리아스',
    type: NpcType.story,
    spriteSheet: 'npcs/elias.png',
    defaultDialogueId: 'elias_default',
    conditionalDialogues: [
      ConditionalDialogue(
        dialogueId: 'elias_lore_hearts',
        condition: DialogueCondition(heartsRequired: 1),
        priority: 5,
      ),
    ],
  );

  // === 챕터 1: 잊혀진 숲 NPC ===

  // 재의 상인 (Ash Merchant)
  static const ashMerchant = NpcData(
    id: 'ash_merchant',
    name: '재의 상인',
    type: NpcType.merchant,
    spriteSheet: 'npcs/ash_merchant.png',
    defaultDialogueId: 'ash_merchant_default',
    conditionalDialogues: [
      // 챕터 2 재등장
      ConditionalDialogue(
        dialogueId: 'ash_merchant_ch2',
        condition: DialogueCondition(
          minChapter: 2,
          flagRequired: 'met_ash_merchant_ch2',
          flagValue: false,
        ),
        priority: 15,
      ),
      // 첫 만남 (챕터 1)
      ConditionalDialogue(
        dialogueId: 'ash_merchant_first',
        condition: DialogueCondition(
          flagRequired: 'met_ash_merchant',
          flagValue: false,
        ),
        priority: 10,
      ),
    ],
  );

  // === 챕터 2: 무너진 성채 NPC ===

  // 눈먼 기사 (Blind Knight)
  static const blindKnight = NpcData(
    id: 'blind_knight',
    name: '눈먼 기사',
    type: NpcType.story,
    spriteSheet: 'npcs/blind_knight.png',
    defaultDialogueId: 'blind_knight_default',
    conditionalDialogues: [
      // 첫 만남
      ConditionalDialogue(
        dialogueId: 'blind_knight_first',
        condition: DialogueCondition(
          flagRequired: 'met_blind_knight',
          flagValue: false,
        ),
        priority: 10,
      ),
    ],
  );

  // === 챕터 3: 침묵의 성당 NPC ===

  // 말 없는 수녀 (Voiceless Nun)
  static const voicelessNun = NpcData(
    id: 'voiceless_nun',
    name: '말 없는 수녀',
    type: NpcType.story,
    spriteSheet: 'npcs/voiceless_nun.png',
    defaultDialogueId: 'voiceless_nun_default',
    conditionalDialogues: [
      // 첫 만남
      ConditionalDialogue(
        dialogueId: 'voiceless_nun_first',
        condition: DialogueCondition(
          flagRequired: 'met_voiceless_nun',
          flagValue: false,
        ),
        priority: 10,
      ),
    ],
  );

  // 배교한 사제 (Apostate Priest)
  static const apostatePriest = NpcData(
    id: 'apostate_priest',
    name: '배교한 사제',
    type: NpcType.story,
    spriteSheet: 'npcs/apostate_priest.png',
    defaultDialogueId: 'apostate_priest_default',
    conditionalDialogues: [
      // 첫 만남
      ConditionalDialogue(
        dialogueId: 'apostate_priest_first',
        condition: DialogueCondition(
          flagRequired: 'met_apostate_priest',
          flagValue: false,
        ),
        priority: 10,
      ),
    ],
  );

  // === 챕터 4: 피의 정원 NPC ===

  // 정원사 (The Gardener)
  static const gardener = NpcData(
    id: 'gardener',
    name: '정원사',
    type: NpcType.story,
    spriteSheet: 'npcs/gardener.png',
    defaultDialogueId: 'gardener_default',
    conditionalDialogues: [
      // 첫 만남
      ConditionalDialogue(
        dialogueId: 'gardener_first',
        condition: DialogueCondition(
          flagRequired: 'met_gardener',
          flagValue: false,
        ),
        priority: 10,
      ),
    ],
  );

  // === 챕터 5: 기억의 심연 NPC ===

  // 과거의 자신 (Past Self)
  static const pastSelf = NpcData(
    id: 'past_self',
    name: '과거의 나',
    type: NpcType.story,
    spriteSheet: 'npcs/past_self.png',
    defaultDialogueId: 'ch5_mirror_room',
    conditionalDialogues: [],
  );

  // 미래의 자신 (Future Self / ???)
  static const futureSelf = NpcData(
    id: 'future_self',
    name: '???',
    type: NpcType.story,
    spriteSheet: 'npcs/future_self.png',
    defaultDialogueId: 'ch5_truth_room',
    conditionalDialogues: [
      // 진실 공개 후
      ConditionalDialogue(
        dialogueId: 'ch5_future_farewell',
        condition: DialogueCondition(
          flagRequired: 'truth_revealed',
          flagValue: true,
        ),
        priority: 10,
      ),
    ],
  );

  // === 챕터 6: 망각의 옥좌 NPC ===

  // 잊혀진 현자 (Forgotten Sage)
  static const forgottenSage = NpcData(
    id: 'forgotten_sage',
    name: '잊혀진 현자',
    type: NpcType.story,
    spriteSheet: 'npcs/forgotten_sage.png',
    defaultDialogueId: 'ch6_forgotten_sage',
    conditionalDialogues: [
      // 트루 엔딩 조건 확인
      ConditionalDialogue(
        dialogueId: 'ch6_true_ending_hint',
        condition: DialogueCondition(
          flagRequired: 'has_all_hearts',
          flagValue: true,
        ),
        priority: 10,
      ),
    ],
  );

  // 봉인된 리리아나 (Sealed Liliana - 망각의 옥좌)
  static const sealedLiliana = NpcData(
    id: 'sealed_liliana',
    name: '봉인된 리리아나',
    type: NpcType.story,
    spriteSheet: 'npcs/sealed_liliana.png',
    defaultDialogueId: 'ch6_liliana_reunion',
    conditionalDialogues: [
      // 전투 후 재회
      ConditionalDialogue(
        dialogueId: 'ch6_liliana_freed',
        condition: DialogueCondition(
          flagRequired: 'oblivion_defeated',
          flagValue: true,
        ),
        priority: 10,
      ),
    ],
  );

  static const List<NpcData> all = [
    liliana,
    volkan,
    merchant,
    elias,
    ashMerchant,
    blindKnight,
    voicelessNun,
    apostatePriest,
    gardener,
    pastSelf,
    futureSelf,
    forgottenSage,
    sealedLiliana,
  ];

  static NpcData? findById(String id) {
    try {
      return all.firstWhere((npc) => npc.id == id);
    } catch (_) {
      return null;
    }
  }
}
