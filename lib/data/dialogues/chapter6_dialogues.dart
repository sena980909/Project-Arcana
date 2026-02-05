/// Arcana: The Three Hearts - 챕터 6 대화
/// 망각의 옥좌 (The Throne of Oblivion)
library;

import '../model/dialogue.dart';

/// 챕터 6 대화 시퀀스 모음
class Chapter6Dialogues {
  Chapter6Dialogues._();

  /// === 망각의 문 ===
  static final oblivionGate = DialogueSequence(
    id: 'ch6_oblivion_gate',
    nodes: [
      const DialogueNode(
        id: 'gate_1',
        speakerId: 'system',
        text: '세계의 끝. 거대한 공허의 문이 서 있다.',
        nextId: 'gate_2',
      ),
      const DialogueNode(
        id: 'gate_2',
        speakerId: 'system',
        text: '문 너머로 희미한 빛이 새어 나온다. 그 빛 속에... 그녀가 있다.',
        nextId: 'gate_3',
      ),
      const DialogueNode(
        id: 'gate_3',
        speakerId: 'player',
        text: '리리아나...',
        nextId: 'gate_4',
      ),
      const DialogueNode(
        id: 'gate_4',
        speakerId: 'system',
        text: '가슴 속 세 개의 심장이 맥동한다. 아직 하나가 비어 있다.',
        nextId: 'gate_5',
      ),
      const DialogueNode(
        id: 'gate_5',
        speakerId: 'player',
        text: '(세 번째 심장... 미래의 심장. 여기서 증명해야 해.)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'entered_oblivion',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 잊혀진 자들의 길 ===
  static final forgottenPath = DialogueSequence(
    id: 'ch6_forgotten_path',
    nodes: [
      const DialogueNode(
        id: 'path_1',
        speakerId: 'system',
        text: '흐릿한 형체들이 길 양쪽에 떠다닌다.',
        nextId: 'path_2',
      ),
      const DialogueNode(
        id: 'path_2',
        speakerId: 'forgotten_voice',
        text: '...기억해줘...',
        nextId: 'path_3',
      ),
      const DialogueNode(
        id: 'path_3',
        speakerId: 'forgotten_voice',
        text: '...이름이... 있었는데...',
        nextId: 'path_4',
      ),
      const DialogueNode(
        id: 'path_4',
        speakerId: 'player',
        text: '(리리아나만이 아니었구나... 이곳에 잊혀진 자들이...)',
        nextId: 'path_5',
      ),
      const DialogueNode(
        id: 'path_5',
        speakerId: 'system',
        text: '수많은 존재들이 세계에서 잊혀져 이곳에 봉인되어 있다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'saw_forgotten_ones',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 잊혀진 현자 ===
  static final forgottenSage = DialogueSequence(
    id: 'ch6_forgotten_sage',
    nodes: [
      const DialogueNode(
        id: 'sage_1',
        speakerId: 'forgotten_sage',
        text: '오래... 기다렸다. 봉인을 풀러 온 자여.',
        nextId: 'sage_2',
      ),
      const DialogueNode(
        id: 'sage_2',
        speakerId: 'player',
        text: '당신은...?',
        nextId: 'sage_3',
      ),
      const DialogueNode(
        id: 'sage_3',
        speakerId: 'forgotten_sage',
        text: '나도 한때는 이름이 있었지. 업적도.',
        nextId: 'sage_4',
      ),
      const DialogueNode(
        id: 'sage_4',
        speakerId: 'forgotten_sage',
        text: '하지만... 대가를 치렀거든. 리리아나처럼.',
        nextId: 'sage_5',
      ),
      const DialogueNode(
        id: 'sage_5',
        speakerId: 'player',
        text: '대가요?',
        nextId: 'sage_6',
      ),
      const DialogueNode(
        id: 'sage_6',
        speakerId: 'forgotten_sage',
        text: '봉인을 풀 방법은 두 가지다.',
        nextId: 'sage_7',
      ),
      const DialogueNode(
        id: 'sage_7',
        speakerId: 'forgotten_sage',
        text: '첫째, 네가 대신 잊혀지는 것.',
        nextId: 'sage_8',
      ),
      const DialogueNode(
        id: 'sage_8',
        speakerId: 'forgotten_sage',
        text: '둘째... 다른 무언가를 대가로 바치는 것.',
        nextId: 'sage_9',
      ),
      const DialogueNode(
        id: 'sage_9',
        speakerId: 'player',
        text: '다른 무언가?',
        nextId: 'sage_10',
      ),
      const DialogueNode(
        id: 'sage_10',
        speakerId: 'forgotten_sage',
        text: '이 세계 너머의 무언가. 윤회의 실 같은 것.',
        nextId: 'sage_11',
      ),
      const DialogueNode(
        id: 'sage_11',
        speakerId: 'forgotten_sage',
        text: '하지만... 그런 것을 가진 자는 드물지.',
        nextId: 'sage_12',
      ),
      const DialogueNode(
        id: 'sage_12',
        speakerId: 'forgotten_sage',
        text: '가거라. 그녀가 기다린다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'learned_price',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 리리아나 재회 ===
  static final lilianaReunion = DialogueSequence(
    id: 'ch6_liliana_reunion',
    nodes: [
      const DialogueNode(
        id: 'reu_1',
        speakerId: 'system',
        text: '거대한 수정 관. 그 안에 리리아나가 잠들어 있다.',
        nextId: 'reu_2',
      ),
      const DialogueNode(
        id: 'reu_2',
        speakerId: 'system',
        text: '평화로운 얼굴. 저주의 흔적은 없다.',
        nextId: 'reu_3',
      ),
      const DialogueNode(
        id: 'reu_3',
        speakerId: 'player',
        text: '리리아나...',
        nextId: 'reu_4',
      ),
      const DialogueNode(
        id: 'reu_4',
        speakerId: 'system',
        text: '세 개의 심장이 공명한다. 봉인이 약해지기 시작한다.',
        nextId: 'reu_5',
      ),
      const DialogueNode(
        id: 'reu_5',
        speakerId: 'system',
        text: '리리아나의 눈꺼풀이 떨린다.',
        nextId: 'reu_6',
      ),
      const DialogueNode(
        id: 'reu_6',
        speakerId: 'liliana',
        text: '...아리온?',
        nextId: 'reu_7',
      ),
      const DialogueNode(
        id: 'reu_7',
        speakerId: 'liliana',
        text: '꿈이야? 또 꿈을 꾸는 거야?',
        nextId: 'reu_8',
      ),
      const DialogueNode(
        id: 'reu_8',
        speakerId: 'player',
        text: '아니야. 진짜야. 내가 왔어.',
        nextId: 'reu_9',
      ),
      const DialogueNode(
        id: 'reu_9',
        speakerId: 'liliana',
        text: '(손을 뻗으며) 진짜... 진짜 네가 온 거야?',
        nextId: 'reu_10',
      ),
      const DialogueNode(
        id: 'reu_10',
        speakerId: 'liliana',
        text: '...바보. 왜 왔어. 여기 오면 안 됐는데.',
        nextId: 'reu_11',
      ),
      const DialogueNode(
        id: 'reu_11',
        speakerId: 'player',
        text: '널 구하러 왔어.',
        nextId: 'reu_12',
      ),
      const DialogueNode(
        id: 'reu_12',
        speakerId: 'liliana',
        text: '대가가 필요하다는 거 알잖아. 넌... 넌...',
        nextId: 'reu_13',
      ),
      const DialogueNode(
        id: 'reu_13',
        speakerId: 'liliana',
        text: '(울며) 날 위해 사라지면 안 돼. 절대로.',
        nextId: 'reu_14',
      ),
      const DialogueNode(
        id: 'reu_14',
        speakerId: 'player',
        text: '걱정 마. 방법을 찾을 거야.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'reunited_with_liliana',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 망각의 화신 조우 ===
  static final oblivionEncounter = DialogueSequence(
    id: 'ch6_oblivion_encounter',
    nodes: [
      const DialogueNode(
        id: 'obl_1',
        speakerId: 'system',
        text: '어둠 속에서 거대한 공허가 형체를 드러낸다.',
        nextId: 'obl_2',
      ),
      const DialogueNode(
        id: 'obl_2',
        speakerId: 'system',
        text: '형체가 없다. 때때로 잊혀진 자들의 얼굴이 스쳐 지나간다.',
        nextId: 'obl_3',
      ),
      const DialogueNode(
        id: 'obl_3',
        speakerId: 'oblivion',
        text: '...아리온.',
        nextId: 'obl_4',
      ),
      const DialogueNode(
        id: 'obl_4',
        speakerId: 'oblivion',
        text: '봉인을 풀러 왔구나.',
        nextId: 'obl_5',
      ),
      const DialogueNode(
        id: 'obl_5',
        speakerId: 'player',
        text: '넌 뭐야?',
        nextId: 'obl_6',
      ),
      const DialogueNode(
        id: 'obl_6',
        speakerId: 'oblivion',
        text: '나는 망각. 세계가 잊을 때 생겨나는 것.',
        nextId: 'obl_7',
      ),
      const DialogueNode(
        id: 'obl_7',
        speakerId: 'oblivion',
        text: '선도 악도 아니다. 단지... 균형.',
        nextId: 'obl_8',
      ),
      const DialogueNode(
        id: 'obl_8',
        speakerId: 'oblivion',
        text: '그녀를 데려가려면, 대가를 치러라.',
        nextId: 'obl_9',
      ),
      const DialogueNode(
        id: 'obl_9',
        speakerId: 'player',
        text: '...알았어. 덤벼.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'oblivion_encounter_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 망각의 화신 Phase 2 ===
  static final oblivionPhase2 = DialogueSequence(
    id: 'ch6_oblivion_phase2',
    nodes: [
      const DialogueNode(
        id: 'op2_1',
        speakerId: 'oblivion',
        text: '과거를 지켰구나...',
        nextId: 'op2_2',
      ),
      const DialogueNode(
        id: 'op2_2',
        speakerId: 'oblivion',
        text: '하지만 현재는 어떠냐?',
        nextId: 'op2_3',
      ),
      const DialogueNode(
        id: 'op2_3',
        speakerId: 'oblivion',
        text: '네 존재 자체를... 잊게 해주지.',
        nextId: 'op2_4',
      ),
      const DialogueNode(
        id: 'op2_4',
        speakerId: 'player',
        text: '(몸이 투명해진다) ...!',
      ),
    ],
  );

  /// === 망각의 화신 Phase 3 ===
  static final oblivionPhase3 = DialogueSequence(
    id: 'ch6_oblivion_phase3',
    nodes: [
      const DialogueNode(
        id: 'op3_1',
        speakerId: 'oblivion',
        text: '대단하군. 존재마저 붙잡다니.',
        nextId: 'op3_2',
      ),
      const DialogueNode(
        id: 'op3_2',
        speakerId: 'oblivion',
        text: '그렇다면... 미래를 지울 수 있을까?',
        nextId: 'op3_3',
      ),
      const DialogueNode(
        id: 'op3_3',
        speakerId: 'oblivion',
        text: '네 가능성을. 너의 미래를.',
        nextId: 'op3_4',
      ),
      const DialogueNode(
        id: 'op3_4',
        speakerId: 'player',
        text: '미래는... 내가 만드는 거야!',
      ),
    ],
  );

  /// === 세 번째 심장 각성 ===
  static final thirdHeartAwakening = DialogueSequence(
    id: 'ch6_third_heart',
    nodes: [
      const DialogueNode(
        id: 'heart_1',
        speakerId: 'system',
        text: '가슴 속에서 강렬한 빛이 터져 나온다.',
        nextId: 'heart_2',
      ),
      const DialogueNode(
        id: 'heart_2',
        speakerId: 'player',
        text: '...리리아나를 구하겠어.',
        nextId: 'heart_3',
      ),
      const DialogueNode(
        id: 'heart_3',
        speakerId: 'player',
        text: '무슨 일이 있어도. 그게 내 의지야.',
        nextId: 'heart_4',
      ),
      const DialogueNode(
        id: 'heart_4',
        speakerId: 'system',
        text: '세 개의 심장이 공명한다. 과거, 현재, 그리고 미래.',
        nextId: 'heart_5',
      ),
      const DialogueNode(
        id: 'heart_5',
        speakerId: 'system',
        text: '"미래의 심장"이 각성했다.',
        nextId: 'heart_6',
        trigger: DialogueTrigger(
          type: TriggerType.giveItem,
          itemId: 'heart_of_future',
          amount: 1,
        ),
      ),
      const DialogueNode(
        id: 'heart_6',
        speakerId: 'system',
        text: '세 개의 심장이 완성되었다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'three_hearts_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 망각의 화신 Phase 4 (최후의 거래) ===
  static final oblivionPhase4 = DialogueSequence(
    id: 'ch6_oblivion_phase4',
    nodes: [
      const DialogueNode(
        id: 'op4_1',
        speakerId: 'oblivion',
        text: '...멈춰라.',
        nextId: 'op4_2',
      ),
      const DialogueNode(
        id: 'op4_2',
        speakerId: 'oblivion',
        text: '나를 죽일 수는 없다. 망각은 세계의 일부다.',
        nextId: 'op4_3',
      ),
      const DialogueNode(
        id: 'op4_3',
        speakerId: 'oblivion',
        text: '하지만... 거래는 가능하다.',
        nextId: 'op4_4',
      ),
      const DialogueNode(
        id: 'op4_4',
        speakerId: 'oblivion',
        text: '대가를 선택해라, 아리온.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'reached_final_choice',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 노말 엔딩 선택 ===
  static final normalEndingChoice = DialogueSequence(
    id: 'ch6_normal_ending_choice',
    nodes: [
      const DialogueNode(
        id: 'nec_1',
        speakerId: 'player',
        text: '...내가 대가가 될게.',
        nextId: 'nec_2',
      ),
      const DialogueNode(
        id: 'nec_2',
        speakerId: 'liliana',
        text: '안 돼! 제발... 다른 방법을 찾자. 시간이 더 필요해.',
        nextId: 'nec_3',
      ),
      const DialogueNode(
        id: 'nec_3',
        speakerId: 'player',
        text: '리리아나. 난 한 번 널 죽였어.',
        nextId: 'nec_4',
      ),
      const DialogueNode(
        id: 'nec_4',
        speakerId: 'player',
        text: '그때 지키지 못한 약속을... 이제야 지키는 거야.',
        nextId: 'nec_5',
      ),
      const DialogueNode(
        id: 'nec_5',
        speakerId: 'liliana',
        text: '이건 약속을 지키는 게 아니야! 이건...!',
        nextId: 'nec_6',
      ),
      const DialogueNode(
        id: 'nec_6',
        speakerId: 'player',
        text: '사랑해. 영원히. 그건 변하지 않아.',
        nextId: 'nec_7',
      ),
      const DialogueNode(
        id: 'nec_7',
        speakerId: 'player',
        text: '네가 날 잊어도... 난 널 기억할 테니까.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chose_normal_ending',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 노말 엔딩 ===
  static final normalEnding = DialogueSequence(
    id: 'ch6_normal_ending',
    nodes: [
      const DialogueNode(
        id: 'ne_1',
        speakerId: 'system',
        text: '아리온이 봉인에 손을 댄다.',
        nextId: 'ne_2',
      ),
      const DialogueNode(
        id: 'ne_2',
        speakerId: 'system',
        text: '빛이 퍼지며... 아리온의 형체가 흐려지기 시작한다.',
        nextId: 'ne_3',
      ),
      const DialogueNode(
        id: 'ne_3',
        speakerId: 'player',
        text: '(흐려지며) 잘 살아. 행복하게. 이번엔 진짜로.',
        nextId: 'ne_4',
      ),
      const DialogueNode(
        id: 'ne_4',
        speakerId: 'system',
        text: '봉인이 풀린다. 리리아나가 완전히 깨어난다.',
        nextId: 'ne_5',
      ),
      const DialogueNode(
        id: 'ne_5',
        speakerId: 'liliana',
        text: '...여기가 어디지?',
        nextId: 'ne_6',
      ),
      const DialogueNode(
        id: 'ne_6',
        speakerId: 'system',
        text: '아리온이 손을 뻗지만... 리리아나는 보지 못한다.',
        nextId: 'ne_7',
      ),
      const DialogueNode(
        id: 'ne_7',
        speakerId: 'player',
        text: '(독백) ...괜찮아. 네가 살아있으면.',
        nextId: 'ne_8',
      ),
      const DialogueNode(
        id: 'ne_8',
        speakerId: 'system',
        text: '--- 시간이 흐른다 ---',
        nextId: 'ne_9',
      ),
      const DialogueNode(
        id: 'ne_9',
        speakerId: 'system',
        text: '리리아나는 새로운 삶을 살기 시작했다.',
        nextId: 'ne_10',
      ),
      const DialogueNode(
        id: 'ne_10',
        speakerId: 'liliana',
        text: '(창밖을 보며) ...왜 이렇게 그리운 걸까.',
        nextId: 'ne_11',
      ),
      const DialogueNode(
        id: 'ne_11',
        speakerId: 'liliana',
        text: '뭔가를 잊은 것 같아...',
        nextId: 'ne_12',
      ),
      const DialogueNode(
        id: 'ne_12',
        speakerId: 'system',
        text: '그녀 곁에 아리온의 잔상이 서 있다. 그녀는 알지 못한다.',
        nextId: 'ne_13',
      ),
      const DialogueNode(
        id: 'ne_13',
        speakerId: 'player',
        text: '(독백) ...다음 생에서는, 내가 널 기억할게.',
        nextId: 'ne_14',
      ),
      const DialogueNode(
        id: 'ne_14',
        speakerId: 'player',
        text: '그때는... 제대로 지킬게. 약속해.',
        nextId: 'ne_15',
      ),
      const DialogueNode(
        id: 'ne_15',
        speakerId: 'system',
        text: '[ THE END - 잊혀진 영웅 ]',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'normal_ending_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 트루 엔딩 선택지 등장 ===
  static final trueEndingOption = DialogueSequence(
    id: 'ch6_true_ending_option',
    nodes: [
      const DialogueNode(
        id: 'teo_1',
        speakerId: 'oblivion',
        text: '...잠깐.',
        nextId: 'teo_2',
      ),
      const DialogueNode(
        id: 'teo_2',
        speakerId: 'oblivion',
        text: '네게서 특별한 것이 느껴진다.',
        nextId: 'teo_3',
      ),
      const DialogueNode(
        id: 'teo_3',
        speakerId: 'oblivion',
        text: '...또 다른 방법이 있다.',
        nextId: 'teo_4',
      ),
      const DialogueNode(
        id: 'teo_4',
        speakerId: 'player',
        text: '뭐야? 말해.',
        nextId: 'teo_5',
      ),
      const DialogueNode(
        id: 'teo_5',
        speakerId: 'oblivion',
        text: '너희의 인연. 윤회하는 실.',
        nextId: 'teo_6',
      ),
      const DialogueNode(
        id: 'teo_6',
        speakerId: 'oblivion',
        text: '그것을 대가로 바치면 둘 다 살 수 있다.',
        nextId: 'teo_7',
      ),
      const DialogueNode(
        id: 'teo_7',
        speakerId: 'player',
        text: '윤회하는 실...?',
        nextId: 'teo_8',
      ),
      const DialogueNode(
        id: 'teo_8',
        speakerId: 'oblivion',
        text: '너희는 여러 생을 함께했다.',
        nextId: 'teo_9',
      ),
      const DialogueNode(
        id: 'teo_9',
        speakerId: 'oblivion',
        text: '그 연결을 끊으면, 이번 생의 기억은 유지된다.',
        nextId: 'teo_10',
      ),
      const DialogueNode(
        id: 'teo_10',
        speakerId: 'oblivion',
        text: '하지만 다음 생에서는 영원히 만나지 못한다.',
        nextId: 'teo_11',
      ),
      const DialogueNode(
        id: 'teo_11',
        speakerId: 'player',
        text: '리리아나...',
        nextId: 'teo_12',
        choices: [
          DialogueChoice(
            text: '내가 잊혀질게.',
            nextId: 'teo_refuse',
          ),
          DialogueChoice(
            text: '윤회의 실을 끊자.',
            nextId: 'teo_accept',
          ),
        ],
      ),
      // 거절 (노말 엔딩으로)
      const DialogueNode(
        id: 'teo_refuse',
        speakerId: 'player',
        text: '아니. 다음 생에서도 널 만나고 싶어.',
        nextId: 'teo_refuse_2',
      ),
      const DialogueNode(
        id: 'teo_refuse_2',
        speakerId: 'player',
        text: '내가 대가가 될게.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chose_normal_ending',
          flagValue: true,
        ),
      ),
      // 수락 (트루 엔딩으로)
      const DialogueNode(
        id: 'teo_accept',
        speakerId: 'liliana',
        text: '...',
        nextId: 'teo_accept_2',
      ),
      const DialogueNode(
        id: 'teo_accept_2',
        speakerId: 'liliana',
        text: '...이번 생만으로 충분해.',
        nextId: 'teo_accept_3',
      ),
      const DialogueNode(
        id: 'teo_accept_3',
        speakerId: 'liliana',
        text: '다음 생에서 널 못 만나도... 지금 네가 있으니까.',
        nextId: 'teo_accept_4',
      ),
      const DialogueNode(
        id: 'teo_accept_4',
        speakerId: 'player',
        text: '...그래. 이번 생을 영원처럼 살자.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chose_true_ending',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 트루 엔딩 ===
  static final trueEnding = DialogueSequence(
    id: 'ch6_true_ending',
    nodes: [
      const DialogueNode(
        id: 'te_1',
        speakerId: 'system',
        text: '약속의 반지가 빛난다.',
        nextId: 'te_2',
      ),
      const DialogueNode(
        id: 'te_2',
        speakerId: 'system',
        text: '최초의 기억 결정이 반응한다.',
        nextId: 'te_3',
      ),
      const DialogueNode(
        id: 'te_3',
        speakerId: 'system',
        text: '윤회의 실이 보인다. 수많은 전생의 장면들이 스쳐 지나간다.',
        nextId: 'te_4',
      ),
      const DialogueNode(
        id: 'te_4',
        speakerId: 'system',
        text: '아리온과 리리아나가 함께 실에 손을 뻗는다.',
        nextId: 'te_5',
      ),
      const DialogueNode(
        id: 'te_5',
        speakerId: 'system',
        text: '실이... 끊어진다.',
        nextId: 'te_6',
      ),
      const DialogueNode(
        id: 'te_6',
        speakerId: 'system',
        text: '봉인이 해제된다. 빛이 사방을 가득 채운다.',
        nextId: 'te_7',
      ),
      const DialogueNode(
        id: 'te_7',
        speakerId: 'system',
        text: '두 사람이 서로를 안는다.',
        nextId: 'te_8',
      ),
      const DialogueNode(
        id: 'te_8',
        speakerId: 'system',
        text: '--- 시간이 흐른다 ---',
        nextId: 'te_9',
      ),
      const DialogueNode(
        id: 'te_9',
        speakerId: 'system',
        text: '정원에서 걷는 두 사람.',
        nextId: 'te_10',
      ),
      const DialogueNode(
        id: 'te_10',
        speakerId: 'liliana',
        text: '있잖아, 아리온.',
        nextId: 'te_11',
      ),
      const DialogueNode(
        id: 'te_11',
        speakerId: 'liliana',
        text: '다음 생은 없다며?',
        nextId: 'te_12',
      ),
      const DialogueNode(
        id: 'te_12',
        speakerId: 'player',
        text: '응. 그래서 지금을 영원처럼 살 거야.',
        nextId: 'te_13',
      ),
      const DialogueNode(
        id: 'te_13',
        speakerId: 'liliana',
        text: '(웃으며) ...그거면 충분해.',
        nextId: 'te_14',
      ),
      const DialogueNode(
        id: 'te_14',
        speakerId: 'system',
        text: '두 사람이 손을 잡고 정원을 걸어간다.',
        nextId: 'te_15',
      ),
      const DialogueNode(
        id: 'te_15',
        speakerId: 'system',
        text: '[ THE END - 이번 생의 사랑 ]',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'true_ending_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 환각 이벤트 (Hearts <= 2) ===
  static final hallucination = DialogueSequence(
    id: 'ch6_hallucination',
    nodes: [
      const DialogueNode(
        id: 'hal_1',
        speakerId: 'oblivion',
        text: '...포기해라.',
        nextId: 'hal_2',
      ),
      const DialogueNode(
        id: 'hal_2',
        speakerId: 'oblivion',
        text: '잊혀지는 것은 아프지 않다.',
        nextId: 'hal_3',
      ),
      const DialogueNode(
        id: 'hal_3',
        speakerId: 'oblivion',
        text: '그냥... 사라지는 것뿐.',
        nextId: 'hal_4',
      ),
      const DialogueNode(
        id: 'hal_4',
        speakerId: 'player',
        text: '(아니야... 사라지지 않아. 난...)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'ch6_hallucination_seen',
          flagValue: true,
        ),
      ),
    ],
  );

  /// === 스토리 아이템: 망각의 눈물 획득 ===
  static final itemTear = DialogueSequence(
    id: 'ch6_item_tear',
    nodes: [
      const DialogueNode(
        id: 'item_t_1',
        speakerId: 'player',
        text: '(무색의 결정을 집어들자, 모든 감각이 사라지는 듯한 느낌이 든다.)',
        nextId: 'item_t_2',
      ),
      const DialogueNode(
        id: 'item_t_2',
        speakerId: 'system',
        text: '망각의 눈물. 모든 기억과 망각이 응축되어 있다.',
        nextId: 'item_t_3',
      ),
      const DialogueNode(
        id: 'item_t_3',
        speakerId: 'oblivion',
        text: '(속삭이듯) "...결국 모든 것은 잊혀진다. 너도, 나도, 모든 것이."',
        nextId: 'item_t_4',
      ),
      const DialogueNode(
        id: 'item_t_4',
        speakerId: 'player',
        text: '(아니야... 잊지 않을 거야. 절대로.)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_oblivion_tear',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 챕터 6 대화 시퀀스
  static List<DialogueSequence> get all => [
    oblivionGate,
    forgottenPath,
    forgottenSage,
    lilianaReunion,
    oblivionEncounter,
    oblivionPhase2,
    oblivionPhase3,
    thirdHeartAwakening,
    oblivionPhase4,
    normalEndingChoice,
    normalEnding,
    trueEndingOption,
    trueEnding,
    hallucination,
    // 스토리 아이템
    itemTear,
  ];
}

/// 잊혀진 현자 화자 정보
const forgottenSageSpeaker = Speaker(
  id: 'forgotten_sage',
  name: '잊혀진 현자',
  defaultPortrait: 'portraits/forgotten_sage.png',
);

/// 망각의 화신 화자 정보
const oblivionSpeaker = Speaker(
  id: 'oblivion',
  name: '망각의 화신',
  defaultPortrait: 'portraits/oblivion.png',
);

/// 잊혀진 목소리 화자 정보
const forgottenVoiceSpeaker = Speaker(
  id: 'forgotten_voice',
  name: '???',
);

/// 리리아나 화자 정보 (재회 시)
const lilianaSpeaker = Speaker(
  id: 'liliana',
  name: '리리아나',
  defaultPortrait: 'portraits/liliana.png',
);
