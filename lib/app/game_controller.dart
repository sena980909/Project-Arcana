/// Arcana: The Three Hearts - 게임 컨트롤러
/// 전체 게임 플로우 관리
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/dialogue.dart';
import '../data/model/item.dart';
import '../data/model/room.dart';
import '../data/services/save_manager.dart';
import '../game/arcana_game.dart';
import '../data/models/skill_data.dart';
import '../providers/game_state_provider.dart';
import '../providers/heart_gauge_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/player_skill_provider.dart';

/// 엔딩 타입
enum EndingType {
  normal,  // 노멀 엔딩 (망각 유지)
  truE,    // 트루 엔딩 (기억 회복)
}

/// 게임 컨트롤러 상태
class GameControllerState {
  const GameControllerState({
    this.currentScreen = GameScreen.mainMenu,
    this.game,
    this.isPaused = false,
    this.showInventory = false,
    this.showDialogue = false,
    this.currentDialogueNode,
    this.currentDialogueChoices = const [],
    this.currentFloor = 1,
    this.bossHealth = 0,
    this.bossMaxHealth = 0,
    this.bossName = '',
    this.isBossFight = false,
    this.endingType,
  });

  /// 현재 화면
  final GameScreen currentScreen;

  /// 게임 인스턴스
  final ArcanaGame? game;

  /// 일시정지 여부
  final bool isPaused;

  /// 인벤토리 표시 여부
  final bool showInventory;

  /// 대화 표시 여부
  final bool showDialogue;

  /// 현재 대화 노드
  final DialogueNode? currentDialogueNode;

  /// 현재 대화 선택지
  final List<DialogueChoice> currentDialogueChoices;

  /// 현재 층
  final int currentFloor;

  /// 보스 현재 체력
  final double bossHealth;

  /// 보스 최대 체력
  final double bossMaxHealth;

  /// 현재 보스 이름
  final String bossName;

  /// 보스전 여부
  final bool isBossFight;

  /// 엔딩 타입 (승리 시)
  final EndingType? endingType;

  GameControllerState copyWith({
    GameScreen? currentScreen,
    ArcanaGame? game,
    bool? isPaused,
    bool? showInventory,
    bool? showDialogue,
    DialogueNode? currentDialogueNode,
    List<DialogueChoice>? currentDialogueChoices,
    bool clearDialogue = false,
    int? currentFloor,
    double? bossHealth,
    double? bossMaxHealth,
    String? bossName,
    bool? isBossFight,
    EndingType? endingType,
  }) {
    return GameControllerState(
      currentScreen: currentScreen ?? this.currentScreen,
      game: game ?? this.game,
      isPaused: isPaused ?? this.isPaused,
      showInventory: showInventory ?? this.showInventory,
      showDialogue: showDialogue ?? this.showDialogue,
      currentDialogueNode: clearDialogue ? null : (currentDialogueNode ?? this.currentDialogueNode),
      currentDialogueChoices: clearDialogue ? const [] : (currentDialogueChoices ?? this.currentDialogueChoices),
      currentFloor: currentFloor ?? this.currentFloor,
      bossHealth: bossHealth ?? this.bossHealth,
      bossMaxHealth: bossMaxHealth ?? this.bossMaxHealth,
      bossName: bossName ?? this.bossName,
      isBossFight: isBossFight ?? this.isBossFight,
      endingType: endingType ?? this.endingType,
    );
  }
}

/// 게임 화면 타입
enum GameScreen {
  mainMenu,
  playing,
  gameOver,
  victory,
}

/// 게임 컨트롤러 Notifier
class GameControllerNotifier extends StateNotifier<GameControllerState> {
  GameControllerNotifier(this.ref) : super(const GameControllerState());

  final Ref ref;

  /// 새 게임 시작
  void startNewGame() {
    // 게임 상태 초기화
    ref.read(gameStateProvider.notifier).startGame();
    ref.read(inventoryProvider.notifier).clear();

    // 스킬/게이지 시스템 초기화 (설정 동기화)
    final resourceConfig = SkillsConfig.defaultConfig.resourceSystem;
    ref.read(heartGaugeProvider.notifier).initialize(resourceConfig);
    ref.read(playerSkillProvider.notifier).initialize(resourceConfig);

    // 현재 상태 읽기
    final gameState = ref.read(gameStateProvider);
    final inventoryState = ref.read(inventoryProvider);
    final inventoryItemIds = inventoryState.slots.map((s) => s.item.id).toList();

    // 게임 인스턴스 생성
    final game = ArcanaGame(
      gameState: gameState,
      inventoryItemIds: inventoryItemIds,
      onItemCollected: _onItemCollected,
      onGameOverCallback: _onGameOver,
      onEnemyKilled: _onEnemyKilled,
      onBossStart: _onBossStart,
      onVictory: _onVictory,
      onRoomChanged: _onRoomChanged,
      onFloorCleared: _onFloorCleared,
      onDialogueStart: _onDialogueStart,
      onDialogueEnd: _onDialogueEnd,
      onDialogueNodeChanged: _onDialogueNodeChanged,
    );

    // 스킬 시스템 콜백 연결
    game.onSkillUsed = _onSkillUsed;
    game.onHeartGaugeChanged = _onHeartGaugeChanged;
    game.onManaChanged = _onManaChanged;

    state = state.copyWith(
      currentScreen: GameScreen.playing,
      game: game,
      isPaused: false,
      currentFloor: 1,
      isBossFight: false,
      clearDialogue: true,
    );
  }

  /// 게임 이어하기
  void continueGame() {
    final saveData = SaveManager.instance.loadGame();
    if (saveData == null) {
      // 세이브 데이터 없으면 새 게임
      startNewGame();
      return;
    }

    // 게임 상태 복원
    ref.read(gameStateProvider.notifier).loadFromSave(
      floor: saveData.currentFloor,
      hearts: saveData.currentHearts,
      score: saveData.score,
      enemiesKilled: saveData.enemiesKilled,
      itemsCollected: saveData.itemsCollected,
      playTime: saveData.playTime,
    );

    // 인벤토리 복원
    ref.read(inventoryProvider.notifier).loadFromSave(
      itemIds: saveData.inventoryItems,
      gold: saveData.gold,
      equippedWeaponId: saveData.equippedWeaponId,
      equippedArmorId: saveData.equippedArmorId,
    );

    // 스킬/게이지 시스템 초기화
    final resourceConfig = SkillsConfig.defaultConfig.resourceSystem;
    ref.read(heartGaugeProvider.notifier).initialize(resourceConfig);
    ref.read(playerSkillProvider.notifier).initialize(resourceConfig);

    // 게임 시작 (이어하기: 저장된 상태로)
    final gameState = ref.read(gameStateProvider);
    final inventoryState = ref.read(inventoryProvider);
    final inventoryItemIds = inventoryState.slots.map((s) => s.item.id).toList();

    final game = ArcanaGame(
      gameState: gameState,
      inventoryItemIds: inventoryItemIds,
      onItemCollected: _onItemCollected,
      onGameOverCallback: _onGameOver,
      onEnemyKilled: _onEnemyKilled,
      onBossStart: _onBossStart,
      onVictory: _onVictory,
      onRoomChanged: _onRoomChanged,
      onFloorCleared: _onFloorCleared,
      onDialogueStart: _onDialogueStart,
      onDialogueEnd: _onDialogueEnd,
      onDialogueNodeChanged: _onDialogueNodeChanged,
      // 저장된 상태로 시작
      initialFloor: saveData.currentFloor,
      initialHearts: saveData.currentHearts,
      initialHealth: saveData.health,
      initialMaxHealth: saveData.maxHealth,
    );

    // 스킬 시스템 콜백 연결
    game.onSkillUsed = _onSkillUsed;
    game.onHeartGaugeChanged = _onHeartGaugeChanged;
    game.onManaChanged = _onManaChanged;

    state = state.copyWith(
      currentScreen: GameScreen.playing,
      game: game,
      isPaused: false,
      currentFloor: saveData.currentFloor,
      isBossFight: false,
      clearDialogue: true,
    );
  }

  /// 게임 일시정지
  void pauseGame() {
    state.game?.pause();
    state = state.copyWith(isPaused: true);
    ref.read(gameStateProvider.notifier).pauseGame();
  }

  /// 게임 재개
  void resumeGame() {
    state.game?.resume();
    state = state.copyWith(isPaused: false);
    ref.read(gameStateProvider.notifier).resumeGame();
  }

  /// 게임 재시작
  void restartGame() {
    ref.read(gameStateProvider.notifier).restartGame();
    ref.read(inventoryProvider.notifier).clear();

    state.game?.restart();
    state = state.copyWith(
      isPaused: false,
      currentFloor: 1,
      isBossFight: false,
    );
  }

  /// 메인 메뉴로
  void goToMainMenu() {
    state.game?.pause();
    ref.read(gameStateProvider.notifier).goToMainMenu();

    state = const GameControllerState(
      currentScreen: GameScreen.mainMenu,
    );
  }

  /// 인벤토리 토글
  void toggleInventory() {
    if (state.showInventory) {
      state.game?.resume();
    } else {
      state.game?.pause();
    }
    state = state.copyWith(showInventory: !state.showInventory);
  }

  /// 인벤토리 닫기
  void closeInventory() {
    if (state.showInventory) {
      state.game?.resume();
      state = state.copyWith(showInventory: false);
    }
  }

  /// 아이템 사용 (회복)
  void useHealItem(int healAmount) {
    state.game?.healPlayer(healAmount);
  }

  /// 다음 층으로
  void goToNextFloor() {
    final nextFloor = state.currentFloor + 1;
    ref.read(gameStateProvider.notifier).nextFloor();
    state = state.copyWith(
      currentFloor: nextFloor,
      isBossFight: false,
    );
  }

  /// 보스전 시작
  void startBossFight(double maxHealth, {String? bossName}) {
    // 층별 보스 이름 결정
    final name = bossName ?? _getBossNameForFloor(state.currentFloor);
    state = state.copyWith(
      isBossFight: true,
      bossHealth: maxHealth,
      bossMaxHealth: maxHealth,
      bossName: name,
    );
  }

  /// 층별 보스 이름 반환
  String _getBossNameForFloor(int floor) {
    switch (floor) {
      case 1:
        return '이그드라';
      case 2:
        return '발두르';
      case 3:
        return '실렌시아';
      case 4:
        return '리리아나';
      case 5:
        return '그림자 자아';
      case 6:
        return '망각의 화신';
      default:
        return '거대 슬라임';
    }
  }

  /// 보스 체력 업데이트
  void updateBossHealth(double health) {
    state = state.copyWith(bossHealth: health);
  }

  /// 아이템 획득 콜백
  void _onItemCollected(Item item) {
    ref.read(inventoryProvider.notifier).addItem(item);
    ref.read(gameStateProvider.notifier).incrementItemsCollected();

    // 장비 스탯 업데이트
    final inventory = ref.read(inventoryProvider);
    state.game?.updatePlayerEquipment(
      attack: inventory.totalAttackBonus,
      defense: inventory.totalDefenseBonus,
    );
  }

  /// 게임 오버 콜백
  void _onGameOver() {
    ref.read(gameStateProvider.notifier).gameOver();
    state = state.copyWith(currentScreen: GameScreen.gameOver);
  }

  /// 적 처치 콜백
  void _onEnemyKilled() {
    ref.read(gameStateProvider.notifier).incrementEnemiesKilled();
    ref.read(gameStateProvider.notifier).addScore(10);
  }

  /// 보스 시작 콜백
  void _onBossStart(double maxHealth, String bossName) {
    state = state.copyWith(
      isBossFight: true,
      bossHealth: maxHealth,
      bossMaxHealth: maxHealth,
      bossName: bossName,
    );
  }

  /// 게임 승리 콜백 (엔딩에서 호출)
  void _onVictory(bool isTrueEnding) {
    // 엔딩 도달 시 세이브 삭제 (완료된 게임)
    SaveManager.instance.deleteSave();

    ref.read(gameStateProvider.notifier).victory();
    state = state.copyWith(
      currentScreen: GameScreen.victory,
      endingType: isTrueEnding ? EndingType.truE : EndingType.normal,
    );
  }

  /// 방 클리어 콜백 (자동 세이브)
  void _onRoomChanged(Room room) {
    // 보스방이 아닌 일반 방 클리어 시 자동 세이브
    if (room.isCleared && room.type != RoomType.boss) {
      _autoSave();
    }
  }

  /// 층 클리어 콜백 (자동 세이브)
  void _onFloorCleared(int floor) {
    state = state.copyWith(currentFloor: floor + 1);
    _autoSave();
  }

  /// 자동 세이브 수행
  Future<void> _autoSave() async {
    final gameState = ref.read(gameStateProvider);
    final inventory = ref.read(inventoryProvider);
    final game = state.game;

    if (game == null) return;

    final saveData = SaveManager.createSaveData(
      currentFloor: state.currentFloor,
      currentHearts: game.currentHearts,
      health: game.currentHealth,
      maxHealth: game.maxHealth,
      score: gameState.score,
      playTime: game.playTime,
      enemiesKilled: gameState.enemiesKilled,
      itemsCollected: gameState.itemsCollected,
      gold: inventory.gold,
      inventory: inventory.slots,
      equippedWeapon: inventory.equippedWeapon,
      equippedArmor: inventory.equippedArmor,
    );

    await SaveManager.instance.saveGame(saveData);
  }

  /// 승리 (엔딩 타입 지정)
  void victory({EndingType endingType = EndingType.normal}) {
    ref.read(gameStateProvider.notifier).victory();
    state = state.copyWith(
      currentScreen: GameScreen.victory,
      endingType: endingType,
    );
  }

  /// 대화 표시 토글
  void setDialogueVisible(bool visible) {
    state = state.copyWith(showDialogue: visible);
  }

  /// 대화 시작 콜백
  void _onDialogueStart() {
    state.game?.pause();
    state = state.copyWith(
      showDialogue: true,
      isPaused: true,
    );
  }

  /// 대화 종료 콜백
  void _onDialogueEnd() {
    state.game?.resume();
    state = state.copyWith(
      showDialogue: false,
      isPaused: false,
      clearDialogue: true,
    );
  }

  /// 대화 노드 변경 콜백
  void _onDialogueNodeChanged(DialogueNode node) {
    state = state.copyWith(
      currentDialogueNode: node,
      currentDialogueChoices: node.choices ?? const [],
    );
  }

  /// 대화 진행 (다음 노드로)
  void advanceDialogue() {
    state.game?.advanceDialogue();
  }

  /// 대화 선택지 선택
  void selectDialogueChoice(int choiceIndex) {
    state.game?.selectDialogueChoice(choiceIndex);
  }

  /// 스킬 사용 콜백
  void _onSkillUsed(String skillId, double manaCost) {
    // Provider에 쿨다운 시작 알림
    final skill = state.game?.skillManager.getSkillById(skillId);
    if (skill != null) {
      ref.read(playerSkillProvider.notifier).startCooldown(skillId, skill.cooldown);
      ref.read(playerSkillProvider.notifier).consumeMana(manaCost);
    }
  }

  /// 심장 게이지 변경 콜백
  void _onHeartGaugeChanged(double current, double max) {
    ref.read(heartGaugeProvider.notifier).setGauge(current);
  }

  /// 마나 변경 콜백 - SkillManager와 Provider 동기화
  void _onManaChanged(double current, double max) {
    // SkillManager의 마나 값을 Provider에 동기화
    final provider = ref.read(playerSkillProvider.notifier);
    final currentState = ref.read(playerSkillProvider);

    // 현재 Provider 마나와 다르면 동기화
    if ((currentState.currentMana - current).abs() > 0.1) {
      // 마나 차이 계산하여 소모 또는 회복
      if (current < currentState.currentMana) {
        provider.consumeMana(currentState.currentMana - current);
      } else {
        provider.restoreMana(current - currentState.currentMana);
      }
    }
  }
}

/// 게임 컨트롤러 Provider
final gameControllerProvider =
    StateNotifierProvider<GameControllerNotifier, GameControllerState>((ref) {
  return GameControllerNotifier(ref);
});
