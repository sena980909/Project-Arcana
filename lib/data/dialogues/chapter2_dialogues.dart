/// Arcana: The Three Hearts - 챕터 2 대화
/// 무너진 성채 (The Crumbling Citadel)
library;

import '../model/dialogue.dart';

/// 챕터 2 대화 시퀀스 모음
class Chapter2Dialogues {
  Chapter2Dialogues._();

  /// === 눈먼 기사 첫 만남 ===
  static final blindKnightFirstMeet = DialogueSequence(
    id: 'blind_knight_first',
    nodes: [
      const DialogueNode(
        id: 'bk_1',
        speakerId: 'blind_knight',
        text: '...발소리가 들린다. 살아있는 자의 발소리.',
        nextId: 'bk_2',
      ),
      const DialogueNode(
        id: 'bk_2',
        speakerId: 'player',
        text: '(녹슨 갑옷의 기사다. 투구 아래... 눈이 없다.)',
        nextId: 'bk_3',
      ),
      const DialogueNode(
        id: 'bk_3',
        speakerId: 'blind_knight',
        text: '이 성채에 올 이유가 있는 자는 둘 중 하나지.',
        nextId: 'bk_4',
      ),
      const DialogueNode(
        id: 'bk_4',
        speakerId: 'blind_knight',
        text: '왕을 구하러 왔거나... 왕을 죽이러 왔거나.',
        nextId: 'bk_5',
      ),
      const DialogueNode(
        id: 'bk_5',
        speakerId: 'blind_knight',
        text: '...어느 쪽이든, 결과는 같아.',
        choices: [
          DialogueChoice(
            text: '왕이 누구죠?',
            nextId: 'bk_about_king',
          ),
          DialogueChoice(
            text: '눈은... 어떻게 된 겁니까?',
            nextId: 'bk_about_eyes',
          ),
          DialogueChoice(
            text: '(묵묵히 지나간다)',
            nextId: null,
          ),
        ],
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_blind_knight',
          flagValue: true,
        ),
      ),
      // 왕에 대해
      const DialogueNode(
        id: 'bk_about_king',
        speakerId: 'blind_knight',
        text: '발두르. 한때는 위대한 왕이었지.',
        nextId: 'bk_about_king_2',
      ),
      const DialogueNode(
        id: 'bk_about_king_2',
        speakerId: 'blind_knight',
        text: '지금은... 사랑이 만들어낸 괴물일 뿐.',
        nextId: 'bk_about_king_3',
      ),
      const DialogueNode(
        id: 'bk_about_king_3',
        speakerId: 'blind_knight',
        text: '탑 정상에서 기다리고 있을 거다. 언제까지고.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'knows_baldur',
          flagValue: true,
        ),
      ),
      // 눈에 대해
      const DialogueNode(
        id: 'bk_about_eyes',
        speakerId: 'blind_knight',
        text: '...내가 찔렀다. 스스로.',
        nextId: 'bk_about_eyes_2',
      ),
      const DialogueNode(
        id: 'bk_about_eyes_2',
        speakerId: 'blind_knight',
        text: '왕이 미쳐가는 것을 보고도 막지 못했으니까.',
        nextId: 'bk_about_eyes_3',
      ),
      const DialogueNode(
        id: 'bk_about_eyes_3',
        speakerId: 'blind_knight',
        text: '다시는 아무것도 보지 않겠다고... 맹세했지.',
        nextId: 'bk_about_eyes_4',
      ),
      const DialogueNode(
        id: 'bk_about_eyes_4',
        speakerId: 'blind_knight',
        text: '(씁쓸하게) 하지만 눈을 감는다고 죄가 사라지지 않더군.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'knows_knight_past',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 눈먼 기사 기본 대화 ===
  static final blindKnightDefault = DialogueSequence(
    id: 'blind_knight_default',
    nodes: [
      const DialogueNode(
        id: 'bk_def_1',
        speakerId: 'blind_knight',
        text: '아직 살아있군. 조심해라. 탑으로 갈수록 왕의 광기가 짙어진다.',
      ),
    ],
  );

  /// === 재의 상인 재등장 (챕터 2) ===
  static final ashMerchantChapter2 = DialogueSequence(
    id: 'ash_merchant_ch2',
    nodes: [
      const DialogueNode(
        id: 'ash_ch2_1',
        speakerId: 'ash_merchant',
        text: '...또 만났군.',
        nextId: 'ash_ch2_2',
      ),
      const DialogueNode(
        id: 'ash_ch2_2',
        speakerId: 'ash_merchant',
        text: '숲의 정령이 해방되었다고 들었어. 네 짓이지?',
        nextId: 'ash_ch2_3',
      ),
      const DialogueNode(
        id: 'ash_ch2_3',
        speakerId: 'player',
        text: '(이그드라를... 기억하는 것 같다)',
        nextId: 'ash_ch2_4',
      ),
      const DialogueNode(
        id: 'ash_ch2_4',
        speakerId: 'ash_merchant',
        text: '...고맙다. 그녀는 오래 기다렸으니까.',
        nextId: 'ash_ch2_5',
      ),
      const DialogueNode(
        id: 'ash_ch2_5',
        speakerId: 'ash_merchant',
        text: '(잠시 침묵) 이 성채도 비슷해. 기다림에 미쳐버린 자가 있지.',
        choices: [
          DialogueChoice(
            text: '펜던트를 보여준다',
            nextId: 'ash_ch2_pendant',
            condition: DialogueCondition(hasItem: 'broken_leaf_pendant'),
          ),
          DialogueChoice(
            text: '물건을 보여주세요.',
            nextId: 'ash_ch2_shop',
            trigger: DialogueTrigger(type: TriggerType.unlockShop),
          ),
          DialogueChoice(
            text: '(떠난다)',
            nextId: null,
          ),
        ],
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_ash_merchant_ch2',
          flagValue: true,
        ),
      ),
      // 펜던트 반응
      const DialogueNode(
        id: 'ash_ch2_pendant',
        speakerId: 'ash_merchant',
        text: '...그건...',
        nextId: 'ash_ch2_pendant_2',
      ),
      const DialogueNode(
        id: 'ash_ch2_pendant_2',
        speakerId: 'ash_merchant',
        text: '(목소리가 떨린다) 어디서 찾았어?',
        nextId: 'ash_ch2_pendant_3',
      ),
      const DialogueNode(
        id: 'ash_ch2_pendant_3',
        speakerId: 'player',
        text: '숲의 제단에서요.',
        nextId: 'ash_ch2_pendant_4',
      ),
      const DialogueNode(
        id: 'ash_ch2_pendant_4',
        speakerId: 'ash_merchant',
        text: '...그렇군. 아직 거기 있었어.',
        nextId: 'ash_ch2_pendant_5',
      ),
      const DialogueNode(
        id: 'ash_ch2_pendant_5',
        speakerId: 'ash_merchant',
        text: '그건... 예전에 내가 누군가에게 준 거야. 약속과 함께.',
        nextId: 'ash_ch2_pendant_6',
      ),
      const DialogueNode(
        id: 'ash_ch2_pendant_6',
        speakerId: 'ash_merchant',
        text: '(길게 한숨) 지키지 못한 약속.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'ash_merchant_pendant_revealed',
          flagValue: true,
        ),
      ),
      // 상점
      const DialogueNode(
        id: 'ash_ch2_shop',
        speakerId: 'ash_merchant',
        text: '이번에도 도움이 될 거야. 아마.',
      ),
    ],
  );

  /// === 왕좌의 방 발견 ===
  static final throneRoomDiscovery = DialogueSequence(
    id: 'ch2_throne_discovery',
    nodes: [
      const DialogueNode(
        id: 'throne_1',
        speakerId: 'system',
        text: '텅 빈 왕좌의 방. 찢어진 태피스트리, 깨진 스테인드글라스.',
        nextId: 'throne_2',
      ),
      const DialogueNode(
        id: 'throne_2',
        speakerId: 'player',
        text: '(왕좌 옆에 무언가 빛나고 있다...)',
        nextId: 'throne_3',
      ),
      const DialogueNode(
        id: 'throne_3',
        speakerId: 'system',
        text: '\'깨진 왕관 조각\'을 발견했다.',
        nextId: 'throne_4',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'broken_crown_shard',
          amount: 1,
        ),
      ),
      const DialogueNode(
        id: 'throne_4',
        speakerId: 'system',
        text: '벽화가 눈에 들어온다. 왕과 왕비가 함께 있는 그림...',
        nextId: 'throne_5',
      ),
      const DialogueNode(
        id: 'throne_5',
        speakerId: 'system',
        text: '왕비의 얼굴 부분만 긁혀 지워져 있다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'throne_room_explored',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 배신의 환각 (Hearts <= 2) ===
  static final betrayalHallucination = DialogueSequence(
    id: 'ch2_betrayal_hallucination',
    nodes: [
      const DialogueNode(
        id: 'betray_1',
        speakerId: 'unknown',
        text: '...믿지 마...',
        nextId: 'betray_2',
      ),
      const DialogueNode(
        id: 'betray_2',
        speakerId: 'player',
        text: '(또 그 목소리다...)',
        nextId: 'betray_3',
      ),
      const DialogueNode(
        id: 'betray_3',
        speakerId: 'unknown',
        text: '네 친구도... 널 버릴 거야...',
        nextId: 'betray_4',
      ),
      const DialogueNode(
        id: 'betray_4',
        speakerId: 'unknown',
        text: '모두가... 결국엔... 떠나니까...',
        nextId: 'betray_5',
      ),
      const DialogueNode(
        id: 'betray_5',
        speakerId: 'player',
        text: '(가슴이 아프다... 이건 내 기억인가?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'heard_betrayal_hallucination',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 왕비의 환영 (Hearts == 1일 때만) ===
  static final queenGhostEncounter = DialogueSequence(
    id: 'ch2_queen_ghost',
    nodes: [
      const DialogueNode(
        id: 'queen_1',
        speakerId: 'system',
        text: '희미한 빛이 나타난다. 아름다운 여인의 형상...',
        nextId: 'queen_2',
      ),
      const DialogueNode(
        id: 'queen_2',
        speakerId: 'queen_ghost',
        text: '...당신이군요.',
        nextId: 'queen_3',
      ),
      const DialogueNode(
        id: 'queen_3',
        speakerId: 'player',
        text: '(나를... 아는 것 같다?)',
        nextId: 'queen_4',
      ),
      const DialogueNode(
        id: 'queen_4',
        speakerId: 'queen_ghost',
        text: '당신도 누군가를 사랑했나요?',
        nextId: 'queen_5',
      ),
      const DialogueNode(
        id: 'queen_5',
        speakerId: 'queen_ghost',
        text: '...기억나지 않는 거죠.',
        nextId: 'queen_6',
      ),
      const DialogueNode(
        id: 'queen_6',
        speakerId: 'queen_ghost',
        text: '잊혀진다는 건... 죽는 것보다 아픈 일이에요.',
        nextId: 'queen_7',
      ),
      const DialogueNode(
        id: 'queen_7',
        speakerId: 'queen_ghost',
        text: '(미소 짓듯) 하지만 당신은... 기억할 수 있을 거예요.',
        nextId: 'queen_8',
      ),
      const DialogueNode(
        id: 'queen_8',
        speakerId: 'system',
        text: '환영이 빛으로 흩어진다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_queen_ghost',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 발두르 보스 조우 ===
  static final baldurEncounter = DialogueSequence(
    id: 'ch2_baldur_encounter',
    nodes: [
      const DialogueNode(
        id: 'bald_1',
        speakerId: 'system',
        text: '탑 정상. 금지된 제단 앞에 한 남자가 서 있다.',
        nextId: 'bald_2',
      ),
      const DialogueNode(
        id: 'bald_2',
        speakerId: 'system',
        text: '반쯤 부패한 시체. 왕관이 살점에 박혀있다. 검은 눈물이 흐른다.',
        nextId: 'bald_3',
      ),
      const DialogueNode(
        id: 'bald_3',
        speakerId: 'baldur',
        text: '또 왔군. 영웅인 척하는 자가.',
        nextId: 'bald_4',
      ),
      const DialogueNode(
        id: 'bald_4',
        speakerId: 'baldur',
        text: '내가 뭘 했는지 아나?',
        nextId: 'bald_5',
      ),
      const DialogueNode(
        id: 'bald_5',
        speakerId: 'baldur',
        text: '...사랑했다. 그게 전부야.',
        nextId: 'bald_6',
      ),
      const DialogueNode(
        id: 'bald_6',
        speakerId: 'baldur',
        text: '세상이 그녀를 빼앗아 갔어. 그래서 세상을 멈췄지.',
        nextId: 'bald_7',
      ),
      const DialogueNode(
        id: 'bald_7',
        speakerId: 'baldur',
        text: '넌 이해 못 해. 아직 기억하지 못하니까.',
        nextId: 'bald_8',
      ),
      const DialogueNode(
        id: 'bald_8',
        speakerId: 'baldur',
        text: '하지만 언젠가... 넌 나와 같은 선택을 하게 될 거다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'baldur_encounter_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 발두르 Phase 2 전환 ===
  static final baldurPhase2 = DialogueSequence(
    id: 'ch2_baldur_phase2',
    nodes: [
      const DialogueNode(
        id: 'bald_p2_1',
        speakerId: 'baldur',
        text: '...아직도 저항하는 거냐?',
        nextId: 'bald_p2_2',
      ),
      const DialogueNode(
        id: 'bald_p2_2',
        speakerId: 'baldur',
        text: '좋아... 보여주지.',
        nextId: 'bald_p2_3',
      ),
      const DialogueNode(
        id: 'bald_p2_3',
        speakerId: 'baldur',
        text: '사랑이 광기가 될 때 무슨 일이 일어나는지!',
      ),
    ],
  );

  /// === 발두르 Phase 3 전환 ===
  static final baldurPhase3 = DialogueSequence(
    id: 'ch2_baldur_phase3',
    nodes: [
      const DialogueNode(
        id: 'bald_p3_1',
        speakerId: 'baldur',
        text: '...왜... 왜 날 막는 거야...',
        nextId: 'bald_p3_2',
      ),
      const DialogueNode(
        id: 'bald_p3_2',
        speakerId: 'baldur',
        text: '난 그저... 그녀를 다시 보고 싶었을 뿐인데...',
        nextId: 'bald_p3_3',
      ),
      const DialogueNode(
        id: 'bald_p3_3',
        speakerId: 'baldur',
        text: '(절규하며) 제발... 제발 그녀를 돌려줘!!!',
      ),
    ],
  );

  /// === 발두르 처치 ===
  static final baldurDefeat = DialogueSequence(
    id: 'ch2_baldur_defeat',
    nodes: [
      const DialogueNode(
        id: 'bald_d_1',
        speakerId: 'system',
        text: '발두르가 무릎을 꿇는다. 광기가 빠져나가고, 슬픔만이 남는다.',
        nextId: 'bald_d_2',
      ),
      const DialogueNode(
        id: 'bald_d_2',
        speakerId: 'baldur',
        text: '...고맙다...',
        nextId: 'bald_d_3',
      ),
      const DialogueNode(
        id: 'bald_d_3',
        speakerId: 'baldur',
        text: '드디어... 그녀에게 갈 수 있겠군...',
        nextId: 'bald_d_4',
      ),
      const DialogueNode(
        id: 'bald_d_4',
        speakerId: 'baldur',
        text: '하지만 넌... 조심해...',
        nextId: 'bald_d_5',
      ),
      const DialogueNode(
        id: 'bald_d_5',
        speakerId: 'baldur',
        text: '네가 지키려는 것이... 널 파멸시킬 거다...',
        nextId: 'bald_d_6',
      ),
      const DialogueNode(
        id: 'bald_d_6',
        speakerId: 'baldur',
        text: '...나처럼...',
        nextId: 'bald_d_7',
      ),
      const DialogueNode(
        id: 'bald_d_7',
        speakerId: 'system',
        text: '발두르가 재로 흩어진다. 검은 눈물이 결정이 되어 떨어진다.',
        nextId: 'bald_d_8',
      ),
      const DialogueNode(
        id: 'bald_d_8',
        speakerId: 'system',
        text: '\'발두르의 눈물\'을 획득했다.',
        nextId: 'bald_d_9',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'baldur_tear',
          amount: 1,
        ),
      ),
      const DialogueNode(
        id: 'bald_d_9',
        speakerId: 'system',
        text: '\'무너진 성채의 아르카나\'를 획득했다.',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'arcana_crumbling_citadel',
          amount: 1,
        ),
      ),
    ],
  );

  /// === 에필로그 ===
  static final epilogue = DialogueSequence(
    id: 'ch2_epilogue',
    nodes: [
      const DialogueNode(
        id: 'epi_1',
        speakerId: 'system',
        text: '성채에 정적이 내린다. 저주의 안개가 걷힌다.',
        nextId: 'epi_2',
      ),
      const DialogueNode(
        id: 'epi_2',
        speakerId: 'player',
        text: '(발두르가 말했다. 나와 같다고...)',
        nextId: 'epi_3',
      ),
      const DialogueNode(
        id: 'epi_3',
        speakerId: 'player',
        text: '(내가... 무언가를 지키려다 잃었다는 건가?)',
        nextId: 'epi_4',
      ),
      const DialogueNode(
        id: 'epi_4',
        speakerId: 'system',
        text: '멀리 종소리가 들린다. 성채 너머 산 위에서.',
        nextId: 'epi_5',
      ),
      const DialogueNode(
        id: 'epi_5',
        speakerId: 'unknown',
        text: '(바람에 실려 오는 속삭임) ...죄를 고백하라... 침묵의 성당에서...',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chapter2_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 스토리 아이템: 깨진 왕관 조각 획득 ===
  static final itemCrown = DialogueSequence(
    id: 'ch2_item_crown',
    nodes: [
      const DialogueNode(
        id: 'item_c_1',
        speakerId: 'player',
        text: '(손에 들자 차가운 금속의 감촉이 전해진다.)',
        nextId: 'item_c_2',
      ),
      const DialogueNode(
        id: 'item_c_2',
        speakerId: 'system',
        text: '깨진 왕관 조각. 검은 얼룩이 묻어있다. 피... 아니면 눈물인가.',
        nextId: 'item_c_3',
      ),
      const DialogueNode(
        id: 'item_c_3',
        speakerId: 'player',
        text: '(이 왕관의 주인은... 무엇을 잃었을까?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_crown_shard',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 챕터 2 대화 시퀀스
  static List<DialogueSequence> get all => [
        blindKnightFirstMeet,
        blindKnightDefault,
        ashMerchantChapter2,
        throneRoomDiscovery,
        betrayalHallucination,
        queenGhostEncounter,
        baldurEncounter,
        baldurPhase2,
        baldurPhase3,
        baldurDefeat,
        epilogue,
        itemCrown,
      ];
}

/// 발두르 화자 정보
const baldurSpeaker = Speaker(
  id: 'baldur',
  name: '발두르',
  defaultPortrait: 'portraits/baldur.png',
);

/// 눈먼 기사 화자 정보
const blindKnightSpeaker = Speaker(
  id: 'blind_knight',
  name: '눈먼 기사',
  defaultPortrait: 'portraits/blind_knight.png',
);

/// 왕비의 환영 화자 정보
const queenGhostSpeaker = Speaker(
  id: 'queen_ghost',
  name: '???',
  defaultPortrait: 'portraits/queen_ghost.png',
);
