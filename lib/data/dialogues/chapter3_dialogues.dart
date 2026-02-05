/// Arcana: The Three Hearts - 챕터 3 대화 시퀀스
/// 침묵의 성당 (The Silent Cathedral)
library;

import '../model/dialogue.dart';

/// 챕터 3 대화 목록
class Chapter3Dialogues {
  Chapter3Dialogues._();

  // === 말 없는 수녀 (Voiceless Nun) ===

  /// 말 없는 수녀 첫 만남
  static final voicelessNunFirst = DialogueSequence(
    id: 'voiceless_nun_first',
    nodes: [
      const DialogueNode(
        id: 'vn1',
        speakerId: 'system',
        text: '*꿰맨 입술을 가진 수녀가 서 있다.*',
        nextId: 'vn2',
      ),
      const DialogueNode(
        id: 'vn2',
        speakerId: 'voiceless_nun',
        text: '...',
        nextId: 'vn3',
      ),
      const DialogueNode(
        id: 'vn3',
        speakerId: 'system',
        text: '*수녀가 낡은 양피지와 깃펜을 꺼낸다.*',
        nextId: 'vn4',
      ),
      const DialogueNode(
        id: 'vn4',
        speakerId: 'voiceless_nun',
        text: '[글을 쓴다] "...당신도 죄인인가요?"',
        nextId: 'vn5',
      ),
      DialogueNode(
        id: 'vn5',
        speakerId: 'system',
        text: '*당신은 수녀의 질문에 어떻게 대답할 것인가?*',
        choices: [
          const DialogueChoice(
            text: '"모르겠다. 기억이 없어서."',
            nextId: 'vn6a',
          ),
          const DialogueChoice(
            text: '"아니."',
            nextId: 'vn6b',
          ),
          const DialogueChoice(
            text: '(대답하지 않는다)',
            nextId: 'vn6c',
          ),
        ],
      ),
      // 선택 분기 A: 모르겠다
      const DialogueNode(
        id: 'vn6a',
        speakerId: 'system',
        text: '*수녀가 천천히 고개를 끄덕인다.*',
        nextId: 'vn7',
      ),
      // 선택 분기 B: 아니
      const DialogueNode(
        id: 'vn6b',
        speakerId: 'system',
        text: '*수녀가 고개를 젓는다. 슬픈 눈.*',
        nextId: 'vn7',
      ),
      // 선택 분기 C: 침묵
      const DialogueNode(
        id: 'vn6c',
        speakerId: 'system',
        text: '*수녀가 이해한다는 듯 미소 짓는다.*',
        nextId: 'vn7',
      ),
      const DialogueNode(
        id: 'vn7',
        speakerId: 'voiceless_nun',
        text: '[글을 쓴다] "이 성당은... 고백하지 않은 죄를 찾아내요."',
        nextId: 'vn8',
      ),
      const DialogueNode(
        id: 'vn8',
        speakerId: 'voiceless_nun',
        text: '[글을 쓴다] "조심하세요. 당신의 죄도... 찾아낼 거예요."',
        nextId: 'vn9',
      ),
      const DialogueNode(
        id: 'vn9',
        speakerId: 'system',
        text: '*수녀가 성당 안쪽을 가리킨다.*',
        nextId: 'vn10',
      ),
      const DialogueNode(
        id: 'vn10',
        speakerId: 'voiceless_nun',
        text: '[글을 쓴다] "고해실을 지나면... 지하 묘지. 그 너머에 \'그분\'이 계세요."',
        nextId: 'vn11',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_voiceless_nun',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'vn11',
        speakerId: 'system',
        text: '*수녀의 꿰맨 입술이 떨린다. 말하고 싶어도 말할 수 없는 고통.*',
      ),
    ],
  );

  /// 말 없는 수녀 기본 대화
  static final voicelessNunDefault = DialogueSequence(
    id: 'voiceless_nun_default',
    nodes: [
      const DialogueNode(
        id: 'vnd1',
        speakerId: 'voiceless_nun',
        text: '...',
        nextId: 'vnd2',
      ),
      const DialogueNode(
        id: 'vnd2',
        speakerId: 'system',
        text: '*수녀가 슬픈 눈으로 당신을 바라본다.*',
        nextId: 'vnd3',
      ),
      const DialogueNode(
        id: 'vnd3',
        speakerId: 'voiceless_nun',
        text: '[글을 쓴다] "진실을 찾으려면... 침묵을 견뎌야 해요."',
      ),
    ],
  );

  // === 배교한 사제 (Apostate Priest) ===

  /// 배교한 사제 첫 만남
  static final apostatePriestFirst = DialogueSequence(
    id: 'apostate_priest_first',
    nodes: [
      const DialogueNode(
        id: 'ap1',
        speakerId: 'apostate_priest',
        text: '크흡...! 또 왔군. 신을 찾으러 온 바보가.',
        nextId: 'ap2',
      ),
      const DialogueNode(
        id: 'ap2',
        speakerId: 'system',
        text: '*찢어진 사제복을 입은 남자가 어둠 속에서 나타난다. 한쪽 눈이 멀었고, 온몸에 상처가 있다.*',
        nextId: 'ap3',
      ),
      const DialogueNode(
        id: 'ap3',
        speakerId: 'apostate_priest',
        text: '신을 믿었어. 평생을.',
        nextId: 'ap4',
      ),
      const DialogueNode(
        id: 'ap4',
        speakerId: 'apostate_priest',
        text: '기도하고, 금식하고, 모든 걸 바쳤지.',
        nextId: 'ap5',
      ),
      const DialogueNode(
        id: 'ap5',
        speakerId: 'apostate_priest',
        text: '그런데 전염병이 왔을 때, 신은 뭘 했을까?',
        nextId: 'ap6',
      ),
      const DialogueNode(
        id: 'ap6',
        speakerId: 'apostate_priest',
        text: '아무것도. 아무것도 안 했어.',
        nextId: 'ap7',
      ),
      const DialogueNode(
        id: 'ap7',
        speakerId: 'apostate_priest',
        text: '실렌시아 성녀님도 같은 걸 느꼈겠지.',
        nextId: 'ap8',
      ),
      const DialogueNode(
        id: 'ap8',
        speakerId: 'apostate_priest',
        text: '다만... 그녀는 나보다 강했어. 아니, 미쳤다고 해야 하나.',
        nextId: 'ap9',
      ),
      const DialogueNode(
        id: 'ap9',
        speakerId: 'apostate_priest',
        text: '"신이 대답 안 하면 내가 신이 되겠다"고 했거든.',
        nextId: 'ap10',
      ),
      const DialogueNode(
        id: 'ap10',
        speakerId: 'apostate_priest',
        text: '...미친 소리 같지?',
        nextId: 'ap11',
      ),
      const DialogueNode(
        id: 'ap11',
        speakerId: 'apostate_priest',
        text: '하지만 이해돼. 난 그녀를 이해해.',
        nextId: 'ap12',
      ),
      const DialogueNode(
        id: 'ap12',
        speakerId: 'apostate_priest',
        text: '넌 저 위로 올라갈 생각이지?',
        nextId: 'ap13',
      ),
      const DialogueNode(
        id: 'ap13',
        speakerId: 'system',
        text: '*사제가 성소를 가리킨다.*',
        nextId: 'ap14',
      ),
      const DialogueNode(
        id: 'ap14',
        speakerId: 'apostate_priest',
        text: '조언 하나 해줄게. 그녀의 "자비"를 믿지 마.',
        nextId: 'ap15',
      ),
      const DialogueNode(
        id: 'ap15',
        speakerId: 'apostate_priest',
        text: '진짜 공포는... 소리가 사라질 때 시작돼.',
        nextId: 'ap16',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'met_apostate_priest',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'ap16',
        speakerId: 'system',
        text: '*사제가 자조적으로 웃으며 어둠 속으로 사라진다.*',
      ),
    ],
  );

  /// 배교한 사제 기본 대화
  static final apostatePriestDefault = DialogueSequence(
    id: 'apostate_priest_default',
    nodes: [
      const DialogueNode(
        id: 'apd1',
        speakerId: 'apostate_priest',
        text: '아직 여기 있어? 호호, 용감하군.',
        nextId: 'apd2',
      ),
      const DialogueNode(
        id: 'apd2',
        speakerId: 'apostate_priest',
        text: '...아니면 나처럼 도망칠 곳이 없거나.',
      ),
    ],
  );

  // === 고해실 환경 스토리텔링 ===

  /// 고해실 발견
  static final ch3Confessional = DialogueSequence(
    id: 'ch3_confessional',
    nodes: [
      const DialogueNode(
        id: 'conf1',
        speakerId: 'system',
        text: '*낡은 고해실에서 속삭임이 들린다.*',
        nextId: 'conf2',
      ),
      const DialogueNode(
        id: 'conf2',
        speakerId: 'unknown',
        text: '[먼 목소리] "저는... 거짓말을 했습니다..."',
        nextId: 'conf3',
      ),
      const DialogueNode(
        id: 'conf3',
        speakerId: 'unknown',
        text: '[먼 목소리] "가족을 버렸습니다..."',
        nextId: 'conf4',
      ),
      const DialogueNode(
        id: 'conf4',
        speakerId: 'unknown',
        text: '[먼 목소리] "사랑하는 사람을 배신했습니다..."',
        nextId: 'conf5',
      ),
      const DialogueNode(
        id: 'conf5',
        speakerId: 'system',
        text: '*갑자기 익숙한 목소리가 들린다.*',
        nextId: 'conf6',
      ),
      const DialogueNode(
        id: 'conf6',
        speakerId: 'unknown',
        text: '"나는... 죽였습니다."',
        nextId: 'conf7',
      ),
      const DialogueNode(
        id: 'conf7',
        speakerId: 'unknown',
        text: '"사랑하는 사람을..."',
        nextId: 'conf8',
      ),
      const DialogueNode(
        id: 'conf8',
        speakerId: 'unknown',
        text: '"지키려고 했는데..."',
        nextId: 'conf9',
      ),
      const DialogueNode(
        id: 'conf9',
        speakerId: 'unknown',
        text: '"결국 내 손으로..."',
        nextId: 'conf10',
      ),
      const DialogueNode(
        id: 'conf10',
        speakerId: 'player',
        text: '...이 목소리... 나야?',
        nextId: 'conf11',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'heard_confessional_voices',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'conf11',
        speakerId: 'system',
        text: '*머릿속이 아프다. 무언가 떠오를 것 같은데... 잡히지 않는다.*',
      ),
    ],
  );

  // === 환청/환영 ===

  /// 고백 강요 환청 (Hearts <= 2)
  static final ch3ConfessionHallucination = DialogueSequence(
    id: 'ch3_confession_hallucination',
    nodes: [
      const DialogueNode(
        id: 'hall1',
        speakerId: 'unknown',
        text: '[낮은 속삭임] 고백해...',
        nextId: 'hall2',
      ),
      const DialogueNode(
        id: 'hall2',
        speakerId: 'unknown',
        text: '[낮은 속삭임] 네 죄를 말해라...',
        nextId: 'hall3',
      ),
      const DialogueNode(
        id: 'hall3',
        speakerId: 'player',
        text: '...누구야?',
        nextId: 'hall4',
      ),
      const DialogueNode(
        id: 'hall4',
        speakerId: 'unknown',
        text: '[낮은 속삭임] 넌 알고 있어... 네가 뭘 했는지...',
        nextId: 'hall5',
      ),
      const DialogueNode(
        id: 'hall5',
        speakerId: 'unknown',
        text: '[낮은 속삭임] 네 손에 묻은 피를...',
        nextId: 'hall6',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'heard_confession_hallucination',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'hall6',
        speakerId: 'system',
        text: '*목소리가 희미해진다. 하지만 가슴 깊은 곳에서 뭔가 꿈틀거린다.*',
      ),
    ],
  );

  // === 보스: 마더 실렌시아 ===

  /// 실렌시아 조우
  static final ch3SilenciaEncounter = DialogueSequence(
    id: 'ch3_silencia_encounter',
    nodes: [
      const DialogueNode(
        id: 'sil1',
        speakerId: 'system',
        text: '*황금 제단 위에 그녀가 서 있다. 얼굴 절반은 금빛 가면, 등 뒤로 부러진 6개의 날개.*',
        nextId: 'sil2',
      ),
      const DialogueNode(
        id: 'sil2',
        speakerId: 'silencia',
        text: '어서 와, 길 잃은 양이여.',
        nextId: 'sil3',
      ),
      const DialogueNode(
        id: 'sil3',
        speakerId: 'silencia',
        text: '고백하러 왔니? 아니면 구원받으러?',
        nextId: 'sil4',
      ),
      const DialogueNode(
        id: 'sil4',
        speakerId: 'player',
        text: '당신이... 침묵의 성녀?',
        nextId: 'sil5',
      ),
      const DialogueNode(
        id: 'sil5',
        speakerId: 'silencia',
        text: '성녀? 호호, 그 이름은 버렸어.',
        nextId: 'sil6',
      ),
      const DialogueNode(
        id: 'sil6',
        speakerId: 'silencia',
        text: '신은 여기 없어. 신은 대답하지 않았으니까.',
        nextId: 'sil7',
      ),
      const DialogueNode(
        id: 'sil7',
        speakerId: 'silencia',
        text: '그래서 내가 대신하고 있지.',
        nextId: 'sil8',
      ),
      const DialogueNode(
        id: 'sil8',
        speakerId: 'silencia',
        text: '자비롭게. 심판하며.',
        nextId: 'sil9',
      ),
      const DialogueNode(
        id: 'sil9',
        speakerId: 'system',
        text: '*실렌시아가 팔을 벌린다. 부러진 날개가 떨린다.*',
        nextId: 'sil10',
      ),
      const DialogueNode(
        id: 'sil10',
        speakerId: 'silencia',
        text: '자, 이리 와. 내 자비를 받아라.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'silencia_encounter_complete',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 실렌시아 페이즈 2 전환 (심판)
  static final ch3SilenciaPhase2 = DialogueSequence(
    id: 'ch3_silencia_phase2',
    nodes: [
      const DialogueNode(
        id: 'sp2_1',
        speakerId: 'system',
        text: '*실렌시아의 표정이 일그러진다.*',
        nextId: 'sp2_2',
      ),
      const DialogueNode(
        id: 'sp2_2',
        speakerId: 'silencia',
        text: '...자비를 거부하겠다?',
        nextId: 'sp2_3',
      ),
      const DialogueNode(
        id: 'sp2_3',
        speakerId: 'silencia',
        text: '그렇다면... 심판을 내리겠다!',
        nextId: 'sp2_4',
      ),
      const DialogueNode(
        id: 'sp2_4',
        speakerId: 'system',
        text: '*실렌시아의 눈에서 황금빛이 터져나온다. 제단이 빛으로 가득 찬다.*',
      ),
    ],
  );

  /// 실렌시아 페이즈 3 전환 (침묵)
  static final ch3SilenciaPhase3 = DialogueSequence(
    id: 'ch3_silencia_phase3',
    nodes: [
      const DialogueNode(
        id: 'sp3_1',
        speakerId: 'system',
        text: '*갑자기 모든 소리가 사라진다.*',
        nextId: 'sp3_2',
      ),
      const DialogueNode(
        id: 'sp3_2',
        speakerId: 'system',
        text: '*실렌시아의 입이 움직이지만, 아무 소리도 들리지 않는다.*',
        nextId: 'sp3_3',
      ),
      const DialogueNode(
        id: 'sp3_3',
        speakerId: 'system',
        text: '[화면에 글자만 떠오른다]',
        nextId: 'sp3_4',
      ),
      const DialogueNode(
        id: 'sp3_4',
        speakerId: 'silencia',
        text: '"이것이... 진정한 침묵..."',
        nextId: 'sp3_5',
      ),
      const DialogueNode(
        id: 'sp3_5',
        speakerId: 'silencia',
        text: '"신이 우리에게 준 대답..."',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'silencia_phase3_started',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 실렌시아 처치
  static final ch3SilenciaDefeat = DialogueSequence(
    id: 'ch3_silencia_defeat',
    nodes: [
      const DialogueNode(
        id: 'sd1',
        speakerId: 'system',
        text: '*소리가 돌아온다. 실렌시아가 무릎을 꿇는다.*',
        nextId: 'sd2',
      ),
      const DialogueNode(
        id: 'sd2',
        speakerId: 'silencia',
        text: '...들려.',
        nextId: 'sd3',
      ),
      const DialogueNode(
        id: 'sd3',
        speakerId: 'silencia',
        text: '신의... 목소리가...',
        nextId: 'sd4',
      ),
      const DialogueNode(
        id: 'sd4',
        speakerId: 'system',
        text: '*실렌시아의 금빛 가면에 금이 간다.*',
        nextId: 'sd5',
      ),
      const DialogueNode(
        id: 'sd5',
        speakerId: 'silencia',
        text: '아... 신은... 침묵한 게 아니었어...',
        nextId: 'sd6',
      ),
      const DialogueNode(
        id: 'sd6',
        speakerId: 'silencia',
        text: '우리가... 듣지 않았을 뿐...',
        nextId: 'sd7',
      ),
      const DialogueNode(
        id: 'sd7',
        speakerId: 'silencia',
        text: '용서해줘... 내 신이여...',
        nextId: 'sd8',
      ),
      const DialogueNode(
        id: 'sd8',
        speakerId: 'system',
        text: '*실렌시아가 빛의 입자가 되어 흩어진다.*',
        nextId: 'sd9',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'silencia_defeated',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'sd9',
        speakerId: 'system',
        text: '『실렌시아의 눈물』을 획득했다.\n『침묵의 성당의 아르카나』를 획득했다.',
      ),
    ],
  );

  /// 기억 회복 (컷씬)
  static final ch3MemoryRecovery = DialogueSequence(
    id: 'ch3_memory_recovery',
    nodes: [
      const DialogueNode(
        id: 'mem1',
        speakerId: 'system',
        text: '*머릿속이 갈라지는 듯한 고통.*',
        nextId: 'mem2',
      ),
      const DialogueNode(
        id: 'mem2',
        speakerId: 'system',
        text: '*비 오는 밤. 어두운 골목.*',
        nextId: 'mem3',
      ),
      const DialogueNode(
        id: 'mem3',
        speakerId: 'system',
        text: '*누군가의 손을 잡고 있다.*',
        nextId: 'mem4',
      ),
      const DialogueNode(
        id: 'mem4',
        speakerId: 'memory_voice',
        text: '"괜찮아, 내가 지켜줄게."',
        nextId: 'mem5',
      ),
      const DialogueNode(
        id: 'mem5',
        speakerId: 'system',
        text: '*검을 휘두르는 팔.*',
        nextId: 'mem6',
      ),
      const DialogueNode(
        id: 'mem6',
        speakerId: 'system',
        text: '*피.*',
        nextId: 'mem7',
      ),
      const DialogueNode(
        id: 'mem7',
        speakerId: 'unknown',
        text: '...왜?',
        nextId: 'mem8',
      ),
      const DialogueNode(
        id: 'mem8',
        speakerId: 'system',
        text: '*쓰러지는 누군가.*',
        nextId: 'mem9',
      ),
      const DialogueNode(
        id: 'mem9',
        speakerId: 'system',
        text: '*그 얼굴은... 흐릿해서 보이지 않는다.*',
        nextId: 'mem10',
      ),
      const DialogueNode(
        id: 'mem10',
        speakerId: 'player',
        text: '...내가... 그 사람을...',
        nextId: 'mem11',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'first_memory_recovered',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'mem11',
        speakerId: 'system',
        text: '*기억이 끊긴다. 하지만 확실한 건 하나.*',
        nextId: 'mem12',
      ),
      const DialogueNode(
        id: 'mem12',
        speakerId: 'system',
        text: '*당신은 사랑하는 사람을 당신의 손으로 죽였다.*',
      ),
    ],
  );

  /// 에필로그
  static final ch3Epilogue = DialogueSequence(
    id: 'ch3_epilogue',
    nodes: [
      const DialogueNode(
        id: 'epi1',
        speakerId: 'system',
        text: '*성당이 무너지기 시작한다.*',
        nextId: 'epi2',
      ),
      const DialogueNode(
        id: 'epi2',
        speakerId: 'player',
        text: '...나는 뭘 한 거지.',
        nextId: 'epi3',
      ),
      const DialogueNode(
        id: 'epi3',
        speakerId: 'player',
        text: '왜... 죽였지?',
        nextId: 'epi4',
      ),
      const DialogueNode(
        id: 'epi4',
        speakerId: 'system',
        text: '*실렌시아의 마지막 말이 머릿속에 맴돈다.*',
        nextId: 'epi5',
      ),
      const DialogueNode(
        id: 'epi5',
        speakerId: 'silencia_echo',
        text: '[속삭임] "피의 정원에서... 그녀가 기다린다..."',
        nextId: 'epi6',
      ),
      const DialogueNode(
        id: 'epi6',
        speakerId: 'player',
        text: '피의 정원...? 그녀...?',
        nextId: 'epi7',
      ),
      const DialogueNode(
        id: 'epi7',
        speakerId: 'system',
        text: '*출구 너머로 붉은 꽃잎이 흩날린다.*',
        nextId: 'epi8',
      ),
      const DialogueNode(
        id: 'epi8',
        speakerId: 'system',
        text: '『세 개의 심장은 세 번의 죄』',
        nextId: 'epi9',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'chapter3_complete',
          flagValue: true,
        ),
      ),
      const DialogueNode(
        id: 'epi9',
        speakerId: 'system',
        text: '*다음 목적지: 피의 정원*',
      ),
    ],
  );

  /// === 스토리 아이템: 첫 번째 기억 조각 획득 ===
  static final itemMemory = DialogueSequence(
    id: 'ch3_item_memory',
    nodes: [
      const DialogueNode(
        id: 'item_m_1',
        speakerId: 'player',
        text: '(빛나는 조각을 손에 들자, 머릿속에 영상이 스쳐간다.)',
        nextId: 'item_m_2',
      ),
      const DialogueNode(
        id: 'item_m_2',
        speakerId: 'system',
        text: '비 오는 밤... 누군가와 함께 걷고 있다. 그 사람의 얼굴은... 보이지 않는다.',
        nextId: 'item_m_3',
      ),
      const DialogueNode(
        id: 'item_m_3',
        speakerId: 'player',
        text: '(이건... 나의 기억인가?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'found_memory_fragment',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 챕터 3 대화 시퀀스
  static final List<DialogueSequence> all = [
    // NPC 대화
    voicelessNunFirst,
    voicelessNunDefault,
    apostatePriestFirst,
    apostatePriestDefault,
    // 환경 스토리텔링
    ch3Confessional,
    // 환청
    ch3ConfessionHallucination,
    // 보스 대화
    ch3SilenciaEncounter,
    ch3SilenciaPhase2,
    ch3SilenciaPhase3,
    ch3SilenciaDefeat,
    // 기억 회복
    ch3MemoryRecovery,
    // 에필로그
    ch3Epilogue,
    // 스토리 아이템
    itemMemory,
  ];
}
