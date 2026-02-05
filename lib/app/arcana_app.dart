/// Arcana: The Three Hearts - 메인 앱
/// 전체 앱 구조 및 라우팅
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/arcana_game.dart';
import '../providers/game_state_provider.dart';
import '../providers/inventory_provider.dart';
import '../ui/screens/game_over_screen.dart';
import '../ui/screens/inventory_screen.dart';
import '../ui/screens/main_menu_screen.dart';
import '../ui/screens/pause_menu.dart';
import '../ui/screens/victory_screen.dart';
import '../ui/overlays/dialogue_overlay.dart';
import '../ui/widgets/boss_health_bar.dart';
import '../ui/widgets/heart_gauge_bar.dart';
import '../ui/widgets/skill_slots.dart';
import '../data/services/save_manager.dart';
import '../providers/heart_gauge_provider.dart';
import '../providers/player_skill_provider.dart';
import 'game_controller.dart';

/// 메인 앱 위젯
class ArcanaApp extends StatelessWidget {
  const ArcanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Arcana: The Three Hearts',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: const Color(0xFF0a0a1a),
          fontFamily: 'Roboto',
        ),
        home: const ArcanaHome(),
      ),
    );
  }
}

/// 메인 홈 위젯
class ArcanaHome extends ConsumerStatefulWidget {
  const ArcanaHome({super.key});

  @override
  ConsumerState<ArcanaHome> createState() => _ArcanaHomeState();
}

class _ArcanaHomeState extends ConsumerState<ArcanaHome> {
  @override
  void initState() {
    super.initState();
    // 화면 방향 고정 (가로)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 전체 화면
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(gameControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 메인 콘텐츠
          _buildMainContent(controllerState),

          // 오버레이들
          ..._buildOverlays(controllerState),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildMainContent(GameControllerState state) {
    switch (state.currentScreen) {
      case GameScreen.mainMenu:
        return MainMenuScreen(
          onStartGame: () {
            ref.read(gameControllerProvider.notifier).startNewGame();
          },
          onContinue: () {
            ref.read(gameControllerProvider.notifier).continueGame();
          },
          hasSaveData: SaveManager.instance.hasSaveData,
        );

      case GameScreen.playing:
        if (state.game == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _GameplayWidget(
          game: state.game!,
          currentFloor: state.currentFloor,
          isBossFight: state.isBossFight,
          bossHealth: state.bossHealth,
          bossMaxHealth: state.bossMaxHealth,
          bossName: state.bossName,
          onPause: () {
            ref.read(gameControllerProvider.notifier).pauseGame();
          },
          onInventory: () {
            ref.read(gameControllerProvider.notifier).toggleInventory();
          },
        );

      case GameScreen.gameOver:
        return GameOverScreen(
          onRestart: () {
            ref.read(gameControllerProvider.notifier).restartGame();
            ref.read(gameControllerProvider.notifier).startNewGame();
          },
          onMainMenu: () {
            ref.read(gameControllerProvider.notifier).goToMainMenu();
          },
        );

      case GameScreen.victory:
        return VictoryScreen(
          endingType: state.endingType ?? EndingType.normal,
          onNewGame: () {
            ref.read(gameControllerProvider.notifier).startNewGame();
          },
          onMainMenu: () {
            ref.read(gameControllerProvider.notifier).goToMainMenu();
          },
        );
    }
  }

  /// 오버레이들 빌드
  List<Widget> _buildOverlays(GameControllerState state) {
    final overlays = <Widget>[];

    // 일시정지 메뉴 (대화 중에는 표시하지 않음)
    if (state.isPaused && state.currentScreen == GameScreen.playing && !state.showDialogue) {
      overlays.add(
        PauseMenu(
          currentFloor: state.currentFloor,
          onResume: () {
            ref.read(gameControllerProvider.notifier).resumeGame();
          },
          onRestart: () {
            ref.read(gameControllerProvider.notifier).restartGame();
            ref.read(gameControllerProvider.notifier).startNewGame();
          },
          onMainMenu: () {
            ref.read(gameControllerProvider.notifier).goToMainMenu();
          },
        ),
      );
    }

    // 인벤토리
    if (state.showInventory && state.currentScreen == GameScreen.playing) {
      overlays.add(
        InventoryScreen(
          onClose: () {
            ref.read(gameControllerProvider.notifier).closeInventory();
          },
          onUseItem: (healAmount) {
            ref.read(gameControllerProvider.notifier).useHealItem(healAmount);
          },
        ),
      );
    }

    // 대화 오버레이
    if (state.showDialogue &&
        state.currentScreen == GameScreen.playing &&
        state.currentDialogueNode != null) {
      overlays.add(
        DialogueOverlay(
          currentNode: state.currentDialogueNode!,
          visibleChoices: state.currentDialogueChoices,
          onAdvance: () {
            ref.read(gameControllerProvider.notifier).advanceDialogue();
          },
          onChoiceSelected: (index) {
            ref.read(gameControllerProvider.notifier).selectDialogueChoice(index);
          },
        ),
      );
    }

    return overlays;
  }
}

/// 게임플레이 위젯
class _GameplayWidget extends ConsumerWidget {
  const _GameplayWidget({
    required this.game,
    required this.currentFloor,
    required this.isBossFight,
    required this.bossHealth,
    required this.bossMaxHealth,
    required this.bossName,
    required this.onPause,
    required this.onInventory,
  });

  final ArcanaGame game;
  final int currentFloor;
  final bool isBossFight;
  final double bossHealth;
  final double bossMaxHealth;
  final String bossName;
  final VoidCallback onPause;
  final VoidCallback onInventory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final inventory = ref.watch(inventoryProvider);

    return Stack(
      children: [
        // 게임 화면
        GameWidget(game: game),

        // HUD
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 HUD
                Row(
                  children: [
                    // 하트 표시
                    _HeartsDisplay(hearts: game.isLoaded ? game.currentHearts : 3),

                    const SizedBox(width: 16),

                    // 챕터 표시
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CH.$currentFloor',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 점수
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${gameState.score}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // 골드
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.amber.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${inventory.gold}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 인벤토리 버튼
                    IconButton(
                      onPressed: onInventory,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // 일시정지 버튼
                    IconButton(
                      onPressed: onPause,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // 보스 체력바
                if (isBossFight)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: BossHealthBar(
                      bossName: bossName.isNotEmpty ? bossName : '보스',
                      currentHealth: bossHealth,
                      maxHealth: bossMaxHealth,
                      isEnraged: bossHealth / bossMaxHealth <= 0.3,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 하단 UI (심장 게이지 + 스킬 슬롯)
        _BottomHUD(ref: ref),
      ],
    );
  }
}

/// 하단 HUD (심장 게이지, 스킬 슬롯)
class _BottomHUD extends StatelessWidget {
  const _BottomHUD({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final heartGauge = ref.watch(heartGaugeProvider);
    final playerSkill = ref.watch(playerSkillProvider);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 좌측: 심장 게이지
            HeartGaugeBar(
              current: heartGauge.current,
              max: heartGauge.max,
              width: 180,
              height: 14,
            ),

            const Spacer(),

            // 우측: 스킬 슬롯
            SkillSlotsCompact(
              equippedSkills: playerSkill.equippedSkills,
              skillCooldowns: playerSkill.skillCooldowns,
            ),
          ],
        ),
      ),
    );
  }
}

/// 하트 표시 위젯
class _HeartsDisplay extends StatelessWidget {
  const _HeartsDisplay({required this.hearts});

  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final isActive = index < hearts;
          Color heartColor;

          switch (index) {
            case 0:
              heartColor = Colors.red; // Body
            case 1:
              heartColor = Colors.blue; // Mind
            case 2:
              heartColor = Colors.purple; // Soul
            default:
              heartColor = Colors.grey;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isActive ? Icons.favorite : Icons.favorite_border,
              color: isActive ? heartColor : Colors.grey.shade700,
              size: 24,
            ),
          );
        }),
      ),
    );
  }
}
