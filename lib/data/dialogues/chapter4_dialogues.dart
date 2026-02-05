/// Arcana: The Three Hearts - 챕터 4 대화 시퀀스
/// 피의 정원 (The Garden of Blood)
library;

import '../model/dialogue.dart';

/// 챕터 4 대화 목록
class Chapter4Dialogues {
  Chapter4Dialogues._();

  // === 정원사 (The Gardener) ===

  /// 정원사 첫 만남
  static final gardenerFirst = DialogueSequence(
    id: 'gardener_first',
    nodes: [
      const DialogueNode(
        id: 'gd1',
        speakerId: 'system',
        text: '*온몸에 장미 가시가 박힌 노인이 서 있다. 피가 흐르지만 그는 미소 짓고 있다.*',
        nextId: 'gd2',
      ),
      const DialogueNode(
        id: 'gd2',
        speakerId: 'gardener',
        text: '어서 오게, 낯선 이여...',
        nextId: 'gd3',
      ),
      const DialogueNode(
        id: 'gd3',
        speakerId: 'gardener',
        text: '...아니, 낯설지 않군.',
        nextId: 'gd4',
      ),
      const DialogueNode(
        id: 'gd4',
        speakerId: 'system',
        text: '*노인의 눈이 당신을 응시한다.*',
        nextId: 'gd5',
      ),
      const DialogueNode(
        id: 'gd5',
        speakerId: 'gardener',
        text: '그 눈. 그 눈은...',
        nextId: 'gd6',
      ),
      const DialogueNode(
        id: 'gd6',
        speakerId: 'gardener',
        text: '...아가씨를 죽인 자의 눈이야.',
        nextId: 'gd7',
      ),
      const DialogueNode(
        id: 'gd7',
        speakerId: 'player',
        text: '...!',
        nextId: 'gd8',
      ),
      const DialogueNode(
        id: 'gd8',
        speakerId: 'gardener',
        text: '하지만 원망하지 않아.',
        nextId: 'gd9',
      ),
      const DialogueNode(
        id: 'gd9',
        speakerId: 'gardener',
        text: '네가 왜 그랬는지... 알고 있으니까.',
        nextId: 'gd10',
      ),
      const DialogueNode(
        id: 'gd10',
        speakerId: 'gardener',
        text: '아가씨도... 알고 있었어.',
        nextId: 'gd11',
      ),
      const DialogueNode(
        id: 'gd11',
        speakerId: 'gardener',
        text: '처음부터.',
        nextId: 'gd12',
      ),
      const DialogueNode(
        id: 'gd12',
        speakerId: 'system',
        text: '*노인이 정원 깊은 곳을 가리킨다.*',
        nextId: 'gd13',
      ),
      const DialogueNode(
        id: 'gd13',
        speakerId: 'gardener',
        text: '장미 미로를 지나면... 그녀가 기다리고 있어.',
        nextId: 'gd14',
      ),
      const DialogueNode(
        id: 'gd14',
        speakerId: 'gardener',
        text: '기억을 되찾을 준비가 됐다면... 가거라.',
        nextId: 'gd15',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_gardener',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'gd15',
        speakerId: 'gardener',
        text: '그리고... 아가씨에게 전해줘. 이 늙은이가 미안하다고.',
      ),
    ],
  );

  /// 정원사 기본 대화
  static final gardenerDefault = DialogueSequence(
    id: 'gardener_default',
    nodes: [
      const DialogueNode(
        id: 'gdd1',
        speakerId: 'gardener',
        text: '아직 여기 있나? 서두르게.',
        nextId: 'gdd2',
      ),
      const DialogueNode(
        id: 'gdd2',
        speakerId: 'gardener',
        text: '아가씨는... 오래 기다렸어.',
      ),
    ],
  );

  // === 장미 미로 기억들 ===

  /// 흰 장미 기억
  static final ch4RoseMemoryWhite = DialogueSequence(
    id: 'ch4_rose_memory_white',
    nodes: [
      const DialogueNode(
        id: 'rmw1',
        speakerId: 'system',
        text: '*흰 장미에서 희미한 빛이 새어나온다.*',
        nextId: 'rmw2',
      ),
      const DialogueNode(
        id: 'rmw2',
        speakerId: 'memory_liliana',
        text: '[기억] "처음 만난 날... 넌 울고 있었어."',
        nextId: 'rmw3',
      ),
      const DialogueNode(
        id: 'rmw3',
        speakerId: 'memory_liliana',
        text: '[기억] "비에 젖은 채로... 혼자서."',
        nextId: 'rmw4',
      ),
      const DialogueNode(
        id: 'rmw4',
        speakerId: 'system',
        text: '*머릿속에 장면이 스친다. 비 오는 밤, 누군가의 손이 다가오던 순간.*',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'rose_memory_white',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 분홍 장미 기억
  static final ch4RoseMemoryPink = DialogueSequence(
    id: 'ch4_rose_memory_pink',
    nodes: [
      const DialogueNode(
        id: 'rmp1',
        speakerId: 'system',
        text: '*분홍 장미가 따뜻한 빛을 발한다.*',
        nextId: 'rmp2',
      ),
      const DialogueNode(
        id: 'rmp2',
        speakerId: 'memory_liliana',
        text: '[기억] "항상 네 곁에 있을게."',
        nextId: 'rmp3',
      ),
      const DialogueNode(
        id: 'rmp3',
        speakerId: 'memory_liliana',
        text: '[기억] "약속해."',
        nextId: 'rmp4',
      ),
      const DialogueNode(
        id: 'rmp4',
        speakerId: 'system',
        text: '*웃고 있는 누군가의 얼굴이 어렴풋이 떠오른다.*',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'rose_memory_pink',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 빨간 장미 기억
  static final ch4RoseMemoryRed = DialogueSequence(
    id: 'ch4_rose_memory_red',
    nodes: [
      const DialogueNode(
        id: 'rmr1',
        speakerId: 'system',
        text: '*빨간 장미에서 뜨거운 감정이 전해진다.*',
        nextId: 'rmr2',
      ),
      const DialogueNode(
        id: 'rmr2',
        speakerId: 'memory_liliana',
        text: '[기억] "사랑해."',
        nextId: 'rmr3',
      ),
      const DialogueNode(
        id: 'rmr3',
        speakerId: 'memory_liliana',
        text: '[기억] "영원히."',
        nextId: 'rmr4',
      ),
      const DialogueNode(
        id: 'rmr4',
        speakerId: 'system',
        text: '*가슴이 뜨거워진다. 이 감정은... 사랑이었다.*',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'rose_memory_red',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 검은 장미 기억
  static final ch4RoseMemoryBlack = DialogueSequence(
    id: 'ch4_rose_memory_black',
    nodes: [
      const DialogueNode(
        id: 'rmb1',
        speakerId: 'system',
        text: '*검은 장미에서 차가운 기운이 흘러나온다.*',
        nextId: 'rmb2',
      ),
      const DialogueNode(
        id: 'rmb2',
        speakerId: 'memory_liliana',
        text: '[기억] "날 죽여줘..."',
        nextId: 'rmb3',
      ),
      const DialogueNode(
        id: 'rmb3',
        speakerId: 'memory_liliana',
        text: '[기억] "제발..."',
        nextId: 'rmb4',
      ),
      const DialogueNode(
        id: 'rmb4',
        speakerId: 'player',
        text: '...!',
        nextId: 'rmb5',
      ),
      const DialogueNode(
        id: 'rmb5',
        speakerId: 'system',
        text: '*머릿속이 갈라지는 듯한 고통. 이건... 부탁이었다.*',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'rose_memory_black',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 핏빛 장미 기억
  static final ch4RoseMemoryBlood = DialogueSequence(
    id: 'ch4_rose_memory_blood',
    nodes: [
      const DialogueNode(
        id: 'rmbl1',
        speakerId: 'system',
        text: '*핏빛 장미가 고동친다. 마치 심장처럼.*',
        nextId: 'rmbl2',
      ),
      const DialogueNode(
        id: 'rmbl2',
        speakerId: 'memory_player',
        text: '[기억] "미안해..."',
        nextId: 'rmbl3',
      ),
      const DialogueNode(
        id: 'rmbl3',
        speakerId: 'memory_player',
        text: '[기억] "미안해..."',
        nextId: 'rmbl4',
      ),
      const DialogueNode(
        id: 'rmbl4',
        speakerId: 'player',
        text: '이 목소리는... 나야.',
        nextId: 'rmbl5',
      ),
      const DialogueNode(
        id: 'rmbl5',
        speakerId: 'system',
        text: '*검을 휘두르는 순간이 떠오른다. 피. 눈물. 그리고 그녀의 미소.*',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'rose_memory_blood',
          flagValue: true,
        ),
      ),
    ],
  );

  // === 중앙 분수: 기억 회복 ===

  /// 중앙 분수 기억 회복
  static final ch4FountainMemory = DialogueSequence(
    id: 'ch4_fountain_memory',
    nodes: [
      const DialogueNode(
        id: 'fm1',
        speakerId: 'system',
        text: '*분수 중앙에 여인의 동상이 서 있다. 피가 눈물처럼 흐른다.*',
        nextId: 'fm2',
      ),
      const DialogueNode(
        id: 'fm2',
        speakerId: 'system',
        text: '*동상의 얼굴을 보는 순간, 모든 것이 밀려온다.*',
        nextId: 'fm3',
      ),
      const DialogueNode(
        id: 'fm3',
        speakerId: 'player',
        text: '...리리아나.',
        nextId: 'fm4',
      ),
      const DialogueNode(
        id: 'fm4',
        speakerId: 'system',
        text: '*그녀의 이름. 잊고 있던 이름.*',
        nextId: 'fm5',
      ),
      const DialogueNode(
        id: 'fm5',
        speakerId: 'system',
        text: '*행복했던 날들이 스쳐간다. 함께 웃던 시간. 손을 잡고 걷던 정원.*',
        nextId: 'fm6',
      ),
      const DialogueNode(
        id: 'fm6',
        speakerId: 'player',
        text: '우리는... 연인이었어.',
        nextId: 'fm7',
      ),
      const DialogueNode(
        id: 'fm7',
        speakerId: 'system',
        text: '*그리고 마지막 날. 그녀의 부탁. 그녀를 죽여야 했던 이유.*',
        nextId: 'fm8',
      ),
      const DialogueNode(
        id: 'fm8',
        speakerId: 'player',
        text: '...아직 전부는 기억나지 않아. 하지만...',
        nextId: 'fm9',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'liliana_name_recovered',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'fm9',
        speakerId: 'player',
        text: '만나야 해. 그녀를.',
      ),
    ],
  );

  // === 가시의 방 환청 ===

  /// 가시의 방 환청 (Hearts <= 2)
  static final ch4ThornHallucination = DialogueSequence(
    id: 'ch4_thorn_hallucination',
    nodes: [
      const DialogueNode(
        id: 'th1',
        speakerId: 'unknown',
        text: '[속삭임] 왜...',
        nextId: 'th2',
      ),
      const DialogueNode(
        id: 'th2',
        speakerId: 'unknown',
        text: '[속삭임] 왜 날 죽였어...?',
        nextId: 'th3',
      ),
      const DialogueNode(
        id: 'th3',
        speakerId: 'player',
        text: '리리아나...?',
        nextId: 'th4',
      ),
      const DialogueNode(
        id: 'th4',
        speakerId: 'liliana_ghost',
        text: '아파. 아직도 아파.',
        nextId: 'th5',
      ),
      const DialogueNode(
        id: 'th5',
        speakerId: 'liliana_ghost',
        text: '네 손이... 차가웠어.',
        nextId: 'th6',
      ),
      const DialogueNode(
        id: 'th6',
        speakerId: 'player',
        text: '...미안해.',
        nextId: 'th7',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'heard_thorn_hallucination',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'th7',
        speakerId: 'system',
        text: '*목소리가 사라진다. 하지만 가시가 심장을 찌르는 듯한 고통이 남는다.*',
      ),
    ],
  );

  // === 보스: 리리아나의 환영 ===

  /// 리리아나 조우
  static final ch4LilianaEncounter = DialogueSequence(
    id: 'ch4_liliana_encounter',
    nodes: [
      const DialogueNode(
        id: 'le1',
        speakerId: 'system',
        text: '*거대한 장미 나무 아래, 그녀가 서 있다.*',
        nextId: 'le2',
      ),
      const DialogueNode(
        id: 'le2',
        speakerId: 'system',
        text: '*아름다운 여인. 하지만 가슴에는 검 상처가 있고, 그곳에서 핏빛 장미가 피어난다.*',
        nextId: 'le3',
      ),
      const DialogueNode(
        id: 'le3',
        speakerId: 'liliana',
        text: '...오래 기다렸어.',
        nextId: 'le4',
      ),
      const DialogueNode(
        id: 'le4',
        speakerId: 'player',
        text: '리리아나...',
        nextId: 'le5',
      ),
      const DialogueNode(
        id: 'le5',
        speakerId: 'liliana',
        text: '기억났어? 나를?',
        nextId: 'le6',
      ),
      const DialogueNode(
        id: 'le6',
        speakerId: 'liliana',
        text: '...우리를?',
        nextId: 'le7',
      ),
      const DialogueNode(
        id: 'le7',
        speakerId: 'system',
        text: '*리리아나의 모습이 일그러진다. 원한의 형상으로.*',
        nextId: 'le8',
      ),
      const DialogueNode(
        id: 'le8',
        speakerId: 'liliana',
        text: '사랑했어. 진심으로. 세상 누구보다.',
        nextId: 'le9',
      ),
      const DialogueNode(
        id: 'le9',
        speakerId: 'liliana',
        text: '그래서 더 용서할 수 없어.',
        nextId: 'le10',
      ),
      const DialogueNode(
        id: 'le10',
        speakerId: 'liliana',
        text: '네가 나를 죽였어.',
        nextId: 'le11',
      ),
      const DialogueNode(
        id: 'le11',
        speakerId: 'liliana',
        text: '네 손으로. 네 검으로.',
        nextId: 'le12',
      ),
      const DialogueNode(
        id: 'le12',
        speakerId: 'system',
        text: '*장미 가시가 리리아나를 둘러싼다.*',
        nextId: 'le13',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'liliana_encounter_complete',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'le13',
        speakerId: 'liliana',
        text: '이번엔... 내가 널 죽일 차례야.',
      ),
    ],
  );

  /// 리리아나 페이즈 2 전환 (배신의 고통)
  static final ch4LilianaPhase2 = DialogueSequence(
    id: 'ch4_liliana_phase2',
    nodes: [
      const DialogueNode(
        id: 'lp2_1',
        speakerId: 'system',
        text: '*리리아나의 몸에서 가시가 돋아난다.*',
        nextId: 'lp2_2',
      ),
      const DialogueNode(
        id: 'lp2_2',
        speakerId: 'liliana',
        text: '아파... 아직도 아파...',
        nextId: 'lp2_3',
      ),
      const DialogueNode(
        id: 'lp2_3',
        speakerId: 'liliana',
        text: '죽는 건 무섭지 않았어.',
        nextId: 'lp2_4',
      ),
      const DialogueNode(
        id: 'lp2_4',
        speakerId: 'liliana',
        text: '네 손에 죽는 것도.',
        nextId: 'lp2_5',
      ),
      const DialogueNode(
        id: 'lp2_5',
        speakerId: 'liliana',
        text: '하지만...',
        nextId: 'lp2_6',
      ),
      const DialogueNode(
        id: 'lp2_6',
        speakerId: 'liliana',
        text: '네 눈에서 눈물이 보였을 때...',
        nextId: 'lp2_7',
      ),
      const DialogueNode(
        id: 'lp2_7',
        speakerId: 'liliana',
        text: '그게 제일 아팠어!',
        nextId: 'lp2_8',
      ),
      const DialogueNode(
        id: 'lp2_8',
        speakerId: 'system',
        text: '*가시 폭풍이 몰아친다.*',
      ),
    ],
  );

  /// 리리아나 페이즈 3 전환 (용서와 원한 사이)
  static final ch4LilianaPhase3 = DialogueSequence(
    id: 'ch4_liliana_phase3',
    nodes: [
      const DialogueNode(
        id: 'lp3_1',
        speakerId: 'system',
        text: '*리리아나가 눈물을 흘린다.*',
        nextId: 'lp3_2',
      ),
      const DialogueNode(
        id: 'lp3_2',
        speakerId: 'liliana',
        text: '...왜.',
        nextId: 'lp3_3',
      ),
      const DialogueNode(
        id: 'lp3_3',
        speakerId: 'liliana',
        text: '왜 내가 널 미워할 수가 없는 거야...',
        nextId: 'lp3_4',
      ),
      const DialogueNode(
        id: 'lp3_4',
        speakerId: 'liliana',
        text: '미워해야 해. 원망해야 해.',
        nextId: 'lp3_5',
      ),
      const DialogueNode(
        id: 'lp3_5',
        speakerId: 'liliana',
        text: '그런데... 그런데...',
        nextId: 'lp3_6',
      ),
      const DialogueNode(
        id: 'lp3_6',
        speakerId: 'system',
        text: '*리리아나의 공격이 불규칙해진다. 사랑과 원한이 뒤섞여.*',
      ),
    ],
  );

  /// 리리아나 처치
  static final ch4LilianaDefeat = DialogueSequence(
    id: 'ch4_liliana_defeat',
    nodes: [
      const DialogueNode(
        id: 'ld1',
        speakerId: 'system',
        text: '*리리아나가 무릎을 꿇는다. 가시가 떨어져 나간다.*',
        nextId: 'ld2',
      ),
      const DialogueNode(
        id: 'ld2',
        speakerId: 'liliana',
        text: '...졌네.',
        nextId: 'ld3',
      ),
      const DialogueNode(
        id: 'ld3',
        speakerId: 'liliana',
        text: '또 졌어.',
        nextId: 'ld4',
      ),
      const DialogueNode(
        id: 'ld4',
        speakerId: 'system',
        text: '*리리아나의 모습이 생전의 모습으로 돌아온다.*',
        nextId: 'ld5',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'liliana_defeated',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'ld5',
        speakerId: 'system',
        text: '『리리아나의 눈물』을 획득했다.\n『피의 정원의 아르카나』를 획득했다.',
      ),
    ],
  );

  /// 진실 공개 (핵심 컷씬)
  static final ch4TruthReveal = DialogueSequence(
    id: 'ch4_truth_reveal',
    nodes: [
      const DialogueNode(
        id: 'tr1',
        speakerId: 'liliana',
        text: '...알아.',
        nextId: 'tr2',
      ),
      const DialogueNode(
        id: 'tr2',
        speakerId: 'liliana',
        text: '알고 있었어. 처음부터.',
        nextId: 'tr3',
      ),
      const DialogueNode(
        id: 'tr3',
        speakerId: 'player',
        text: '...뭘?',
        nextId: 'tr4',
      ),
      const DialogueNode(
        id: 'tr4',
        speakerId: 'liliana',
        text: '내가 부탁했잖아.',
        nextId: 'tr5',
      ),
      const DialogueNode(
        id: 'tr5',
        speakerId: 'liliana',
        text: '"날 죽여줘"라고.',
        nextId: 'tr6',
      ),
      const DialogueNode(
        id: 'tr6',
        speakerId: 'system',
        text: '*기억이 완전히 돌아온다.*',
        nextId: 'tr7',
      ),
      const DialogueNode(
        id: 'tr7',
        speakerId: 'system',
        text: '*리리아나는 태어날 때부터 \'종말의 저주\'를 품고 있었다.*',
        nextId: 'tr8',
      ),
      const DialogueNode(
        id: 'tr8',
        speakerId: 'system',
        text: '*그녀의 22번째 생일에 저주가 발동하여 세계를 멸망시킬 예정이었다.*',
        nextId: 'tr9',
      ),
      const DialogueNode(
        id: 'tr9',
        speakerId: 'system',
        text: '*유일한 해결책: 발동 전에 저주의 그릇을 죽이는 것.*',
        nextId: 'tr10',
      ),
      const DialogueNode(
        id: 'tr10',
        speakerId: 'player',
        text: '그래서... 난...',
        nextId: 'tr11',
      ),
      const DialogueNode(
        id: 'tr11',
        speakerId: 'liliana',
        text: '세상을 구했어.',
        nextId: 'tr12',
      ),
      const DialogueNode(
        id: 'tr12',
        speakerId: 'liliana',
        text: '나 대신.',
        nextId: 'tr13',
      ),
      const DialogueNode(
        id: 'tr13',
        speakerId: 'player',
        text: '그래도... 난...',
        nextId: 'tr14',
      ),
      const DialogueNode(
        id: 'tr14',
        speakerId: 'liliana',
        text: '그게 네가 할 수 있는 최선이었어.',
        nextId: 'tr15',
      ),
      const DialogueNode(
        id: 'tr15',
        speakerId: 'player',
        text: '최선이 아니야. 널 살릴 방법이 있었을지도...',
        nextId: 'tr16',
      ),
      const DialogueNode(
        id: 'tr16',
        speakerId: 'liliana',
        text: '그래.',
        nextId: 'tr17',
      ),
      const DialogueNode(
        id: 'tr17',
        speakerId: 'liliana',
        text: '그래서 네가 여기 있는 거야.',
        nextId: 'tr18',
      ),
      const DialogueNode(
        id: 'tr18',
        speakerId: 'liliana',
        text: '기억을 되찾았으니까...',
        nextId: 'tr19',
      ),
      const DialogueNode(
        id: 'tr19',
        speakerId: 'liliana',
        text: '이제 찾을 수 있어.',
        nextId: 'tr20',
      ),
      const DialogueNode(
        id: 'tr20',
        speakerId: 'liliana',
        text: '\'나\'를 진짜로 구할 방법을.',
        nextId: 'tr21',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'truth_revealed',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'tr21',
        speakerId: 'system',
        text: '*리리아나가 미소 짓는다. 생전의 그 미소 그대로.*',
      ),
    ],
  );

  /// 에필로그
  static final ch4Epilogue = DialogueSequence(
    id: 'ch4_epilogue',
    nodes: [
      const DialogueNode(
        id: 'ep1',
        speakerId: 'liliana',
        text: '...아팠어. 솔직히.',
        nextId: 'ep2',
      ),
      const DialogueNode(
        id: 'ep2',
        speakerId: 'liliana',
        text: '네가 검을 들었을 때. 네가 날 안았을 때.',
        nextId: 'ep3',
      ),
      const DialogueNode(
        id: 'ep3',
        speakerId: 'liliana',
        text: '알고 있었는데도... 아팠어.',
        nextId: 'ep4',
      ),
      const DialogueNode(
        id: 'ep4',
        speakerId: 'player',
        text: '...미안해.',
        nextId: 'ep5',
      ),
      const DialogueNode(
        id: 'ep5',
        speakerId: 'liliana',
        text: '사과하지 마.',
        nextId: 'ep6',
      ),
      const DialogueNode(
        id: 'ep6',
        speakerId: 'liliana',
        text: '대신... 약속해.',
        nextId: 'ep7',
      ),
      const DialogueNode(
        id: 'ep7',
        speakerId: 'liliana',
        text: '이번엔 날 살려줘.',
        nextId: 'ep8',
      ),
      const DialogueNode(
        id: 'ep8',
        speakerId: 'player',
        text: '...반드시.',
        nextId: 'ep9',
      ),
      const DialogueNode(
        id: 'ep9',
        speakerId: 'system',
        text: '*리리아나가 빛의 입자가 되어 흩어진다.*',
        nextId: 'ep10',
      ),
      const DialogueNode(
        id: 'ep10',
        speakerId: 'liliana_echo',
        text: '[메아리] "기억의 심연에서... 기다릴게..."',
        nextId: 'ep11',
      ),
      const DialogueNode(
        id: 'ep11',
        speakerId: 'system',
        text: '『세 개의 심장은 세 번의 기회』',
        nextId: 'ep12',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chapter4_complete',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'ep12',
        speakerId: 'system',
        text: '*다음 목적지: 기억의 심연*',
        nextId: 'ep13',
      ),
      const DialogueNode(
        id: 'ep13',
        speakerId: 'system',
        text: '"과거의 심장"을 획득했다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'has_heart_of_past',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 스토리 아이템: 리리아나의 반지 획득 ===
  static final itemRing = DialogueSequence(
    id: 'ch4_item_ring',
    nodes: [
      const DialogueNode(
        id: 'item_r_1',
        speakerId: 'player',
        text: '(반지를 집어들자, 희미한 빛이 손가락 사이로 새어나온다.)',
        nextId: 'item_r_2',
      ),
      const DialogueNode(
        id: 'item_r_2',
        speakerId: 'system',
        text: '리리아나의 반지. 두 사람의 영원한 사랑을 약속했던 증표.',
        nextId: 'item_r_3',
      ),
      const DialogueNode(
        id: 'item_r_3',
        speakerId: 'player',
        text: '(왜 이렇게... 익숙한 느낌이 드는 걸까?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_liliana_ring',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 숨겨진 아이템: 약속의 반지 (트루 엔딩 필수) ===
  static final hiddenRing = DialogueSequence(
    id: 'ch4_hidden_ring',
    nodes: [
      const DialogueNode(
        id: 'hid_r_1',
        speakerId: 'system',
        text: '정원 구석의 시든 장미 덤불 아래, 무언가 빛나고 있다.',
        nextId: 'hid_r_2',
      ),
      const DialogueNode(
        id: 'hid_r_2',
        speakerId: 'player',
        text: '(이건... 반지? 아니, 두 개의 반지가 맞물려 있다.)',
        nextId: 'hid_r_3',
      ),
      const DialogueNode(
        id: 'hid_r_3',
        speakerId: 'system',
        text: '\'약속의 반지\'를 발견했다. 영원한 약속을 상징하는 낡은 반지.',
        nextId: 'hid_r_4',
      ),
      const DialogueNode(
        id: 'hid_r_4',
        speakerId: 'player',
        text: '(가슴 속 깊은 곳이... 아프다. 이 반지는 분명...)',
        nextId: 'hid_r_5',
      ),
      const DialogueNode(
        id: 'hid_r_5',
        speakerId: 'unknown',
        text: '(바람에 실려오는 목소리) "...약속해줘... 날 잊지 않겠다고..."',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_promise_ring',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 챕터 4 대화 시퀀스
  static final List<DialogueSequence> all = [
    // NPC 대화
    gardenerFirst,
    gardenerDefault,
    // 장미 미로 기억
    ch4RoseMemoryWhite,
    ch4RoseMemoryPink,
    ch4RoseMemoryRed,
    ch4RoseMemoryBlack,
    ch4RoseMemoryBlood,
    // 기억 회복
    ch4FountainMemory,
    // 환청
    ch4ThornHallucination,
    // 보스 대화
    ch4LilianaEncounter,
    ch4LilianaPhase2,
    ch4LilianaPhase3,
    ch4LilianaDefeat,
    // 진실 공개
    ch4TruthReveal,
    // 에필로그
    ch4Epilogue,
    // 스토리 아이템
    itemRing,
    hiddenRing,
  ];
}
