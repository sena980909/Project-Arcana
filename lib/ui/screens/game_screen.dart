/// Arcana: The Three Hearts - 게임 화면
/// 게임 진입점 위젯
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/dialogue.dart';
import '../../data/model/item.dart';
import '../../game/arcana_game.dart';
import '../../game/interface/game_hud.dart';
import '../../providers/game_state_provider.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/dialogue_overlay.dart';

/// 게임 화면 위젯
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  ArcanaGame? _game;

  /// 현재 대화 노드 (UI 표시용)
  DialogueNode? _currentDialogueNode;

  /// 대화 중 여부
  bool _isInDialogue = false;

  @override
  void initState() {
    super.initState();

    // 전체 화면 모드 설정
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // 가로 모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 시스템 UI 복원
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  /// 게임 인스턴스 생성
  ArcanaGame _createGame() {
    final gameState = ref.read(gameStateProvider);
    final inventoryState = ref.read(inventoryProvider);

    // 인벤토리 아이템 ID 목록 추출
    final inventoryItemIds = inventoryState.slots.map((s) => s.item.id).toList();

    return ArcanaGame(
      gameState: gameState,
      inventoryItemIds: inventoryItemIds,
      onDialogueStart: _handleDialogueStart,
      onDialogueEnd: _handleDialogueEnd,
      onDialogueNodeChanged: _handleDialogueNodeChanged,
      onTriggerExecuted: _handleTriggerExecuted,
    );
  }

  /// 대화 시작 처리
  void _handleDialogueStart() {
    setState(() {
      _isInDialogue = true;
    });
  }

  /// 대화 종료 처리
  void _handleDialogueEnd() {
    setState(() {
      _isInDialogue = false;
      _currentDialogueNode = null;
    });
  }

  /// 대화 노드 변경 처리
  void _handleDialogueNodeChanged(DialogueNode node) {
    setState(() {
      _currentDialogueNode = node;
    });
  }

  /// 트리거 실행 처리
  void _handleTriggerExecuted(DialogueTrigger trigger) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    switch (trigger.type) {
      case TriggerType.setFlag:
        if (trigger.flagName != null) {
          gameStateNotifier.setFlag(
            trigger.flagName!,
            value: trigger.flagValue ?? true,
          );
        }
      case TriggerType.giveItem:
        if (trigger.itemId != null) {
          // 아이템 지급 로직 (Items 클래스에서 아이템 찾기)
          final item = _findItemById(trigger.itemId!);
          if (item != null) {
            inventoryNotifier.addItem(item, quantity: trigger.amount ?? 1);
          }
        }
      case TriggerType.giveGold:
        if (trigger.amount != null) {
          inventoryNotifier.addGold(trigger.amount!);
        }
      case TriggerType.heal:
        if (trigger.amount != null) {
          _game?.healPlayer(trigger.amount!);
        }
      case TriggerType.unlockShop:
        // 상점 열기 (추후 구현)
        break;
      case TriggerType.startQuest:
        // 퀘스트 시작 (추후 구현)
        break;
    }
  }

  /// ID로 아이템 찾기
  Item? _findItemById(String itemId) {
    // Items 클래스에서 아이템 찾기
    return Items.findById(itemId);
  }

  /// 대화 진행 (다음으로)
  void _advanceDialogue() {
    if (_game == null) return;

    if (_game!.currentDialogueNode?.hasChoices == true) {
      // 선택지가 있으면 진행 불가
      return;
    }

    _game!.advanceDialogue();
  }

  /// 선택지 선택
  void _selectChoice(int index) {
    _game?.selectDialogueChoice(index);
  }

  @override
  Widget build(BuildContext context) {
    // 게임 인스턴스가 없으면 생성
    _game ??= _createGame();

    return Scaffold(
      body: Stack(
        children: [
          // 메인 게임
          GameWidget(game: _game!),

          // HUD 오버레이
          const Positioned.fill(
            child: GameHud(),
          ),

          // 대화 오버레이
          if (_isInDialogue && _currentDialogueNode != null)
            Positioned.fill(
              child: DialogueOverlay(
                node: _currentDialogueNode!,
                choices: _game?.currentDialogueChoices ?? [],
                onAdvance: _advanceDialogue,
                onChoiceSelected: _selectChoice,
              ),
            ),

          // 뒤로가기 버튼
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 게임 종료 확인 다이얼로그
  void _showExitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          '게임 종료',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '메인 메뉴로 돌아가시겠습니까?\n진행 상황은 저장되지 않습니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              '종료',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
