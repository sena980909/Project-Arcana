/// Arcana: The Three Hearts - 환경 스토리텔링 대화
/// 벽화, 비문, 제단 등 상호작용 오브젝트 대화
library;

import '../model/dialogue.dart';

/// 환경 스토리텔링 대화 시퀀스 모음
class EnvironmentDialogues {
  EnvironmentDialogues._();

  // === 챕터 1: 잊혀진 숲 ===

  /// 숲의 벽화 - 약속의 장면
  static final ch1Mural = DialogueSequence(
    id: 'env_ch1_mural',
    nodes: [
      const DialogueNode(
        id: 'mural_1',
        speakerId: 'system',
        text: '오래된 벽화가 있다. 두 사람이 나무 아래서 손을 잡고 있는 모습.',
        nextId: 'mural_2',
      ),
      const DialogueNode(
        id: 'mural_2',
        speakerId: 'player',
        text: '(희미하게 글씨가 새겨져 있다... "영원히 함께")',
        nextId: 'mural_3',
      ),
      const DialogueNode(
        id: 'mural_3',
        speakerId: 'system',
        text: '벽화 아래에 마른 꽃잎들이 흩어져 있다. 누군가 오래전부터 이곳에 꽃을 놓았던 것 같다.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch1_mural',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 숲의 비문 - 정령의 경고
  static final ch1Inscription = DialogueSequence(
    id: 'env_ch1_inscription',
    nodes: [
      const DialogueNode(
        id: 'insc_1',
        speakerId: 'system',
        text: '이끼 낀 돌에 고대 문자가 새겨져 있다.',
        nextId: 'insc_2',
      ),
      const DialogueNode(
        id: 'insc_2',
        speakerId: 'system',
        text: '"잊혀진 자의 눈물을 밟지 말라. 슬픔은 전염된다."',
        nextId: 'insc_3',
      ),
      const DialogueNode(
        id: 'insc_3',
        speakerId: 'player',
        text: '(재의 상인이 말한 것과 같다... 눈물에 닿지 말라고.)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch1_inscription',
          flagValue: true,
        ),
      ),
    ],
  );

  // === 챕터 2: 무너진 성채 ===

  /// 성채의 초상화 - 왕과 왕비
  static final ch2Mural = DialogueSequence(
    id: 'env_ch2_mural',
    nodes: [
      const DialogueNode(
        id: 'portrait_1',
        speakerId: 'system',
        text: '찢어진 초상화가 벽에 걸려 있다. 왕관을 쓴 남자와 아름다운 여인.',
        nextId: 'portrait_2',
      ),
      const DialogueNode(
        id: 'portrait_2',
        speakerId: 'system',
        text: '여인의 얼굴 부분만 칼로 난도질한 듯 훼손되어 있다.',
        nextId: 'portrait_3',
      ),
      const DialogueNode(
        id: 'portrait_3',
        speakerId: 'player',
        text: '(무슨 일이 있었던 걸까... 이런 분노는...)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch2_mural',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 성채의 비문 - 배신의 기록
  static final ch2Inscription = DialogueSequence(
    id: 'env_ch2_inscription',
    nodes: [
      const DialogueNode(
        id: 'record_1',
        speakerId: 'system',
        text: '옥좌 옆에 금속판이 있다. 왕국의 연대기인 것 같다.',
        nextId: 'record_2',
      ),
      const DialogueNode(
        id: 'record_2',
        speakerId: 'system',
        text: '"제 127년, 왕비가 기사단장과 함께 사라지다. 왕, 칠일 동안 흐느끼다."',
        nextId: 'record_3',
      ),
      const DialogueNode(
        id: 'record_3',
        speakerId: 'system',
        text: '"제 127년 8일, 왕이 모든 거울을 부수라 명하다. 그녀의 얼굴을 보지 않기 위해."',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch2_inscription',
          flagValue: true,
        ),
      ),
    ],
  );

  // === 챕터 3: 침묵의 성당 ===

  /// 성당의 스테인드글라스 - 성녀의 이야기
  static final ch3Mural = DialogueSequence(
    id: 'env_ch3_mural',
    nodes: [
      const DialogueNode(
        id: 'glass_1',
        speakerId: 'system',
        text: '깨진 스테인드글라스 창문. 한 여인이 기도하는 모습이 그려져 있다.',
        nextId: 'glass_2',
      ),
      const DialogueNode(
        id: 'glass_2',
        speakerId: 'system',
        text: '여인의 입에서 빛이 나오고 있다. 하지만 다음 장면에서 빛은 사라지고...',
        nextId: 'glass_3',
      ),
      const DialogueNode(
        id: 'glass_3',
        speakerId: 'system',
        text: '마지막 창문은 완전히 검게 칠해져 있다. 침묵의 끝.',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch3_mural',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 성당의 고해실 기록
  static final ch3Inscription = DialogueSequence(
    id: 'env_ch3_inscription',
    nodes: [
      const DialogueNode(
        id: 'confess_1',
        speakerId: 'system',
        text: '고해실 벽에 수많은 이름이 새겨져 있다.',
        nextId: 'confess_2',
      ),
      const DialogueNode(
        id: 'confess_2',
        speakerId: 'system',
        text: '모두 같은 문장으로 끝난다. "침묵 속에서 용서받으리라."',
        nextId: 'confess_3',
      ),
      const DialogueNode(
        id: 'confess_3',
        speakerId: 'player',
        text: '(용서... 누구의 용서를 바란 걸까?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch3_inscription',
          flagValue: true,
        ),
      ),
    ],
  );

  // === 챕터 4: 피의 정원 ===

  /// 정원의 석상 - 연인의 모습
  static final ch4Statue = DialogueSequence(
    id: 'env_ch4_statue',
    nodes: [
      const DialogueNode(
        id: 'statue_1',
        speakerId: 'system',
        text: '정원 중앙에 두 사람의 석상이 있다. 서로를 바라보며 미소짓는 모습.',
        nextId: 'statue_2',
      ),
      const DialogueNode(
        id: 'statue_2',
        speakerId: 'system',
        text: '석상 받침대에 글씨가 새겨져 있다. "우리의 사랑은 시들지 않으리."',
        nextId: 'statue_3',
      ),
      const DialogueNode(
        id: 'statue_3',
        speakerId: 'player',
        text: '(하지만 주변의 장미는 모두 검게 시들어 있다...)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch4_statue',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 정원의 일기장
  static final ch4Inscription = DialogueSequence(
    id: 'env_ch4_inscription',
    nodes: [
      const DialogueNode(
        id: 'diary_1',
        speakerId: 'system',
        text: '시든 장미 사이에 낡은 일기장이 있다. 대부분의 페이지가 피로 물들어 있다.',
        nextId: 'diary_2',
      ),
      const DialogueNode(
        id: 'diary_2',
        speakerId: 'system',
        text: '읽을 수 있는 마지막 문장: "그가 날 떠났다. 하지만 난 기다릴 거야. 영원히."',
        nextId: 'diary_3',
      ),
      const DialogueNode(
        id: 'diary_3',
        speakerId: 'player',
        text: '(리리아나... 이것이 네 이야기인 거야?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch4_inscription',
          flagValue: true,
        ),
      ),
    ],
  );

  // === 챕터 5: 기억의 심연 ===

  /// 심연의 거울
  static final ch5Mirror = DialogueSequence(
    id: 'env_ch5_mirror',
    nodes: [
      const DialogueNode(
        id: 'mirror_1',
        speakerId: 'system',
        text: '깨진 거울 조각들이 벽에 붙어 있다. 각 조각에 다른 모습이 비친다.',
        nextId: 'mirror_2',
      ),
      const DialogueNode(
        id: 'mirror_2',
        speakerId: 'system',
        text: '어린아이... 젊은 청년... 노인... 모두 같은 눈을 하고 있다.',
        nextId: 'mirror_3',
      ),
      const DialogueNode(
        id: 'mirror_3',
        speakerId: 'player',
        text: '(이건... 나의 모습들인가? 과거와 미래의...)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch5_mirror',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 심연의 기억 조각
  static final ch5Inscription = DialogueSequence(
    id: 'env_ch5_inscription',
    nodes: [
      const DialogueNode(
        id: 'memory_1',
        speakerId: 'system',
        text: '공중에 떠있는 빛나는 글자들. 누군가의 기억이 텍스트로 남은 것 같다.',
        nextId: 'memory_2',
      ),
      const DialogueNode(
        id: 'memory_2',
        speakerId: 'system',
        text: '"내가 한 일을 용서해줘. 널 지키려고 한 거야. 제발..."',
        nextId: 'memory_3',
      ),
      const DialogueNode(
        id: 'memory_3',
        speakerId: 'player',
        text: '(이 목소리... 어디선가 들은 것 같은데...)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch5_inscription',
          flagValue: true,
        ),
      ),
    ],
  );

  // === 챕터 6: 망각의 옥좌 ===

  /// 옥좌의 기념비
  static final ch6Memorial = DialogueSequence(
    id: 'env_ch6_memorial',
    nodes: [
      const DialogueNode(
        id: 'memorial_1',
        speakerId: 'system',
        text: '수천 개의 이름이 새겨진 거대한 기념비. 모두 잊혀진 자들의 이름.',
        nextId: 'memorial_2',
      ),
      const DialogueNode(
        id: 'memorial_2',
        speakerId: 'system',
        text: '기념비 꼭대기에 아직 새겨지지 않은 빈 공간이 있다.',
        nextId: 'memorial_3',
      ),
      const DialogueNode(
        id: 'memorial_3',
        speakerId: 'player',
        text: '(저 자리가... 나를 위한 건가?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch6_memorial',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 옥좌의 비문
  static final ch6Inscription = DialogueSequence(
    id: 'env_ch6_inscription',
    nodes: [
      const DialogueNode(
        id: 'throne_1',
        speakerId: 'system',
        text: '옥좌 뒤에 새겨진 글씨. 반쯤 지워져 읽기 어렵다.',
        nextId: 'throne_2',
      ),
      const DialogueNode(
        id: 'throne_2',
        speakerId: 'system',
        text: '"...세 개의 심장이 하나가 될 때...기억은 돌아오리라..."',
        nextId: 'throne_3',
      ),
      const DialogueNode(
        id: 'throne_3',
        speakerId: 'player',
        text: '(세 개의 심장... 그것이 나를 되찾는 열쇠인 건가?)',
        trigger: DialogueTrigger(
          type: TriggerType.setFlag,
          flagName: 'seen_ch6_inscription',
          flagValue: true,
        ),
      ),
    ],
  );

  /// 모든 환경 대화 시퀀스
  static List<DialogueSequence> get all => [
    // 챕터 1
    ch1Mural,
    ch1Inscription,
    // 챕터 2
    ch2Mural,
    ch2Inscription,
    // 챕터 3
    ch3Mural,
    ch3Inscription,
    // 챕터 4
    ch4Statue,
    ch4Inscription,
    // 챕터 5
    ch5Mirror,
    ch5Inscription,
    // 챕터 6
    ch6Memorial,
    ch6Inscription,
  ];
}
