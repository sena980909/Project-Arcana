/// Arcana: The Three Hearts - 챕터 1 대화
/// 잊혀진 숲 (The Forgotten Grove)
library;

import '../model/dialogue.dart';

/// 챕터 1 대화 시퀀스 모음
class Chapter1Dialogues {
  Chapter1Dialogues._();

  /// === 프롤로그 ===
  static final prologue = DialogueSequence(
    id: 'ch1_prologue',
    nodes: [
      const DialogueNode(
        id: 'pro_1',
        speakerId: 'system',
        text: '...어둠 속에서 눈을 뜬다.',
        nextId: 'pro_2',
      ),
      const DialogueNode(
        id: 'pro_2',
        speakerId: 'player',
        text: '(여기가... 어디지?)',
        nextId: 'pro_3',
      ),
      const DialogueNode(
        id: 'pro_3',
        speakerId: 'system',
        text: '차가운 안개가 온몸을 감싼다. 기억은 없다. 이름도, 과거도.',
        nextId: 'pro_4',
      ),
      const DialogueNode(
        id: 'pro_4',
        speakerId: 'player',
        text: '(가슴에... 무언가가 새겨져 있다. 세 개의 심장...)',
        nextId: 'pro_5',
      ),
      const DialogueNode(
        id: 'pro_5',
        speakerId: 'system',
        text: '희미한 빛이 숲 깊은 곳에서 맥동한다. 본능적으로 알 수 있다.',
        nextId: 'pro_6',
      ),
      const DialogueNode(
        id: 'pro_6',
        speakerId: 'system',
        text: '그곳에 - 잃어버린 것들이 있다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'prologue_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 재의 상인 첫 만남 ===
  static final ashMerchantFirstMeet = DialogueSequence(
    id: 'ash_merchant_first',
    nodes: [
      const DialogueNode(
        id: 'ash_1',
        speakerId: 'ash_merchant',
        text: '...또 한 명이로군.',
        nextId: 'ash_2',
      ),
      const DialogueNode(
        id: 'ash_2',
        speakerId: 'ash_merchant',
        text: '이곳에 떨어진 자들은 모두 같은 눈을 하고 있어. 텅 빈, 아무것도 기억하지 못하는 눈.',
        nextId: 'ash_3',
      ),
      const DialogueNode(
        id: 'ash_3',
        speakerId: 'player',
        text: '(눈이... 없다. 빈 눈구멍에서 연기가...)',
        nextId: 'ash_4',
      ),
      const DialogueNode(
        id: 'ash_4',
        speakerId: 'ash_merchant',
        text: '겁먹지 마. 난 이미 볼 것을 다 봤으니까.',
        choices: [
          DialogueChoice(
            text: '여긴 어디죠?',
            nextId: 'ash_where',
          ),
          DialogueChoice(
            text: '당신은 누구입니까?',
            nextId: 'ash_who',
          ),
          DialogueChoice(
            text: '(무시하고 지나간다)',
            nextId: null,
          ),
        ],
      ),
      // 여긴 어디죠?
      const DialogueNode(
        id: 'ash_where',
        speakerId: 'ash_merchant',
        text: '\'잊혀진 숲\'이라고 부르지. 세상에서 잊혀진 것들이 모이는 곳.',
        nextId: 'ash_where_2',
      ),
      const DialogueNode(
        id: 'ash_where_2',
        speakerId: 'ash_merchant',
        text: '숲의 깊은 곳에는... 오래된 것이 있어. 아주 슬프고, 아주 분노한 것이.',
        nextId: 'ash_shop_offer',
      ),
      // 당신은 누구입니까?
      const DialogueNode(
        id: 'ash_who',
        speakerId: 'ash_merchant',
        text: '...상인이야. 재가 된 자들이 남긴 것들을 팔지.',
        nextId: 'ash_who_2',
      ),
      const DialogueNode(
        id: 'ash_who_2',
        speakerId: 'ash_merchant',
        text: '(잠시 침묵) 예전엔... 다른 이름으로 불렸지만, 그건 중요치 않아.',
        nextId: 'ash_shop_offer',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'asked_ash_merchant_identity',
          flagValue: true,
        ),
      ),
      // 상점 제안
      const DialogueNode(
        id: 'ash_shop_offer',
        speakerId: 'ash_merchant',
        text: '물건이 필요하면 말해. 이 숲에서 살아남으려면... 준비가 필요할 테니.',
        choices: [
          DialogueChoice(
            text: '물건을 보여주세요.',
            nextId: 'ash_shop',
            trigger: DialogueTrigger(type: TriggerType.unlockShop),
          ),
          DialogueChoice(
            text: '숲에 대해 더 알려주세요.',
            nextId: 'ash_hint',
          ),
          DialogueChoice(
            text: '됐습니다.',
            nextId: null,
          ),
        ],
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_ash_merchant',
          flagValue: true,
        ),
      ),
      // 상점
      const DialogueNode(
        id: 'ash_shop',
        speakerId: 'ash_merchant',
        text: '천천히 골라. 서두를 필요 없어... 어차피 우리 모두, 시간만은 넉넉하니까.',
      ),
      // 힌트
      const DialogueNode(
        id: 'ash_hint',
        speakerId: 'ash_merchant',
        text: '숲의 중심에 제단이 있어. 거기서... (말을 멈춘다)',
        nextId: 'ash_hint_2',
      ),
      const DialogueNode(
        id: 'ash_hint_2',
        speakerId: 'ash_merchant',
        text: '아니, 직접 보는 게 나을 거야. 다만... 눈물에 닿지 마. 닿으면 슬픔이 전염되니까.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'ash_merchant_hint',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 재의 상인 기본 대화 ===
  static final ashMerchantDefault = DialogueSequence(
    id: 'ash_merchant_default',
    nodes: [
      const DialogueNode(
        id: 'ash_def_1',
        speakerId: 'ash_merchant',
        text: '아직 살아있군. 좋은 일이야.',
        choices: [
          DialogueChoice(
            text: '물건을 보여주세요.',
            nextId: 'ash_def_shop',
            trigger: DialogueTrigger(type: TriggerType.unlockShop),
          ),
          DialogueChoice(
            text: '(떠난다)',
            nextId: null,
          ),
        ],
      ),
      const DialogueNode(
        id: 'ash_def_shop',
        speakerId: 'ash_merchant',
        text: '골라.',
      ),
    ],
  );

  /// === 제단 발견 ===
  static final altarDiscovery = DialogueSequence(
    id: 'ch1_altar_discovery',
    nodes: [
      const DialogueNode(
        id: 'altar_1',
        speakerId: 'system',
        text: '부서진 제단이 있다. 이끼와 덩굴에 뒤덮여 있지만, 한때는 신성한 곳이었음을 알 수 있다.',
        nextId: 'altar_2',
      ),
      const DialogueNode(
        id: 'altar_2',
        speakerId: 'player',
        text: '(제단 위에 무언가 빛나고 있다...)',
        nextId: 'altar_3',
      ),
      const DialogueNode(
        id: 'altar_3',
        speakerId: 'system',
        text: '\'부서진 나뭇잎 펜던트\'를 발견했다.',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'broken_leaf_pendant',
          amount: 1,
        ),
      ),
    ],
  );

  /// === 환청 (Hearts < 3) ===
  static final hallucination = DialogueSequence(
    id: 'ch1_hallucination',
    nodes: [
      const DialogueNode(
        id: 'hall_1',
        speakerId: 'unknown',
        text: '...돌아와...',
        nextId: 'hall_2',
      ),
      const DialogueNode(
        id: 'hall_2',
        speakerId: 'player',
        text: '(누구지...? 머릿속에서 목소리가...)',
        nextId: 'hall_3',
      ),
      const DialogueNode(
        id: 'hall_3',
        speakerId: 'unknown',
        text: '왜 날 버렸어...? 왜...?',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'heard_hallucination',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 이그드라 보스 조우 ===
  static final yggdraEncounter = DialogueSequence(
    id: 'ch1_yggdra_encounter',
    nodes: [
      const DialogueNode(
        id: 'ygg_1',
        speakerId: 'system',
        text: '숲의 가장 깊은 곳. 거대한 고목이 서 있다.',
        nextId: 'ygg_2',
      ),
      const DialogueNode(
        id: 'ygg_2',
        speakerId: 'system',
        text: '나무가... 움직인다. 아니, 나무 속에서 무언가가 깨어난다.',
        nextId: 'ygg_3',
      ),
      const DialogueNode(
        id: 'ygg_3',
        speakerId: 'yggdra',
        text: '...또... 왔구나...',
        nextId: 'ygg_4',
      ),
      const DialogueNode(
        id: 'ygg_4',
        speakerId: 'yggdra',
        text: '모두... 나를 잊었어... 지키겠다던 약속도... 함께하겠다던 맹세도...',
        nextId: 'ygg_5',
      ),
      const DialogueNode(
        id: 'ygg_5',
        speakerId: 'yggdra',
        text: '너도... 마찬가지겠지... 결국엔... 모두가...',
        nextId: 'ygg_6',
      ),
      const DialogueNode(
        id: 'ygg_6',
        speakerId: 'yggdra',
        text: '...잊혀지는 것이 얼마나 아픈지... 알게 해줄게.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'yggdra_encounter_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 이그드라 Phase 2 전환 ===
  static final yggdraPhase2 = DialogueSequence(
    id: 'ch1_yggdra_phase2',
    nodes: [
      const DialogueNode(
        id: 'ygg_p2_1',
        speakerId: 'yggdra',
        text: '...아파... 아파아아아!',
        nextId: 'ygg_p2_2',
      ),
      const DialogueNode(
        id: 'ygg_p2_2',
        speakerId: 'yggdra',
        text: '그가... 약속했어! 영원히 함께할 거라고!',
        nextId: 'ygg_p2_3',
      ),
      const DialogueNode(
        id: 'ygg_p2_3',
        speakerId: 'yggdra',
        text: '거짓말이었어! 전부! 전부 거짓말!!!',
      ),
    ],
  );

  /// === 이그드라 처치 ===
  static final yggdraDefeat = DialogueSequence(
    id: 'ch1_yggdra_defeat',
    nodes: [
      const DialogueNode(
        id: 'ygg_d_1',
        speakerId: 'system',
        text: '이그드라가 쓰러진다. 분노가 사그라들고, 슬픔만이 남는다.',
        nextId: 'ygg_d_2',
      ),
      const DialogueNode(
        id: 'ygg_d_2',
        speakerId: 'yggdra',
        text: '...고마워...',
        nextId: 'ygg_d_3',
      ),
      const DialogueNode(
        id: 'ygg_d_3',
        speakerId: 'player',
        text: '...?',
        nextId: 'ygg_d_4',
      ),
      const DialogueNode(
        id: 'ygg_d_4',
        speakerId: 'yggdra',
        text: '이제... 쉴 수 있어... 더 이상... 기다리지 않아도 돼...',
        nextId: 'ygg_d_5',
      ),
      const DialogueNode(
        id: 'ygg_d_5',
        speakerId: 'yggdra',
        text: '(속삭이듯) ...성채에서... 그가... 기다린다...',
        nextId: 'ygg_d_6',
      ),
      const DialogueNode(
        id: 'ygg_d_6',
        speakerId: 'system',
        text: '이그드라가 빛으로 흩어진다. 남겨진 것은 한 방울의 눈물.',
        nextId: 'ygg_d_7',
      ),
      const DialogueNode(
        id: 'ygg_d_7',
        speakerId: 'system',
        text: '\'이그드라의 눈물\'을 획득했다.',
        nextId: 'ygg_d_8',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'yggdra_tear',
          amount: 1,
        ),
      ),
      const DialogueNode(
        id: 'ygg_d_8',
        speakerId: 'system',
        text: '\'잊혀진 숲의 아르카나\'를 획득했다.',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'arcana_forgotten_grove',
          amount: 1,
        ),
      ),
    ],
  );

  /// === 에필로그 ===
  static final epilogue = DialogueSequence(
    id: 'ch1_epilogue',
    nodes: [
      const DialogueNode(
        id: 'epi_1',
        speakerId: 'system',
        text: '숲의 안개가 걷힌다. 저주가 풀린 것일까, 아니면 잠시 쉬는 것일까.',
        nextId: 'epi_2',
      ),
      const DialogueNode(
        id: 'epi_2',
        speakerId: 'player',
        text: '(성채... 누군가 기다리고 있다고 했다.)',
        nextId: 'epi_3',
      ),
      const DialogueNode(
        id: 'epi_3',
        speakerId: 'system',
        text: '숲 너머로 무너진 성벽이 보인다.',
        nextId: 'epi_4',
      ),
      const DialogueNode(
        id: 'epi_4',
        speakerId: 'unknown',
        text: '(바람에 실려 오는 목소리) ...숲은 기억한다. 네가 무엇을 빼앗았는지.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chapter1_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 스토리 아이템: 부서진 나뭇잎 펜던트 획득 ===
  static final itemPendant = DialogueSequence(
    id: 'ch1_item_pendant',
    nodes: [
      const DialogueNode(
        id: 'item_p_1',
        speakerId: 'player',
        text: '(펜던트를 집어들자, 희미한 빛이 감돈다.)',
        nextId: 'item_p_2',
      ),
      const DialogueNode(
        id: 'item_p_2',
        speakerId: 'system',
        text: '부서진 나뭇잎 모양의 펜던트. 누군가의 소중한 약속이 담겨있던 것 같다.',
        nextId: 'item_p_3',
      ),
      const DialogueNode(
        id: 'item_p_3',
        speakerId: 'player',
        text: '(왜... 이것을 보면 슬픈 기분이 드는 걸까?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_leaf_pendant',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 챕터 1 대화 시퀀스
  static List<DialogueSequence> get all => [
        prologue,
        ashMerchantFirstMeet,
        ashMerchantDefault,
        altarDiscovery,
        hallucination,
        yggdraEncounter,
        yggdraPhase2,
        yggdraDefeat,
        epilogue,
        itemPendant,
      ];
}

/// 이그드라 화자 정보
const yggdraSpeaker = Speaker(
  id: 'yggdra',
  name: '이그드라',
  defaultPortrait: 'portraits/yggdra.png',
);

/// 재의 상인 화자 정보
const ashMerchantSpeaker = Speaker(
  id: 'ash_merchant',
  name: '재의 상인',
  defaultPortrait: 'portraits/ash_merchant.png',
);

/// 알 수 없는 목소리 화자
const unknownSpeaker = Speaker(
  id: 'unknown',
  name: '???',
);
