/// Arcana: The Three Hearts - 메인 게임 클래스
/// Flame 기반 게임 엔진 설정
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../data/dialogues/chapter1_dialogues.dart';
import '../data/dialogues/chapter2_dialogues.dart';
import '../data/dialogues/chapter3_dialogues.dart';
import '../data/dialogues/chapter4_dialogues.dart';
import '../data/dialogues/chapter5_dialogues.dart';
import '../data/dialogues/chapter6_dialogues.dart';
import '../data/dialogues/environment_dialogues.dart';
import '../data/model/dialogue.dart';
import '../data/model/item.dart';
import '../data/model/npc.dart';
import '../data/model/room.dart';
import '../providers/game_state_provider.dart';
import 'characters/npc_component.dart';
import 'characters/player.dart';
import 'decorations/dropped_item.dart';
import 'enemies/base_enemy.dart';
import 'enemies/boss_baldur.dart';
import 'enemies/boss_liliana.dart';
import 'enemies/boss_oblivion.dart';
import 'enemies/boss_shadow.dart';
import 'enemies/boss_silencia.dart';
import 'enemies/boss_yggdra.dart';
import 'enemies/dummy_enemy.dart';
import 'managers/audio_manager.dart';
import 'managers/dialogue_manager.dart';
import 'managers/dungeon_manager.dart';
import 'managers/skill_manager.dart';
import '../data/models/skill_data.dart';

/// 아이템 획득 콜백 타입
typedef OnItemCollected = void Function(Item item);

/// 게임 오버 콜백 타입
typedef OnGameOverCallback = void Function();

/// 적 처치 콜백 타입
typedef OnEnemyKilled = void Function();

/// 대화 노드 변경 콜백 타입
typedef OnDialogueNodeChanged = void Function(DialogueNode node);

/// 트리거 실행 콜백 타입
typedef OnTriggerExecuted = void Function(DialogueTrigger trigger);

/// 승리 콜백 타입 (엔딩 타입 포함)
typedef OnVictoryCallback = void Function(bool isTrueEnding);

/// 보스 시작 콜백 타입
typedef OnBossStartCallback = void Function(double maxHealth, String bossName);

/// 메인 게임 클래스
class ArcanaGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection
    implements ArcanaGameInterface {
  ArcanaGame({
    this.onItemCollected,
    this.onGameOverCallback,
    this.onEnemyKilled,
    this.onRoomChanged,
    this.onFloorCleared,
    this.onBossDefeated,
    this.onBossStart,
    this.onVictory,
    this.onDialogueStart,
    this.onDialogueEnd,
    this.onDialogueNodeChanged,
    this.onTriggerExecuted,
    required this.gameState,
    required this.inventoryItemIds,
    this.initialFloor = 1,
    this.initialHearts = 3,
    this.initialHealth = 100,
    this.initialMaxHealth = 100,
  });

  /// 시작 층 (이어하기용)
  final int initialFloor;

  /// 시작 하트 수 (이어하기용)
  final int initialHearts;

  /// 시작 체력 (이어하기용)
  final double initialHealth;

  /// 시작 최대 체력 (이어하기용)
  final double initialMaxHealth;

  /// 아이템 획득 콜백
  final OnItemCollected? onItemCollected;

  /// 게임 오버 콜백
  final OnGameOverCallback? onGameOverCallback;

  /// 적 처치 콜백
  final OnEnemyKilled? onEnemyKilled;

  /// 방 전환 콜백
  final void Function(Room room)? onRoomChanged;

  /// 층 클리어 콜백
  final void Function(int floor)? onFloorCleared;

  /// 보스 처치 콜백
  final VoidCallback? onBossDefeated;

  /// 보스 시작 콜백
  final OnBossStartCallback? onBossStart;

  /// 승리 콜백
  final OnVictoryCallback? onVictory;

  /// 대화 시작 콜백
  final VoidCallback? onDialogueStart;

  /// 대화 종료 콜백
  final VoidCallback? onDialogueEnd;

  /// 대화 노드 변경 콜백
  final OnDialogueNodeChanged? onDialogueNodeChanged;

  /// 트리거 실행 콜백
  final OnTriggerExecuted? onTriggerExecuted;

  /// 게임 상태 참조
  final GameState gameState;

  /// 인벤토리 아이템 ID 목록
  final List<String> inventoryItemIds;

  /// 플레이어 캐릭터
  ArcanaPlayer? _player;

  /// 플레이어 게터 (안전 접근)
  ArcanaPlayer get player => _player!;

  /// 던전 관리자
  late DungeonManager _dungeonManager;

  /// 던전 관리자 게터
  DungeonManager get dungeonManager => _dungeonManager;

  /// 대화 관리자
  late DialogueManager _dialogueManager;

  /// 대화 관리자 게터
  DialogueManager get dialogueManager => _dialogueManager;

  /// 대화 중 여부 (ArcanaGameInterface 구현)
  @override
  bool get isInDialogue => _dialogueManager.isActive;

  /// 스킬 관리자
  late SkillManager _skillManager;

  /// 스킬 관리자 게터
  SkillManager get skillManager => _skillManager;

  /// 스킬 사용 콜백 (Provider 연동용)
  void Function(String skillId, double manaCost)? onSkillUsed;

  /// 심장 게이지 변경 콜백
  void Function(double current, double max)? onHeartGaugeChanged;

  /// 마나 변경 콜백
  void Function(double current, double max)? onManaChanged;

  /// 조이스틱 컴포넌트 (터치용)
  late JoystickComponent joystick;

  /// 공격 버튼
  late HudButtonComponent attackButton;

  /// 게임 일시정지 여부
  bool _isPaused = false;

  /// 게임 일시정지 여부 (ArcanaGameInterface 구현)
  @override
  bool get isGamePaused => _isPaused || isInDialogue;

  /// 게임 시작 시간
  DateTime? _startTime;

  /// 방 전환 중 여부
  bool _isTransitioning = false;

  /// 환청 타이머 (Hearts < 3일 때 랜덤 발생)
  double _hallucinationTimer = 0;

  /// 다음 환청까지 남은 시간
  double _nextHallucinationTime = 60;

  /// 환청 발생 최소 간격 (초)
  static const double _hallucinationMinInterval = 45;

  /// 환청 발생 최대 간격 (초)
  static const double _hallucinationMaxInterval = 120;

  /// 보스 조우 대화 완료 여부
  bool _bossEncounterDialogueShown = false;

  /// 보스 페이즈2 대화 완료 여부
  bool _bossPhase2DialogueShown = false;

  /// 보스 페이즈3 대화 완료 여부 (챕터 2용)
  bool _bossPhase3DialogueShown = false;

  /// 랜덤 생성기
  final Random _random = Random();

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 카메라 줌 설정
    camera.viewfinder.zoom = PhysicsConstants.zoomLevel;

    // 대화 관리자 초기화
    _dialogueManager = DialogueManager(
      gameState: gameState,
      inventory: inventoryItemIds,
      onDialogueStart: _handleDialogueStart,
      onDialogueEnd: _handleDialogueEnd,
      onNodeChanged: _handleDialogueNodeChanged,
      onTriggerExecuted: _handleTriggerExecuted,
    );

    // 대화 시퀀스 등록
    _dialogueManager.registerSequences(Chapter1Dialogues.all);
    _dialogueManager.registerSequences(Chapter2Dialogues.all);
    _dialogueManager.registerSequences(Chapter3Dialogues.all);
    _dialogueManager.registerSequences(Chapter4Dialogues.all);
    _dialogueManager.registerSequences(Chapter5Dialogues.all);
    _dialogueManager.registerSequences(Chapter6Dialogues.all);
    // 환경 스토리텔링 대화 등록
    _dialogueManager.registerSequences(EnvironmentDialogues.all);
    // 테스트 대화 시퀀스도 등록
    _dialogueManager.registerSequences(TestDialogues.all);

    // 스킬 관리자 초기화
    _skillManager = SkillManager(
      onSkillUsed: _handleSkillUsed,
      onManaConsumed: _handleManaConsumed,
      onHeartGaugeConsumed: _handleHeartGaugeConsumed,
      onCooldownStarted: _handleCooldownStarted,
    );
    _skillManager.initialize(SkillsConfig.defaultConfig);
    add(_skillManager);

    // 던전 관리자 초기화 (이어하기 시 저장된 층에서 시작)
    _dungeonManager = DungeonManager(
      onRoomCleared: _onRoomCleared,
      onFloorCleared: _onFloorCleared,
      onBossDefeated: _onBossDefeated,
      initialFloor: initialFloor,
    );
    add(_dungeonManager);

    // 던전 생성
    await _dungeonManager.generateNewDungeon();

    // 플레이어 생성 (콜백 연결)
    _player = ArcanaPlayer(
      position: _dungeonManager.getPlayerStartPosition(),
      onItemPickup: _handleItemPickup,
      onGameOver: _handleGameOver,
      onDoorEnter: _handleDoorEnter,
      onNpcInteract: _handleNpcInteract,
      onSkillUse: _handleSkillUse,
      onDamageDealt: _handlePlayerDamageDealt,
      onDamageTaken: _handlePlayerDamageTaken,
    );

    // 이어하기 시 저장된 플레이어 상태 복원
    _player!.currentHearts = initialHearts;
    _player!.maxHealth = initialMaxHealth;
    _player!.health = initialHealth;

    world.add(_player!);

    // 카메라가 플레이어를 따라가도록 설정
    camera.follow(player);

    // 조이스틱 추가 (모바일/터치용)
    _setupJoystick();

    // 게임 시작 시간 기록
    _startTime = DateTime.now();

    // 챕터별 던전 BGM 재생
    AudioManager.instance.playChapterDungeonBgm(initialFloor);

    // 프롤로그 시작 (첫 게임인 경우)
    _startPrologueIfNeeded();
  }

  /// 프롤로그 필요 시 시작
  void _startPrologueIfNeeded() {
    // prologue_complete 플래그가 없으면 프롤로그 시작
    if (!gameState.getFlag('prologue_complete')) {
      // 약간의 딜레이 후 시작 (로딩 완료 대기)
      _safeStartDialogue('ch1_prologue', delayMs: 500);
    }
  }

  /// 대화 시작 처리
  void _handleDialogueStart() {
    _player?.setInputEnabled(false);
    onDialogueStart?.call();
  }

  /// 대화 종료 처리
  void _handleDialogueEnd() {
    _player?.setInputEnabled(true);

    // 대화 체인 처리 (특정 대화 후 다음 대화 자동 시작)
    _handleDialogueChain();

    onDialogueEnd?.call();
  }

  /// 안전한 대화 시작 (상태 체크 포함)
  void _safeStartDialogue(String dialogueId, {int delayMs = 1500}) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      // 게임이 일시정지/종료되지 않았고, 다른 대화가 진행 중이 아닐 때만
      if (!_isPaused && !isInDialogue && _player != null) {
        startDialogue(dialogueId);
      }
    });
  }

  /// 대화 체인 처리 (대화 → 대화 자동 연결)
  void _handleDialogueChain() {
    final lastDialogue = _dialogueManager.lastCompletedSequenceId;
    if (lastDialogue == null) return;

    // 챕터 1: 보스 처치 대화 → 에필로그
    if (lastDialogue == 'ch1_yggdra_defeat') {
      _safeStartDialogue('ch1_epilogue');
    }

    // 챕터 2: 보스 처치 대화 → 에필로그
    if (lastDialogue == 'ch2_baldur_defeat') {
      _safeStartDialogue('ch2_epilogue');
    }

    // 챕터 3: 보스 처치 대화 → 기억 회복 → 에필로그
    if (lastDialogue == 'ch3_silencia_defeat') {
      _safeStartDialogue('ch3_memory_recovery');
    }

    if (lastDialogue == 'ch3_memory_recovery') {
      _safeStartDialogue('ch3_epilogue', delayMs: 2000);
    }

    // 챕터 4: 보스 처치 대화 → 진실 공개 → 에필로그
    if (lastDialogue == 'ch4_liliana_defeat') {
      _safeStartDialogue('ch4_truth_reveal');
    }

    if (lastDialogue == 'ch4_truth_reveal') {
      _safeStartDialogue('ch4_epilogue', delayMs: 2000);
    }

    // 챕터 5: 그림자 통합 → 미래의 자신 작별 → 에필로그
    if (lastDialogue == 'ch5_shadow_integration') {
      _safeStartDialogue('ch5_future_farewell');
    }

    if (lastDialogue == 'ch5_future_farewell') {
      _safeStartDialogue('ch5_epilogue', delayMs: 2000);
    }

    // 챕터 6: 최종 보스 흐름
    // Phase 4 (협상) 이후 엔딩 분기
    if (lastDialogue == 'ch6_oblivion_phase4') {
      // 트루 엔딩 조건 확인 (세 개의 심장 + 모든 기억 결정)
      final hasTrueEndingCondition =
          gameState.getFlag('has_heart_of_past') &&
          gameState.getFlag('has_heart_of_present') &&
          gameState.getFlag('has_all_memory_crystals');

      if (hasTrueEndingCondition) {
        _safeStartDialogue('ch6_true_ending_option');
      } else {
        _safeStartDialogue('ch6_normal_ending_choice');
      }
    }

    // 노멀 엔딩 선택 후 → 노멀 엔딩
    if (lastDialogue == 'ch6_normal_ending_choice') {
      _safeStartDialogue('ch6_normal_ending', delayMs: 2000);
    }

    // 트루 엔딩 옵션 선택 후 → 트루 엔딩
    if (lastDialogue == 'ch6_true_ending_option') {
      _safeStartDialogue('ch6_true_ending', delayMs: 2000);
    }

    // 노멀 엔딩 완료 → 승리 화면 (노멀)
    if (lastDialogue == 'ch6_normal_ending') {
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (!_isPaused && _player != null) {
          onVictory?.call(false); // 노멀 엔딩
        }
      });
    }

    // 트루 엔딩 완료 → 승리 화면 (트루)
    if (lastDialogue == 'ch6_true_ending') {
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (!_isPaused && _player != null) {
          onVictory?.call(true); // 트루 엔딩
        }
      });
    }

    // 세 번째 심장 각성 → Phase 4 진입
    if (lastDialogue == 'ch6_third_heart') {
      _safeStartDialogue('ch6_oblivion_phase4');
    }
  }

  /// 대화 노드 변경 처리
  void _handleDialogueNodeChanged(DialogueNode node) {
    onDialogueNodeChanged?.call(node);
  }

  /// 트리거 실행 처리
  void _handleTriggerExecuted(DialogueTrigger trigger) {
    onTriggerExecuted?.call(trigger);
  }

  /// 스킬 사용 처리
  void _handleSkillUsed(SkillData skill) {
    onSkillUsed?.call(skill.id, skill.manaCost);
    // 스킬 사운드 재생 (추후 스킬별 사운드 추가)
    AudioManager.instance.playSfx(SoundEffect.playerAttack);
  }

  /// 마나 소모 처리
  void _handleManaConsumed(double amount) {
    onManaChanged?.call(_skillManager.currentMana, _skillManager.maxMana);
  }

  /// 심장 게이지 소모 처리
  void _handleHeartGaugeConsumed(double amount) {
    onHeartGaugeChanged?.call(_skillManager.heartGauge, _skillManager.maxHeartGauge);
  }

  /// 쿨다운 시작 처리
  void _handleCooldownStarted(String skillId, double cooldown) {
    // Provider에서 처리
  }

  /// 스킬 사용 (외부 호출용)
  SkillUseResult useSkill(int slotIndex) {
    final skillId = _getSkillIdForSlot(slotIndex);
    if (skillId == null) return SkillUseResult.invalid;

    final skill = _skillManager.getSkillById(skillId);
    if (skill == null) return SkillUseResult.invalid;

    final playerPos = _player?.position ?? Vector2.zero();
    final playerDir = _getDirectionVector();

    return _skillManager.useSkill(skill, playerPos, playerDir);
  }

  /// 슬롯별 스킬 ID 반환 (기본 스킬 설정)
  String? _getSkillIdForSlot(int slot) {
    // 기본 스킬 슬롯 매핑
    switch (slot) {
      case 0:
        return 'basic_attack'; // 기본 공격
      case 1:
        return 'dash'; // 대시
      case 2:
        return 'heavy_attack'; // 강공격
      case 3:
        return 'ultimate_body'; // 궁극기
      default:
        return null;
    }
  }

  /// 현재 방향을 벡터로 변환
  Vector2 _getDirectionVector() {
    if (_player == null) return Vector2(0, 1);

    switch (_player!.direction) {
      case PlayerDirection.up:
        return Vector2(0, -1);
      case PlayerDirection.down:
        return Vector2(0, 1);
      case PlayerDirection.left:
        return Vector2(-1, 0);
      case PlayerDirection.right:
        return Vector2(1, 0);
      case PlayerDirection.idle:
        return Vector2(0, 1);
    }
  }

  /// 심장 게이지 충전 (데미지 가함 시)
  void onDamageDealt(double damage) {
    _skillManager.onDamageDealt(damage);
    onHeartGaugeChanged?.call(_skillManager.heartGauge, _skillManager.maxHeartGauge);
  }

  /// 심장 게이지 충전 (데미지 받음 시)
  void onDamageTaken(double damage) {
    _skillManager.onDamageTaken(damage);
    onHeartGaugeChanged?.call(_skillManager.heartGauge, _skillManager.maxHeartGauge);
  }

  /// 심장 게이지 충전 (완벽 회피 시)
  void onPerfectDodge() {
    _skillManager.onPerfectDodge();
    onHeartGaugeChanged?.call(_skillManager.heartGauge, _skillManager.maxHeartGauge);
  }

  /// 적 처치 시 마나/게이지 회복
  void onKillEnemy() {
    _skillManager.onKill();
    onManaChanged?.call(_skillManager.currentMana, _skillManager.maxMana);
    onHeartGaugeChanged?.call(_skillManager.heartGauge, _skillManager.maxHeartGauge);
  }

  /// 방 클리어 처리
  void _onRoomCleared(Room room) {
    onRoomChanged?.call(room);

    // 보스방이 아닌 경우 클리어 사운드
    if (room.type != RoomType.boss) {
      AudioManager.instance.playSfx(SoundEffect.doorOpen);
    }
  }

  /// 층 클리어 처리
  void _onFloorCleared(int floor) {
    onFloorCleared?.call(floor);
  }

  /// 보스 처치 처리
  void _onBossDefeated() {
    // 플레이어가 이미 사망했으면 보스 처치 무시 (동시 사망 시 게임오버 우선)
    if (_player?.isDead == true) {
      debugPrint('[ArcanaGame] Boss defeated but player is dead - ignoring');
      return;
    }

    AudioManager.instance.playSfx(SoundEffect.victory);
    AudioManager.instance.playBgm(BgmTrack.victory);

    // 층별 보스 처치 대화 시작
    final floor = _dungeonManager.currentFloor;
    switch (floor) {
      case 1:
        _safeStartDialogue('ch1_yggdra_defeat', delayMs: 1000);
      case 2:
        _safeStartDialogue('ch2_baldur_defeat', delayMs: 1000);
      case 3:
        _safeStartDialogue('ch3_silencia_defeat', delayMs: 1000);
      case 4:
        _safeStartDialogue('ch4_liliana_defeat', delayMs: 1000);
      case 5:
        // 챕터 5: 그림자 통합 대화 (보스 처치가 아닌 통합으로 처리)
        _safeStartDialogue('ch5_shadow_integration', delayMs: 1000);
      case 6:
        // 챕터 6: 최종 보스는 완전 처치가 아닌 엔딩 분기로 처리
        break;
      default:
        // 이후 챕터는 기본 처리
        break;
    }

    onBossDefeated?.call();
  }

  /// NPC 상호작용 처리 (E키)
  /// 스킬 사용 처리 (키보드 입력)
  void _handleSkillUse(int slotIndex) {
    if (isInDialogue || _isPaused) return;

    final result = useSkill(slotIndex);
    if (result == SkillUseResult.success) {
      // 스킬 성공 피드백
      AudioManager.instance.playSfx(SoundEffect.playerAttack);
    }
  }

  /// 플레이어가 적에게 데미지를 가했을 때
  void _handlePlayerDamageDealt(double damage) {
    // 심장 게이지 충전
    onDamageDealt(damage);
  }

  /// 플레이어가 데미지를 받았을 때
  void _handlePlayerDamageTaken(double damage) {
    // 심장 게이지 충전 (피격 시 더 빠르게 충전)
    onDamageTaken(damage);
  }

  void _handleNpcInteract() {
    if (isInDialogue) return;
    if (_player == null) return;

    // 근처 NPC 찾기
    final nearbyNpc = _findNearbyNpc();
    if (nearbyNpc == null) return;

    // NPC 대화 시작
    _dialogueManager.startDialogueWithNpc(nearbyNpc.npcData);
  }

  /// 근처 NPC 찾기
  NpcComponent? _findNearbyNpc() {
    const interactionRange = 64.0; // 상호작용 범위

    NpcComponent? closest;
    double closestDistance = interactionRange;

    for (final component in world.children) {
      if (component is NpcComponent) {
        final distance = _player!.position.distanceTo(component.position);
        if (distance < closestDistance) {
          closestDistance = distance;
          closest = component;
        }
      }
    }

    return closest;
  }

  /// 문 진입 처리
  Future<void> _handleDoorEnter(DoorDirection direction) async {
    if (_isTransitioning) return;

    // 디버그: 방 이동 조건 확인
    debugPrint('[DoorEnter] Room type: ${_dungeonManager.currentRoom?.type}, isCleared: ${_dungeonManager.isRoomCleared}');

    if (!_dungeonManager.isRoomCleared) {
      debugPrint('[DoorEnter] BLOCKED - Room not cleared');
      return;
    }

    _isTransitioning = true;

    // 화면 페이드 효과 (간단한 대기)
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // 방 이동
    await _dungeonManager.moveToRoom(direction);

    // 플레이어 위치 재설정
    _player?.position = _getPlayerEntryPosition(direction);

    // 보스방 진입 시 챕터별 보스 BGM 변경 및 대화 시작
    if (_dungeonManager.currentRoom?.type == RoomType.boss) {
      AudioManager.instance.playChapterBossBgm(_dungeonManager.currentFloor);
      AudioManager.instance.playSfx(SoundEffect.bossAppear);

      // 보스 시작 콜백 (UI용)
      final bossInfo = _getBossInfo(_dungeonManager.currentFloor);
      onBossStart?.call(bossInfo.$1, bossInfo.$2);

      // 보스 조우 대화 (한 번만, 층별 분기)
      if (!_bossEncounterDialogueShown) {
        _bossEncounterDialogueShown = true;
        _startBossEncounterDialogue(_dungeonManager.currentFloor);
      }
    }

    // 방 변경 콜백 및 전환 완료 (모든 방 타입에 적용)
    onRoomChanged?.call(_dungeonManager.currentRoom!);
    _isTransitioning = false;

    debugPrint('[DoorEnter] Transition complete to ${_dungeonManager.currentRoom?.type}');
  }

  /// 보스 조우 대화 시작 (안전한 방식)
  void _startBossEncounterDialogue(int floor) {
    String? dialogueId;

    switch (floor) {
      case 1:
        if (!gameState.getFlag('yggdra_encounter_complete')) {
          dialogueId = 'ch1_yggdra_encounter';
        }
      case 2:
        if (!gameState.getFlag('baldur_encounter_complete')) {
          dialogueId = 'ch2_baldur_encounter';
        }
      case 3:
        if (!gameState.getFlag('silencia_encounter_complete')) {
          dialogueId = 'ch3_silencia_encounter';
        }
      case 4:
        if (!gameState.getFlag('liliana_encounter_complete')) {
          dialogueId = 'ch4_liliana_encounter';
        }
      case 5:
        if (!gameState.getFlag('shadow_encounter_complete')) {
          dialogueId = 'ch5_shadow_encounter';
        }
      case 6:
        if (!gameState.getFlag('oblivion_encounter_complete')) {
          dialogueId = 'ch6_oblivion_encounter';
        }
    }

    if (dialogueId != null) {
      _safeStartDialogue(dialogueId, delayMs: 500);
    }
  }

  /// 층별 보스 정보 반환 (HP, 이름)
  (double, String) _getBossInfo(int floor) {
    switch (floor) {
      case 1:
        return (600, '이그드라');
      case 2:
        return (750, '발두르');
      case 3:
        return (800, '실렌시아');
      case 4:
        return (850, '리리아나');
      case 5:
        return (900, '그림자 자아');
      case 6:
        return (1500, '망각의 화신');
      default:
        return (500, '거대 슬라임');
    }
  }

  /// 방 진입 방향에 따른 플레이어 위치
  Vector2 _getPlayerEntryPosition(DoorDirection fromDirection) {
    final room = _dungeonManager.currentRoom;
    if (room == null) return Vector2(160, 160);

    final centerX = room.width * 32 / 2;
    final centerY = room.height * 32 / 2;

    // 반대 방향에서 진입
    switch (fromDirection) {
      case DoorDirection.north:
        return Vector2(centerX, room.height * 32 - 64);
      case DoorDirection.south:
        return Vector2(centerX, 64);
      case DoorDirection.east:
        return Vector2(64, centerY);
      case DoorDirection.west:
        return Vector2(room.width * 32 - 64, centerY);
    }
  }

  /// 현재 층
  int get currentFloor => _dungeonManager.currentFloor;

  /// 현재 방
  Room? get currentRoom => _dungeonManager.currentRoom;

  /// 방 클리어 여부
  bool get isRoomCleared => _dungeonManager.isRoomCleared;

  /// 조이스틱 및 버튼 설정
  void _setupJoystick() {
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.8),
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.3),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);

    // 공격 버튼
    attackButton = HudButtonComponent(
      button: CircleComponent(
        radius: 30,
        paint: Paint()..color = Colors.red.withValues(alpha: 0.5),
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () => _player?.attack(),
    );
    camera.viewport.add(attackButton);
  }

  @override
  void update(double dt) {
    if (_isPaused) return;

    super.update(dt);

    // 조이스틱 입력 처리
    if (_player != null && !joystick.delta.isZero()) {
      _player!.moveByJoystick(joystick.delta);
    }

    // 플레이어 위치 경계 제한 (방 안에 유지)
    _clampPlayerPosition();

    // 환청 시스템 업데이트 (대화 중이 아닐 때만)
    if (!isInDialogue) {
      _updateHallucinationSystem(dt);
    }

    // 보스 상태 체크
    _checkBossState();
  }

  /// 플레이어 위치를 현재 방 경계 안으로 제한
  void _clampPlayerPosition() {
    if (_player == null) return;

    final room = _dungeonManager.currentRoom;
    if (room == null) return;

    // 방 크기 계산 (타일 크기 * 방 크기)
    const tileSize = 32.0;
    final roomWidth = room.width * tileSize;
    final roomHeight = room.height * tileSize;

    // 플레이어 크기의 절반 (중앙 앵커 기준)
    final halfSize = _player!.size.x / 2;

    // 단순 경계: 플레이어가 방 안에 있도록 (문 트리거 접근 가능)
    // 최소 경계는 플레이어가 완전히 방 안에 있도록
    final minX = halfSize;
    final maxX = roomWidth - halfSize;
    final minY = halfSize;
    final maxY = roomHeight - halfSize;

    // 위치 클램프 - NaN이나 무한대 체크
    if (_player!.position.x.isNaN || _player!.position.x.isInfinite) {
      _player!.position.x = roomWidth / 2;
    } else {
      _player!.position.x = _player!.position.x.clamp(minX, maxX);
    }

    if (_player!.position.y.isNaN || _player!.position.y.isInfinite) {
      _player!.position.y = roomHeight / 2;
    } else {
      _player!.position.y = _player!.position.y.clamp(minY, maxY);
    }
  }

  /// 환청 시스템 업데이트
  void _updateHallucinationSystem(double dt) {
    // Hearts가 3개 이상이면 환청 없음
    if (gameState.heartCount >= 3) return;

    _hallucinationTimer += dt;

    if (_hallucinationTimer >= _nextHallucinationTime) {
      _hallucinationTimer = 0;
      _nextHallucinationTime = _hallucinationMinInterval +
          _random.nextDouble() * (_hallucinationMaxInterval - _hallucinationMinInterval);

      // 층별 환청 대화 선택
      _triggerChapterHallucination();
    }
  }

  /// 챕터별 환청 트리거
  void _triggerChapterHallucination() {
    final floor = _dungeonManager.currentFloor;

    switch (floor) {
      case 1:
        // 챕터 1: 기본 환청 (한 번만)
        if (!gameState.getFlag('heard_hallucination')) {
          startDialogue('ch1_hallucination');
        }

      case 2:
        // 챕터 2: 하트 상태에 따른 환청/환영
        if (gameState.heartCount == 1 && !gameState.getFlag('seen_queen_ghost')) {
          // Hearts == 1: 왕비의 환영
          startDialogue('ch2_queen_ghost');
        } else if (gameState.heartCount <= 2 && !gameState.getFlag('heard_betrayal_hallucination')) {
          // Hearts <= 2: 배신의 환각
          startDialogue('ch2_betrayal_hallucination');
        }

      case 3:
        // 챕터 3: 고백 강요 환청 (Hearts <= 2)
        if (gameState.heartCount <= 2 && !gameState.getFlag('heard_confession_hallucination')) {
          startDialogue('ch3_confession_hallucination');
        }

      case 4:
        // 챕터 4: 가시의 방 환청 (Hearts <= 2)
        if (gameState.heartCount <= 2 && !gameState.getFlag('heard_thorn_hallucination')) {
          startDialogue('ch4_thorn_hallucination');
        }

      case 5:
        // 챕터 5: 그림자의 환청 (Hearts <= 2)
        if (gameState.heartCount <= 2 && !gameState.getFlag('ch5_hallucination_seen')) {
          startDialogue('ch5_hallucination');
        }

      case 6:
        // 챕터 6: 망각의 환청 (Hearts <= 2)
        if (gameState.heartCount <= 2 && !gameState.getFlag('ch6_hallucination_seen')) {
          startDialogue('ch6_hallucination');
        }

      default:
        // 이후 챕터: 기본 환청
        if (!gameState.getFlag('heard_hallucination_ch$floor')) {
          startDialogue('ch1_hallucination');
        }
    }
  }

  /// 보스 상태 체크
  void _checkBossState() {
    // 보스방이 아니면 스킵
    if (_dungeonManager.currentRoom?.type != RoomType.boss) return;

    // 층별 보스 체크
    switch (_dungeonManager.currentFloor) {
      case 1:
        _checkYggdraState();
      case 2:
        _checkBaldurState();
      case 3:
        _checkSilenciaState();
      case 4:
        _checkLilianaState();
      case 5:
        _checkShadowState();
      case 6:
        _checkOblivionState();
      default:
        break;
    }
  }

  /// 이그드라 상태 체크
  void _checkYggdraState() {
    final bosses = world.children.whereType<BossYggdra>();
    if (bosses.isEmpty) return;

    final boss = bosses.first;

    // 페이즈 2 전환 대화 (한 번만)
    if (!_bossPhase2DialogueShown && boss.isInRagePhase) {
      _bossPhase2DialogueShown = true;
      startDialogue('ch1_yggdra_phase2');
    }
  }

  /// 발두르 상태 체크
  void _checkBaldurState() {
    final bosses = world.children.whereType<BossBaldur>();
    if (bosses.isEmpty) return;

    final boss = bosses.first;

    // 페이즈 2 전환 대화 (광기)
    if (!_bossPhase2DialogueShown && boss.isInMadnessPhase) {
      _bossPhase2DialogueShown = true;
      startDialogue('ch2_baldur_phase2');
    }

    // 페이즈 3 전환 대화 (절망)
    if (!_bossPhase3DialogueShown && boss.isInDespairPhase) {
      _bossPhase3DialogueShown = true;
      startDialogue('ch2_baldur_phase3');
    }
  }

  /// 실렌시아 상태 체크
  void _checkSilenciaState() {
    final bosses = world.children.whereType<BossSilencia>();
    if (bosses.isEmpty) return;

    final boss = bosses.first;

    // 페이즈 2 전환 대화 (심판)
    if (!_bossPhase2DialogueShown && boss.isInJudgmentPhase) {
      _bossPhase2DialogueShown = true;
      startDialogue('ch3_silencia_phase2');
    }

    // 페이즈 3 전환 대화 (침묵) + BGM 무음 처리
    if (!_bossPhase3DialogueShown && boss.isInSilencePhase) {
      _bossPhase3DialogueShown = true;
      // GDD: 챕터 3 Phase 3는 완전한 무음으로 긴장감 연출
      AudioManager.instance.playChapter3SilencePhase();
      startDialogue('ch3_silencia_phase3');
    }
  }

  /// 리리아나 상태 체크
  void _checkLilianaState() {
    final bosses = world.children.whereType<BossLiliana>();
    if (bosses.isEmpty) return;

    final boss = bosses.first;

    // 페이즈 2 전환 대화 (배신의 고통)
    if (!_bossPhase2DialogueShown && boss.isInBetrayalPhase) {
      _bossPhase2DialogueShown = true;
      startDialogue('ch4_liliana_phase2');
    }

    // 페이즈 3 전환 대화 (용서와 원한)
    if (!_bossPhase3DialogueShown && boss.isInForgivenessPhase) {
      _bossPhase3DialogueShown = true;
      startDialogue('ch4_liliana_phase3');
    }
  }

  /// 그림자 자아 상태 체크
  void _checkShadowState() {
    final bosses = world.children.whereType<BossShadow>();
    if (bosses.isEmpty) return;

    final boss = bosses.first;

    // 페이즈 2 전환 대화 (분노)
    if (!_bossPhase2DialogueShown && boss.isInAngerPhase) {
      _bossPhase2DialogueShown = true;
      startDialogue('ch5_shadow_phase2');
    }

    // 페이즈 3 전환 대화 (수용)
    if (!_bossPhase3DialogueShown && boss.isInAcceptancePhase) {
      _bossPhase3DialogueShown = true;
      startDialogue('ch5_shadow_phase3');
    }
  }

  /// 망각의 화신 상태 체크 (Phase 4 특수 플래그 필요)
  bool _bossPhase4DialogueShown = false;

  void _checkOblivionState() {
    final bosses = world.children.whereType<BossOblivion>();
    if (bosses.isEmpty) return;

    final boss = bosses.first;

    // 페이즈 2 전환 대화 (현재의 망각)
    if (!_bossPhase2DialogueShown && boss.isInPresentPhase) {
      _bossPhase2DialogueShown = true;
      startDialogue('ch6_oblivion_phase2');
    }

    // 페이즈 3 전환 대화 (미래의 망각)
    if (!_bossPhase3DialogueShown && boss.isInFuturePhase) {
      _bossPhase3DialogueShown = true;
      startDialogue('ch6_oblivion_phase3');
    }

    // 페이즈 4 전환 (최후의 협상) - HP 10% 이하
    if (!_bossPhase4DialogueShown && boss.isInBargainPhase) {
      _bossPhase4DialogueShown = true;
      // GDD: 최종 페이즈 BGM 전환
      AudioManager.instance.playFinalBossBgm();
      // 세 번째 심장 각성 대화 먼저
      startDialogue('ch6_third_heart');
    }
  }

  /// 아이템 획득 처리
  void _handleItemPickup(Item item) {
    onItemCollected?.call(item);

    // 스토리 아이템 획득 시 대화 트리거
    _triggerStoryItemDialogue(item.id);
  }

  /// 스토리 아이템 대화 트리거
  /// 대화 내에서 DialogueTrigger.setFlag를 통해 플래그 설정됨
  void _triggerStoryItemDialogue(String itemId) {
    // 지연 실행으로 아이템 획득 연출 후 대화 시작
    String? dialogueId;

    switch (itemId) {
      // 챕터 1: 부서진 나뭇잎 펜던트
      case 'broken_leaf_pendant':
        if (!gameState.getFlag('found_leaf_pendant')) {
          dialogueId = 'ch1_item_pendant';
        }

      // 챕터 2: 깨진 왕관 조각
      case 'broken_crown_shard':
        if (!gameState.getFlag('found_crown_shard')) {
          dialogueId = 'ch2_item_crown';
        }

      // 챕터 3: 첫 번째 기억 조각
      case 'memory_fragment_1':
        if (!gameState.getFlag('found_memory_fragment')) {
          dialogueId = 'ch3_item_memory';
        }

      // 챕터 4: 리리아나의 반지
      case 'liliana_ring':
        if (!gameState.getFlag('found_liliana_ring')) {
          dialogueId = 'ch4_item_ring';
        }

      // 트루 엔딩 아이템: 약속의 반지
      case 'promise_ring':
        if (!gameState.getFlag('found_promise_ring')) {
          dialogueId = 'ch4_hidden_ring';
        }

      // 트루 엔딩 아이템: 첫 번째 기억의 결정
      case 'first_memory_crystal':
        if (!gameState.getFlag('found_memory_crystal')) {
          dialogueId = 'ch5_hidden_crystal';
        }

      // 챕터 5: 그림자의 파편
      case 'shadow_fragment':
        if (!gameState.getFlag('found_shadow_fragment')) {
          dialogueId = 'ch5_item_shadow';
        }

      // 챕터 6: 망각의 눈물
      case 'oblivion_tear':
        if (!gameState.getFlag('found_oblivion_tear')) {
          dialogueId = 'ch6_item_tear';
        }
    }

    if (dialogueId != null) {
      _safeStartDialogue(dialogueId, delayMs: 800);
    }
  }

  /// 게임 오버 처리
  void _handleGameOver() {
    _isPaused = true;
    // 게임 오버 BGM으로 변경
    AudioManager.instance.playBgm(BgmTrack.gameOver);
    onGameOverCallback?.call();
  }

  /// 적 처치 알림 (BaseEnemy에서 호출)
  @override
  void notifyEnemyKilled() {
    // 던전 매니저에 적 처치 알림 (방 클리어 카운트)
    _dungeonManager.onEnemyKilled();

    // 외부 콜백 호출
    onEnemyKilled?.call();
  }

  /// 드롭 아이템 생성
  void spawnDroppedItem(Item item, Vector2 position) {
    world.add(DroppedItem(item: item, position: position));
  }

  /// 게임 일시정지
  void pause() {
    _isPaused = true;
    pauseEngine();
  }

  /// 게임 재개
  void resume() {
    _isPaused = false;
    resumeEngine();
  }

  /// 플레이어 체력 회복
  void healPlayer(int amount) {
    _player?.heal(amount);
  }

  /// 플레이어 장비 스탯 업데이트
  void updatePlayerEquipment({int? attack, int? defense}) {
    _player?.updateEquipmentStats(attack: attack, defense: defense);
  }

  /// 게임 재시작
  Future<void> restart() async {
    // 모든 적 제거
    world.children.whereType<BaseEnemy>().forEach((e) => e.removeFromParent());
    world.children.whereType<DummyEnemy>().forEach((e) => e.removeFromParent());
    world.children.whereType<DroppedItem>().forEach((e) => e.removeFromParent());

    // 던전 리셋 및 재생성
    _dungeonManager.reset();
    await _dungeonManager.generateNewDungeon();

    // 플레이어 리셋
    _player?.reset(_dungeonManager.getPlayerStartPosition());

    // 게임 재개
    _isPaused = false;
    _isTransitioning = false;
    _startTime = DateTime.now();
    resumeEngine();

    // 챕터별 던전 BGM 재생
    AudioManager.instance.playChapterDungeonBgm(_dungeonManager.currentFloor);
  }

  /// 플레이 시간 반환
  Duration get playTime {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  /// 게임 로드 완료 여부
  bool get isLoaded => _player != null;

  /// 현재 하트 개수
  int get currentHearts => _player?.currentHearts ?? 3;

  /// 현재 체력
  double get currentHealth => _player?.health ?? 100;

  /// 최대 체력
  double get maxHealth => _player?.maxHealth ?? 100;

  /// 플레이어 사망 여부
  bool get isPlayerDead => _player?.isDead ?? false;

  // === 대화 시스템 공개 메서드 ===

  /// 대화 시작
  bool startDialogue(String dialogueId) {
    return _dialogueManager.startDialogue(dialogueId);
  }

  /// 대화 진행 (다음 노드로)
  void advanceDialogue() {
    _dialogueManager.advance();
  }

  /// 선택지 선택
  void selectDialogueChoice(int choiceIndex) {
    _dialogueManager.selectChoice(choiceIndex);
  }

  /// 현재 대화 노드
  DialogueNode? get currentDialogueNode => _dialogueManager.currentNode;

  /// 현재 선택지 목록 (조건 필터링됨)
  List<DialogueChoice> get currentDialogueChoices =>
      _dialogueManager.getVisibleChoices();

  /// 대화 강제 종료
  void forceEndDialogue() {
    _dialogueManager.forceEnd();
  }
}

/// 플레이어 공격 타입 식별자
class PlayerAttackType {
  PlayerAttackType._();

  static const int melee = 1;
  static const int skill = 2;
}
