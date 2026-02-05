/// Arcana: The Three Hearts - 챕터 5 대화
/// 기억의 심연 (The Abyss of Memory)
library;

import '../model/dialogue.dart';

/// 챕터 5 대화 시퀀스 모음
class Chapter5Dialogues {
  Chapter5Dialogues._();

  /// === 심연의 입구 ===
  static final abyssEntrance = DialogueSequence(
    id: 'ch5_abyss_entrance',
    nodes: [
      const DialogueNode(
        id: 'ent_1',
        speakerId: 'system',
        text: '리리아나의 머리핀이 희미하게 빛난다.',
        nextId: 'ent_2',
      ),
      const DialogueNode(
        id: 'ent_2',
        speakerId: 'player',
        text: '(이 빛이... 나를 인도하고 있다.)',
        nextId: 'ent_3',
      ),
      const DialogueNode(
        id: 'ent_3',
        speakerId: 'system',
        text: '끝없이 깊어 보이는 어둠. 푸른 빛이 심연 속에서 맥동한다.',
        nextId: 'ent_4',
      ),
      const DialogueNode(
        id: 'ent_4',
        speakerId: 'unknown',
        text: '...여기까지 왔구나.',
        nextId: 'ent_5',
      ),
      const DialogueNode(
        id: 'ent_5',
        speakerId: 'unknown',
        text: '진실을 마주할 준비가 됐어?',
        nextId: 'ent_6',
      ),
      const DialogueNode(
        id: 'ent_6',
        speakerId: 'player',
        text: '(그 목소리... 계속 나를 인도해온 그 목소리다.)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'entered_abyss',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 기억의 회랑 - 떠다니는 기억들 ===
  static final memoryCorridor = DialogueSequence(
    id: 'ch5_memory_corridor',
    nodes: [
      const DialogueNode(
        id: 'corr_1',
        speakerId: 'system',
        text: '기억의 파편들이 공중에 떠다닌다. 희미한 영상들.',
        nextId: 'corr_2',
      ),
      const DialogueNode(
        id: 'corr_2',
        speakerId: 'system',
        text: '어린 시절의 나... 부모 없이 자란 고아원...',
        nextId: 'corr_3',
      ),
      const DialogueNode(
        id: 'corr_3',
        speakerId: 'system',
        text: '검을 잡은 날... "그녀의 기사가 되겠다"는 다짐...',
        nextId: 'corr_4',
      ),
      const DialogueNode(
        id: 'corr_4',
        speakerId: 'system',
        text: '분홍빛 정원... 함께 춤추던 두 사람의 그림자...',
        nextId: 'corr_5',
      ),
      const DialogueNode(
        id: 'corr_5',
        speakerId: 'player',
        text: '(이건... 나의 기억...?)',
        nextId: 'corr_6',
      ),
      const DialogueNode(
        id: 'corr_6',
        speakerId: 'system',
        text: '그리고 마지막... 비 오는 밤. 검을 드는 손. 붉게 물든 장미.',
        nextId: 'corr_7',
      ),
      const DialogueNode(
        id: 'corr_7',
        speakerId: 'player',
        text: '...!',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'saw_memory_corridor',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 거울의 방 - 과거의 나 ===
  static final mirrorRoomPastSelf = DialogueSequence(
    id: 'ch5_mirror_room',
    nodes: [
      const DialogueNode(
        id: 'mir_1',
        speakerId: 'system',
        text: '사방이 거울로 둘러싸인 방. 무수한 자신의 모습이 비친다.',
        nextId: 'mir_2',
      ),
      const DialogueNode(
        id: 'mir_2',
        speakerId: 'system',
        text: '거울 속에서... 누군가 걸어 나온다.',
        nextId: 'mir_3',
      ),
      const DialogueNode(
        id: 'mir_3',
        speakerId: 'past_self',
        text: '오랜만이야.',
        nextId: 'mir_4',
      ),
      const DialogueNode(
        id: 'mir_4',
        speakerId: 'player',
        text: '(나와 똑같은 얼굴... 하지만 눈에 생기가 있다.)',
        nextId: 'mir_5',
      ),
      const DialogueNode(
        id: 'mir_5',
        speakerId: 'past_self',
        text: '...아니, 처음 보는 건가? 넌 나를 잊었으니까.',
        nextId: 'mir_6',
      ),
      const DialogueNode(
        id: 'mir_6',
        speakerId: 'past_self',
        text: '난 네가 기억하지 못하는 "나"야.',
        nextId: 'mir_7',
      ),
      const DialogueNode(
        id: 'mir_7',
        speakerId: 'past_self',
        text: '아리온.',
        nextId: 'mir_8',
      ),
      const DialogueNode(
        id: 'mir_8',
        speakerId: 'player',
        text: '아리온...?',
        nextId: 'mir_9',
      ),
      const DialogueNode(
        id: 'mir_9',
        speakerId: 'past_self',
        text: '그게 우리 이름이야. 기억나?',
        nextId: 'mir_10',
      ),
      const DialogueNode(
        id: 'mir_10',
        speakerId: 'past_self',
        text: '리리아나가 지어준 이름이야. "빛나는 자"라는 뜻이래.',
        nextId: 'mir_11',
      ),
      const DialogueNode(
        id: 'mir_11',
        speakerId: 'past_self',
        text: '(씁쓸하게 웃으며) 웃기지? 빛나는 자가 어둠 속에서 헤매고 있으니.',
        nextId: 'mir_12',
      ),
      const DialogueNode(
        id: 'mir_12',
        speakerId: 'player',
        text: '...난 왜 그녀를 죽였어?',
        nextId: 'mir_13',
      ),
      const DialogueNode(
        id: 'mir_13',
        speakerId: 'past_self',
        text: '(잠시 침묵) ...그건 다음 방에서 알게 될 거야.',
        nextId: 'mir_14',
      ),
      const DialogueNode(
        id: 'mir_14',
        speakerId: 'past_self',
        text: '하지만 기억해. 넌 다시 빛날 수 있어.',
        nextId: 'mir_15',
      ),
      const DialogueNode(
        id: 'mir_15',
        speakerId: 'past_self',
        text: '그녀를 구하면.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'learned_true_name',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 선택의 방 - 그날의 재현 ===
  static final choiceRoom = DialogueSequence(
    id: 'ch5_choice_room',
    nodes: [
      const DialogueNode(
        id: 'cho_1',
        speakerId: 'system',
        text: '어둠 속에서 장면이 펼쳐진다. 비 오는 밤.',
        nextId: 'cho_2',
      ),
      const DialogueNode(
        id: 'cho_2',
        speakerId: 'system',
        text: '리리아나가 서 있다. 하지만... 그녀의 몸이 검게 물들어가고 있다.',
        nextId: 'cho_3',
      ),
      const DialogueNode(
        id: 'cho_3',
        speakerId: 'memory_liliana',
        text: '아리온... 더 이상 시간이 없어.',
        nextId: 'cho_4',
      ),
      const DialogueNode(
        id: 'cho_4',
        speakerId: 'memory_liliana',
        text: '저주가... 나를 삼키고 있어. 곧 나는... 괴물이 될 거야.',
        nextId: 'cho_5',
      ),
      const DialogueNode(
        id: 'cho_5',
        speakerId: 'player',
        text: '(이건... 그날의 기억...!)',
        nextId: 'cho_6',
      ),
      const DialogueNode(
        id: 'cho_6',
        speakerId: 'memory_liliana',
        text: '이 저주가 완성되면... 세계가 끝나. 모든 것이.',
        nextId: 'cho_7',
      ),
      const DialogueNode(
        id: 'cho_7',
        speakerId: 'memory_liliana',
        text: '(검을 건네며) ...날 죽여줘.',
        nextId: 'cho_8',
      ),
      const DialogueNode(
        id: 'cho_8',
        speakerId: 'memory_arion',
        text: '안 돼! 다른 방법이 있을 거야!',
        nextId: 'cho_9',
      ),
      const DialogueNode(
        id: 'cho_9',
        speakerId: 'memory_liliana',
        text: '(미소 지으며) 없어. 우린 이미 모든 방법을 찾아봤잖아.',
        nextId: 'cho_10',
      ),
      const DialogueNode(
        id: 'cho_10',
        speakerId: 'memory_liliana',
        text: '제발... 내가 괴물이 되기 전에. 아직 내가 "나"일 때.',
        nextId: 'cho_11',
      ),
      const DialogueNode(
        id: 'cho_11',
        speakerId: 'memory_liliana',
        text: '널 사랑하는 내가... 널 죽이게 하지 마.',
        nextId: 'cho_12',
        choices: [
          DialogueChoice(
            text: '[검을 든다]',
            nextId: 'cho_take_sword',
          ),
          DialogueChoice(
            text: '[검을 들지 않는다]',
            nextId: 'cho_refuse_sword',
          ),
        ],
      ),
      // 검을 드는 경우
      const DialogueNode(
        id: 'cho_take_sword',
        speakerId: 'system',
        text: '떨리는 손으로 검을 든다.',
        nextId: 'cho_final',
      ),
      // 검을 들지 않는 경우
      const DialogueNode(
        id: 'cho_refuse_sword',
        speakerId: 'memory_liliana',
        text: '(슬프게 웃으며) ...그래도 결국, 넌 들게 될 거야.',
        nextId: 'cho_refuse_2',
      ),
      const DialogueNode(
        id: 'cho_refuse_2',
        speakerId: 'system',
        text: '리리아나의 몸이 더 빠르게 검어진다. 비명을 삼키며 그녀가 쓰러진다.',
        nextId: 'cho_refuse_3',
      ),
      const DialogueNode(
        id: 'cho_refuse_3',
        speakerId: 'system',
        text: '결국... 검을 들 수밖에 없었다.',
        nextId: 'cho_final',
      ),
      // 공통 결말
      const DialogueNode(
        id: 'cho_final',
        speakerId: 'memory_liliana',
        text: '(눈을 감으며) 고마워... 사랑해...',
        nextId: 'cho_final_2',
      ),
      const DialogueNode(
        id: 'cho_final_2',
        speakerId: 'system',
        text: '검이... 내려간다.',
        nextId: 'cho_final_3',
      ),
      const DialogueNode(
        id: 'cho_final_3',
        speakerId: 'system',
        text: '화면이 암전된다. 비명이 들린다. 나의 비명이.',
        nextId: 'cho_final_4',
      ),
      const DialogueNode(
        id: 'cho_final_4',
        speakerId: 'player',
        text: '...아아아아아아!!!',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'relived_that_day',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 진실의 방 - ??? 정체 공개 ===
  static final truthRoom = DialogueSequence(
    id: 'ch5_truth_room',
    nodes: [
      const DialogueNode(
        id: 'tru_1',
        speakerId: 'system',
        text: '하얀 공간. 중앙에 빛나는 문이 있다.',
        nextId: 'tru_2',
      ),
      const DialogueNode(
        id: 'tru_2',
        speakerId: 'system',
        text: '문 앞에 후드를 쓴 형체가 서 있다. 계속 나를 인도해온 그 목소리의 주인.',
        nextId: 'tru_3',
      ),
      const DialogueNode(
        id: 'tru_3',
        speakerId: 'unknown',
        text: '...드디어 여기까지 왔구나.',
        nextId: 'tru_4',
      ),
      const DialogueNode(
        id: 'tru_4',
        speakerId: 'system',
        text: '그가 후드를 벗는다.',
        nextId: 'tru_5',
      ),
      const DialogueNode(
        id: 'tru_5',
        speakerId: 'player',
        text: '...!!',
        nextId: 'tru_6',
      ),
      const DialogueNode(
        id: 'tru_6',
        speakerId: 'system',
        text: '나와 똑같은 얼굴. 하지만 더 늙고, 더 지쳐있다. 눈에 깊은 후회가 서려 있다.',
        nextId: 'tru_7',
      ),
      const DialogueNode(
        id: 'tru_7',
        speakerId: 'future_self',
        text: '난 "아리온"이야.',
        nextId: 'tru_8',
      ),
      const DialogueNode(
        id: 'tru_8',
        speakerId: 'future_self',
        text: '네가 될 뻔한.',
        nextId: 'tru_9',
      ),
      const DialogueNode(
        id: 'tru_9',
        speakerId: 'player',
        text: '네가... 될 뻔한...?',
        nextId: 'tru_10',
      ),
      const DialogueNode(
        id: 'tru_10',
        speakerId: 'future_self',
        text: '다른 시간선에서 온 나야. 리리아나를 구하지 못한 나.',
        nextId: 'tru_11',
      ),
      const DialogueNode(
        id: 'tru_11',
        speakerId: 'future_self',
        text: '세 개의 심장을 모으지 못했어. 그래서 실패했지.',
        nextId: 'tru_12',
      ),
      const DialogueNode(
        id: 'tru_12',
        speakerId: 'future_self',
        text: '하지만 넌 다를 수 있어.',
        nextId: 'tru_13',
      ),
      const DialogueNode(
        id: 'tru_13',
        speakerId: 'future_self',
        text: '내가 여기서 널 인도한 건... 같은 실수를 막기 위해서야.',
        nextId: 'tru_14',
      ),
      const DialogueNode(
        id: 'tru_14',
        speakerId: 'player',
        text: '리리아나를... 구할 수 있다는 거야?',
        nextId: 'tru_15',
      ),
      const DialogueNode(
        id: 'tru_15',
        speakerId: 'future_self',
        text: '그녀는 "망각의 옥좌"에 있어.',
        nextId: 'tru_16',
      ),
      const DialogueNode(
        id: 'tru_16',
        speakerId: 'future_self',
        text: '세계가 그녀를 잊음으로써 봉인한 곳.',
        nextId: 'tru_17',
      ),
      const DialogueNode(
        id: 'tru_17',
        speakerId: 'future_self',
        text: '세 개의 심장으로 봉인을 풀 수 있어.',
        nextId: 'tru_18',
      ),
      const DialogueNode(
        id: 'tru_18',
        speakerId: 'player',
        text: '세 개의 심장...?',
        nextId: 'tru_19',
      ),
      const DialogueNode(
        id: 'tru_19',
        speakerId: 'future_self',
        text: '첫 번째는 과거의 심장. 리리아나와의 추억. 넌 이미 기억을 되찾았어.',
        nextId: 'tru_20',
      ),
      const DialogueNode(
        id: 'tru_20',
        speakerId: 'future_self',
        text: '두 번째는 현재의 심장. 지금의 너 자신을 받아들여야 해.',
        nextId: 'tru_21',
      ),
      const DialogueNode(
        id: 'tru_21',
        speakerId: 'future_self',
        text: '세 번째는 미래의 심장. 그녀를 구하겠다는 의지. 망각의 옥좌에서 증명해야 해.',
        nextId: 'tru_22',
      ),
      const DialogueNode(
        id: 'tru_22',
        speakerId: 'future_self',
        text: '하지만... 대가가 있어.',
        nextId: 'tru_23',
      ),
      const DialogueNode(
        id: 'tru_23',
        speakerId: 'future_self',
        text: '세계가 무언가를 잊어야 해. 그녀 대신.',
        nextId: 'tru_24',
      ),
      const DialogueNode(
        id: 'tru_24',
        speakerId: 'future_self',
        text: '...난 나 자신을 대가로 바쳤지만, 부족했어.',
        nextId: 'tru_25',
      ),
      const DialogueNode(
        id: 'tru_25',
        speakerId: 'future_self',
        text: '넌 더 나은 방법을 찾아. 반드시.',
        nextId: 'tru_26',
      ),
      const DialogueNode(
        id: 'tru_26',
        speakerId: 'player',
        text: '...알겠어.',
        nextId: 'tru_27',
      ),
      const DialogueNode(
        id: 'tru_27',
        speakerId: 'future_self',
        text: '하지만 그 전에... 너 자신과 마주해야 해.',
        nextId: 'tru_28',
      ),
      const DialogueNode(
        id: 'tru_28',
        speakerId: 'future_self',
        text: '심연의 핵심에서. 네가 부정해온 너와.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'truth_revealed',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 그림자 자아 조우 ===
  static final shadowEncounter = DialogueSequence(
    id: 'ch5_shadow_encounter',
    nodes: [
      const DialogueNode(
        id: 'sha_1',
        speakerId: 'system',
        text: '완전한 어둠. 자신의 그림자만이 보인다.',
        nextId: 'sha_2',
      ),
      const DialogueNode(
        id: 'sha_2',
        speakerId: 'system',
        text: '그림자가... 움직인다. 분리된다.',
        nextId: 'sha_3',
      ),
      const DialogueNode(
        id: 'sha_3',
        speakerId: 'shadow_self',
        text: '또 왔어. 또 도망치려고?',
        nextId: 'sha_4',
      ),
      const DialogueNode(
        id: 'sha_4',
        speakerId: 'player',
        text: '넌... 누구야?',
        nextId: 'sha_5',
      ),
      const DialogueNode(
        id: 'sha_5',
        speakerId: 'shadow_self',
        text: '(비웃음) 뻔히 알면서.',
        nextId: 'sha_6',
      ),
      const DialogueNode(
        id: 'sha_6',
        speakerId: 'shadow_self',
        text: '난 네가 인정하지 않는 너야.',
        nextId: 'sha_7',
      ),
      const DialogueNode(
        id: 'sha_7',
        speakerId: 'shadow_self',
        text: '살인자. 배신자. 겁쟁이.',
        nextId: 'sha_8',
      ),
      const DialogueNode(
        id: 'sha_8',
        speakerId: 'shadow_self',
        text: '리리아나를 죽인 손. 그게 바로 너야.',
        nextId: 'sha_9',
      ),
      const DialogueNode(
        id: 'sha_9',
        speakerId: 'player',
        text: '...그건...',
        nextId: 'sha_10',
      ),
      const DialogueNode(
        id: 'sha_10',
        speakerId: 'shadow_self',
        text: '그녀가 부탁했다고? 어쩔 수 없었다고?',
        nextId: 'sha_11',
      ),
      const DialogueNode(
        id: 'sha_11',
        speakerId: 'shadow_self',
        text: '(조롱하듯) 그런 변명은 여기서 통하지 않아.',
        nextId: 'sha_12',
      ),
      const DialogueNode(
        id: 'sha_12',
        speakerId: 'shadow_self',
        text: '자, 싸우자. 아리온.',
        nextId: 'sha_13',
      ),
      const DialogueNode(
        id: 'sha_13',
        speakerId: 'shadow_self',
        text: '네가 진짜 빛날 수 있는지... 증명해봐.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'shadow_encounter_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 그림자 자아 Phase 2 ===
  static final shadowPhase2 = DialogueSequence(
    id: 'ch5_shadow_phase2',
    nodes: [
      const DialogueNode(
        id: 'shp2_1',
        speakerId: 'shadow_self',
        text: '인정해!',
        nextId: 'shp2_2',
      ),
      const DialogueNode(
        id: 'shp2_2',
        speakerId: 'shadow_self',
        text: '넌 그녀를 죽이고 "싶었어"!',
        nextId: 'shp2_3',
      ),
      const DialogueNode(
        id: 'shp2_3',
        speakerId: 'shadow_self',
        text: '저주 때문이 아니야. 네가 약해서 죽인 거야!',
        nextId: 'shp2_4',
      ),
      const DialogueNode(
        id: 'shp2_4',
        speakerId: 'shadow_self',
        text: '구한다고? 웃기지 마.',
        nextId: 'shp2_5',
      ),
      const DialogueNode(
        id: 'shp2_5',
        speakerId: 'shadow_self',
        text: '또 죽일 거잖아.',
        nextId: 'shp2_6',
      ),
      const DialogueNode(
        id: 'shp2_6',
        speakerId: 'shadow_self',
        text: '넌 절대 빛날 수 없어. 어둠이 네 본질이니까!',
      ),
    ],
  );

  /// === 그림자 자아 Phase 3 ===
  static final shadowPhase3 = DialogueSequence(
    id: 'ch5_shadow_phase3',
    nodes: [
      const DialogueNode(
        id: 'shp3_1',
        speakerId: 'shadow_self',
        text: '...왜 계속 싸워?',
        nextId: 'shp3_2',
      ),
      const DialogueNode(
        id: 'shp3_2',
        speakerId: 'shadow_self',
        text: '날 죽여봤자... 넌 완전해지지 않아.',
        nextId: 'shp3_3',
      ),
      const DialogueNode(
        id: 'shp3_3',
        speakerId: 'shadow_self',
        text: '난... 네 일부야.',
        nextId: 'shp3_4',
      ),
      const DialogueNode(
        id: 'shp3_4',
        speakerId: 'shadow_self',
        text: '네 슬픔. 네 죄책감. 네 자기혐오.',
        nextId: 'shp3_5',
      ),
      const DialogueNode(
        id: 'shp3_5',
        speakerId: 'shadow_self',
        text: '날 죽이지 마... 받아들여.',
        nextId: 'shp3_6',
      ),
      const DialogueNode(
        id: 'shp3_6',
        speakerId: 'shadow_self',
        text: '...그래야 진짜 리리아나를 구할 수 있어.',
      ),
    ],
  );

  /// === 그림자 통합 (접근 시) ===
  static final shadowIntegration = DialogueSequence(
    id: 'ch5_shadow_integration',
    nodes: [
      const DialogueNode(
        id: 'int_1',
        speakerId: 'player',
        text: '...알았어.',
        nextId: 'int_2',
      ),
      const DialogueNode(
        id: 'int_2',
        speakerId: 'player',
        text: '넌 나야.',
        nextId: 'int_3',
      ),
      const DialogueNode(
        id: 'int_3',
        speakerId: 'player',
        text: '살인자인 나. 겁쟁이인 나. 약한 나.',
        nextId: 'int_4',
      ),
      const DialogueNode(
        id: 'int_4',
        speakerId: 'shadow_self',
        text: '...',
        nextId: 'int_5',
      ),
      const DialogueNode(
        id: 'int_5',
        speakerId: 'player',
        text: '하지만 그래도... 리리아나를 사랑했던 나.',
        nextId: 'int_6',
      ),
      const DialogueNode(
        id: 'int_6',
        speakerId: 'system',
        text: '그림자가 주인공과 하나가 된다.',
        nextId: 'int_7',
      ),
      const DialogueNode(
        id: 'int_7',
        speakerId: 'system',
        text: '어둠이 빛으로 변한다. 가슴 속에서 따뜻함이 퍼져나간다.',
        nextId: 'int_8',
      ),
      const DialogueNode(
        id: 'int_8',
        speakerId: 'player',
        text: '이제 알겠어. 세 개의 심장.',
        nextId: 'int_9',
      ),
      const DialogueNode(
        id: 'int_9',
        speakerId: 'player',
        text: '과거를 기억하는 심장.',
        nextId: 'int_10',
      ),
      const DialogueNode(
        id: 'int_10',
        speakerId: 'player',
        text: '현재를 받아들이는 심장.',
        nextId: 'int_11',
      ),
      const DialogueNode(
        id: 'int_11',
        speakerId: 'player',
        text: '그리고... 미래를 선택하는 심장.',
        nextId: 'int_12',
      ),
      const DialogueNode(
        id: 'int_12',
        speakerId: 'system',
        text: '"현재의 심장"을 획득했다.',
        nextId: 'int_13',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'heart_of_present',
          amount: 1,
        ),
      ),
      const DialogueNode(
        id: 'int_13',
        speakerId: 'system',
        text: '심장이 하나 회복되었다.',
        nextId: 'int_14',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'heart_restored_ch5',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'int_14',
        speakerId: 'system',
        text: '두 개의 심장이 완성되었다. 마지막 심장을 찾아야 한다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'has_heart_of_present',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 미래의 자신과의 작별 ===
  static final futureSelfFarewell = DialogueSequence(
    id: 'ch5_future_farewell',
    nodes: [
      const DialogueNode(
        id: 'far_1',
        speakerId: 'future_self',
        text: '잘했어.',
        nextId: 'far_2',
      ),
      const DialogueNode(
        id: 'far_2',
        speakerId: 'future_self',
        text: '이제 갈 수 있어.',
        nextId: 'far_3',
      ),
      const DialogueNode(
        id: 'far_3',
        speakerId: 'future_self',
        text: '망각의 옥좌로. 리리아나에게로.',
        nextId: 'far_4',
      ),
      const DialogueNode(
        id: 'far_4',
        speakerId: 'player',
        text: '고마워. 네 덕분에 여기까지 올 수 있었어.',
        nextId: 'far_5',
      ),
      const DialogueNode(
        id: 'far_5',
        speakerId: 'future_self',
        text: '(희미하게 웃으며) 감사는 필요 없어.',
        nextId: 'far_6',
      ),
      const DialogueNode(
        id: 'far_6',
        speakerId: 'future_self',
        text: '결국, 널 도운 건 나 자신을 돕는 거니까.',
        nextId: 'far_7',
      ),
      const DialogueNode(
        id: 'far_7',
        speakerId: 'system',
        text: '그가 빛으로 흩어지기 시작한다.',
        nextId: 'far_8',
      ),
      const DialogueNode(
        id: 'far_8',
        speakerId: 'future_self',
        text: '(속삭이듯) ...다음 생에서는, 그녀와 행복하길.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'future_self_farewell',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 에필로그 ===
  static final epilogue = DialogueSequence(
    id: 'ch5_epilogue',
    nodes: [
      const DialogueNode(
        id: 'epi_1',
        speakerId: 'system',
        text: '심연의 어둠이 걷힌다. 저 멀리, 거대한 옥좌가 보인다.',
        nextId: 'epi_2',
      ),
      const DialogueNode(
        id: 'epi_2',
        speakerId: 'system',
        text: '세계의 끝. 망각의 옥좌.',
        nextId: 'epi_3',
      ),
      const DialogueNode(
        id: 'epi_3',
        speakerId: 'player',
        text: '가자.',
        nextId: 'epi_4',
      ),
      const DialogueNode(
        id: 'epi_4',
        speakerId: 'player',
        text: '이번엔 진짜로 구하러.',
        nextId: 'epi_5',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chapter5_complete',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'epi_5',
        speakerId: 'system',
        text: '기억의 파편들이 하나로 합쳐진다.',
        nextId: 'epi_6',
      ),
      const DialogueNode(
        id: 'epi_6',
        speakerId: 'system',
        text: '모든 기억의 결정이 완성되었다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'has_all_memory_crystals',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 환각 이벤트 (Hearts <= 2) ===
  static final hallucination = DialogueSequence(
    id: 'ch5_hallucination',
    nodes: [
      const DialogueNode(
        id: 'hal_1',
        speakerId: 'shadow_self',
        text: '...못 할 거야.',
        nextId: 'hal_2',
      ),
      const DialogueNode(
        id: 'hal_2',
        speakerId: 'player',
        text: '(어디서 목소리가...)',
        nextId: 'hal_3',
      ),
      const DialogueNode(
        id: 'hal_3',
        speakerId: 'shadow_self',
        text: '넌 이미 실패했어. 기억나지? 그녀를 죽였잖아.',
        nextId: 'hal_4',
      ),
      const DialogueNode(
        id: 'hal_4',
        speakerId: 'shadow_self',
        text: '또 같은 짓을 하게 될 거야.',
        nextId: 'hal_5',
      ),
      const DialogueNode(
        id: 'hal_5',
        speakerId: 'shadow_self',
        text: '영원히. 영원히. 영원히.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'ch5_hallucination_seen',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 숨겨진 아이템: 첫 번째 기억의 결정 (트루 엔딩 필수) ===
  static final hiddenCrystal = DialogueSequence(
    id: 'ch5_hidden_crystal',
    nodes: [
      const DialogueNode(
        id: 'hid_c_1',
        speakerId: 'system',
        text: '기억의 제단 위, 한 줄기 빛이 결정에 내려앉는다.',
        nextId: 'hid_c_2',
      ),
      const DialogueNode(
        id: 'hid_c_2',
        speakerId: 'player',
        text: '(이 결정... 만지면 따뜻한 느낌이 든다.)',
        nextId: 'hid_c_3',
      ),
      const DialogueNode(
        id: 'hid_c_3',
        speakerId: 'system',
        text: '\'첫 번째 기억의 결정\'을 발견했다. 가장 소중한 기억이 담겨있다.',
        nextId: 'hid_c_4',
      ),
      const DialogueNode(
        id: 'hid_c_4',
        speakerId: 'player',
        text: '(누군가의 웃음소리가... 들리는 것 같다.)',
        nextId: 'hid_c_5',
      ),
      const DialogueNode(
        id: 'hid_c_5',
        speakerId: 'unknown',
        text: '(기억 속 목소리) "...항상 함께할 거야. 약속해."',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_memory_crystal',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 스토리 아이템: 그림자의 파편 획득 ===
  static final itemShadow = DialogueSequence(
    id: 'ch5_item_shadow',
    nodes: [
      const DialogueNode(
        id: 'item_s_1',
        speakerId: 'player',
        text: '(검은 결정을 집어들자, 차가운 감정이 밀려온다.)',
        nextId: 'item_s_2',
      ),
      const DialogueNode(
        id: 'item_s_2',
        speakerId: 'system',
        text: '그림자의 파편. 자기혐오와 죄책감이 응축되어 있다.',
        nextId: 'item_s_3',
      ),
      const DialogueNode(
        id: 'item_s_3',
        speakerId: 'shadow_self',
        text: '(속삭이듯) "넌 날 버릴 수 없어... 난 너의 일부니까."',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_shadow_fragment',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 챕터 5 대화 시퀀스
  static List<DialogueSequence> get all => [
    abyssEntrance,
    memoryCorridor,
    mirrorRoomPastSelf,
    choiceRoom,
    truthRoom,
    shadowEncounter,
    shadowPhase2,
    shadowPhase3,
    shadowIntegration,
    futureSelfFarewell,
    epilogue,
    hallucination,
    // 스토리 아이템
    hiddenCrystal,
    itemShadow,
  ];
}

/// 과거의 자신 화자 정보
const pastSelfSpeaker = Speaker(
  id: 'past_self',
  name: '과거의 나',
  defaultPortrait: 'portraits/past_self.png',
);

/// 미래의 자신 화자 정보
const futureSelfSpeaker = Speaker(
  id: 'future_self',
  name: '미래의 아리온',
  defaultPortrait: 'portraits/future_self.png',
);

/// 그림자 자아 화자 정보
const shadowSelfSpeaker = Speaker(
  id: 'shadow_self',
  name: '그림자',
  defaultPortrait: 'portraits/shadow_self.png',
);

/// 기억 속 리리아나 화자 정보
const memoryLilianaSpeaker = Speaker(
  id: 'memory_liliana',
  name: '리리아나 (기억)',
  defaultPortrait: 'portraits/liliana_memory.png',
);

/// 기억 속 아리온 화자 정보
const memoryArionSpeaker = Speaker(
  id: 'memory_arion',
  name: '아리온 (기억)',
  defaultPortrait: 'portraits/arion_memory.png',
);
