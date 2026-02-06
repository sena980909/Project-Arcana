/// Arcana: The Three Hearts - 메인 진입점
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/models/player_state.dart';
import 'data/models/item_data.dart';
import 'data/repositories/config_repository.dart';
import 'data/services/database_service.dart';
import 'game/arcana_game.dart';
import 'game/systems/audio_system.dart';
import 'providers/game_providers.dart';
import 'ui/hud_overlay.dart';
import 'ui/shop_overlay.dart';
import 'ui/inventory_overlay.dart';
import 'ui/main_menu_overlay.dart';
import 'utils/game_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 초기화
  await Future.wait([
    ConfigRepository.instance.initialize(),
    DatabaseService.instance.initialize(),
    AudioSystem.instance.initialize(),
  ]);

  runApp(
    const ProviderScope(
      child: ArcanaApp(),
    ),
  );
}

class ArcanaApp extends StatelessWidget {
  const ArcanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcana: The Three Hearts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
      ),
      home: const GameScreen(),
    );
  }
}

/// 게임 화면
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  ArcanaGame? _game;

  // 메뉴 상태
  bool _isInMainMenu = true;
  bool _isGameStarted = false;

  // UI 상태 (로컬 관리 - Riverpod 빌드 중 수정 방지)
  bool _isShopOpen = false;
  bool _isInventoryOpen = false;
  String _lastKey = '';

  // 인벤토리 상태
  List<InventoryItem> _inventory = [];
  Map<String, String?> _equipment = {
    'weapon': null,
    'armor': null,
    'accessory1': null,
    'accessory2': null,
  };

  // 게임 상태 (로컬)
  double _hp = 100;
  double _maxHp = 100;
  double _mana = 100;
  double _maxMana = 100;
  int _gold = 100;
  int _heartGauge = 0;

  // 현재 저장 슬롯
  int _currentSaveSlot = 1;

  @override
  void initState() {
    super.initState();

    // 로거 초기화
    GameLogger.instance.init();
    GameLogger.instance.log('SYSTEM', '앱 시작');

    // 글로벌 키보드 핸들러
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  /// 새 게임 시작
  void _startNewGame() {
    setState(() {
      _isInMainMenu = false;
      _isGameStarted = true;

      // 상태 초기화
      _hp = 100;
      _maxHp = 100;
      _mana = 100;
      _maxMana = 100;
      _gold = 100;
      _heartGauge = 0;
      _inventory = [];
      _equipment = {
        'weapon': null,
        'armor': null,
        'accessory1': null,
        'accessory2': null,
      };
    });

    _initializeGame();
    GameLogger.instance.log('SYSTEM', '새 게임 시작');

    // 챕터 1 BGM 재생
    AudioSystem.instance.playChapterBgm(1);
  }

  /// 이어하기 (가장 최근 저장)
  Future<void> _continueGame() async {
    // 가장 최근 저장 슬롯 찾기
    final slots = await DatabaseService.instance.getAllSaveSlots();
    SaveSlot? latestSave;
    int latestSlot = 1;

    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (slot != null) {
        if (latestSave == null || slot.updatedAt.isAfter(latestSave.updatedAt)) {
          latestSave = slot;
          latestSlot = i + 1;
        }
      }
    }

    if (latestSave != null) {
      await _loadGame(latestSlot);
    } else {
      // 저장 데이터가 없으면 새 게임
      _startNewGame();
    }
  }

  /// 특정 슬롯 불러오기
  Future<void> _loadGame(int slot) async {
    final save = await DatabaseService.instance.loadGame(slot);
    if (save == null) return;

    setState(() {
      _isInMainMenu = false;
      _isGameStarted = true;
      _currentSaveSlot = slot;

      // 플레이어 상태 복원
      _hp = save.playerState.hp;
      _maxHp = save.playerState.maxHp;
      _mana = save.playerState.mana;
      _maxMana = save.playerState.maxMana;
      _gold = save.playerState.gold;
      _heartGauge = save.playerState.heartGauge;

      // 인벤토리 복원
      _inventory = List.from(save.playerState.inventory);
      _equipment = {
        'weapon': save.playerState.equipment.weapon,
        'armor': save.playerState.equipment.armor,
        'accessory1': save.playerState.equipment.accessory1,
        'accessory2': save.playerState.equipment.accessory2,
      };
    });

    // 게임 상태 복원
    ref.read(gameStateProvider.notifier).loadState(save.gameState);

    _initializeGame();
    GameLogger.instance.log('SAVE', '게임 불러오기 완료 (슬롯 $slot)');

    // 챕터별 BGM 재생
    AudioSystem.instance.playChapterBgm(save.gameState.currentChapter);
  }

  /// 게임 초기화
  void _initializeGame() {
    _game = ArcanaGame(
      onPlayerHpChanged: (hp, maxHp) {
        if (mounted) {
          setState(() {
            _hp = hp;
            _maxHp = maxHp;
          });
        }
      },
      onManaChanged: (mana) {
        if (mounted) {
          setState(() {
            _mana = mana;
          });
        }
      },
      onGoldChanged: (gold) {
        if (mounted) {
          setState(() {
            _gold = gold;
          });
        }
      },
      onHeartGaugeChanged: (gauge) {
        if (mounted) {
          setState(() {
            _heartGauge = gauge;
          });
        }
      },
      onEnemyKilled: () {
        ref.read(gameStateProvider.notifier).addKill();
      },
    );
  }

  @override
  void dispose() {
    GameLogger.instance.close();
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  /// 키보드 이벤트 핸들러
  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() => _lastKey = event.logicalKey.keyLabel);

      // ESC: 오버레이 닫기
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (_isShopOpen) {
          _closeShop();
          return true;
        }
        if (_isInventoryOpen) {
          _closeInventory();
          return true;
        }
      }

      // I: 인벤토리 토글
      if (event.logicalKey == LogicalKeyboardKey.keyI) {
        if (_isInventoryOpen) {
          _closeInventory();
        } else {
          _openInventory();
        }
        return true;
      }

      // E: 상호작용 / 상점
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        if (!_isShopOpen) {
          _openShop();
        }
        return true;
      }

      // F4: 상점 토글 (디버그)
      if (event.logicalKey == LogicalKeyboardKey.f4) {
        if (_isShopOpen) {
          _closeShop();
        } else {
          _openShop();
        }
        return true;
      }

      // F1: 디버그 정보 토글
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        _game?.toggleDebug();
        return true;
      }

      // F3: 모든 적 처치 (디버그)
      if (event.logicalKey == LogicalKeyboardKey.f3) {
        _game?.killAllEnemies();
        return true;
      }

      // F5: 저장 (디버그)
      if (event.logicalKey == LogicalKeyboardKey.f5) {
        _quickSave();
        return true;
      }

      // F9: 불러오기 (디버그)
      if (event.logicalKey == LogicalKeyboardKey.f9) {
        _quickLoad();
        return true;
      }
    }
    return false;
  }

  void _openShop() {
    setState(() => _isShopOpen = true);
    _game?.paused = true;
  }

  void _closeShop() {
    setState(() => _isShopOpen = false);
    _game?.paused = false;
  }

  void _openInventory() {
    setState(() => _isInventoryOpen = true);
    _game?.paused = true;
  }

  void _closeInventory() {
    setState(() => _isInventoryOpen = false);
    _game?.paused = false;
  }

  void _useItem(String itemId) {
    // 인벤토리에서 아이템 찾기
    final index = _inventory.indexWhere((item) => item.itemId == itemId);
    if (index == -1) return;

    final item = _inventory[index];
    final itemData = ConfigRepository.instance.getItem(itemId);
    if (itemData == null) return;

    // 소비 아이템 효과 적용
    if (itemData.type == ItemType.consumable) {
      if (itemId.contains('health') || itemId == 'potion') {
        _game?.healPlayer(30);
      } else if (itemId.contains('mana')) {
        _game?.restoreMana(30);
      }

      // 수량 감소
      setState(() {
        if (item.quantity > 1) {
          _inventory[index] = InventoryItem(
            itemId: item.itemId,
            quantity: item.quantity - 1,
          );
        } else {
          _inventory.removeAt(index);
        }
      });

      GameLogger.instance.log('ITEM', '아이템 사용: $itemId');
    }
  }

  void _equipItem(String itemId, String slot) {
    // 기존 장비 해제
    final oldItemId = _equipment[slot];
    if (oldItemId != null) {
      _unequipItem(slot);
    }

    // 인벤토리에서 아이템 제거
    final index = _inventory.indexWhere((item) => item.itemId == itemId);
    if (index != -1) {
      setState(() {
        final item = _inventory[index];
        if (item.quantity > 1) {
          _inventory[index] = InventoryItem(
            itemId: item.itemId,
            quantity: item.quantity - 1,
          );
        } else {
          _inventory.removeAt(index);
        }
        _equipment[slot] = itemId;
      });

      GameLogger.instance.log('ITEM', '장비 장착: $itemId -> $slot');
    }
  }

  void _unequipItem(String slot) {
    final itemId = _equipment[slot];
    if (itemId == null) return;

    setState(() {
      _equipment[slot] = null;

      // 인벤토리에 추가
      final existingIndex = _inventory.indexWhere((item) => item.itemId == itemId);
      if (existingIndex != -1) {
        final existing = _inventory[existingIndex];
        _inventory[existingIndex] = InventoryItem(
          itemId: itemId,
          quantity: existing.quantity + 1,
        );
      } else {
        _inventory.add(InventoryItem(itemId: itemId, quantity: 1));
      }
    });

    GameLogger.instance.log('ITEM', '장비 해제: $slot');
  }

  void _addItemToInventory(String itemId, {int quantity = 1}) {
    setState(() {
      final existingIndex = _inventory.indexWhere((item) => item.itemId == itemId);
      if (existingIndex != -1) {
        final existing = _inventory[existingIndex];
        _inventory[existingIndex] = InventoryItem(
          itemId: itemId,
          quantity: existing.quantity + quantity,
        );
      } else {
        _inventory.add(InventoryItem(itemId: itemId, quantity: quantity));
      }
    });
  }

  Future<void> _quickSave() async {
    // 현재 게임 상태를 PlayerState로 변환 (인벤토리 포함)
    final playerState = PlayerState(
      hp: _hp,
      maxHp: _maxHp,
      mana: _mana,
      maxMana: _maxMana,
      gold: _gold,
      heartGauge: _heartGauge,
      inventory: _inventory,
      equipment: Equipment(
        weapon: _equipment['weapon'],
        armor: _equipment['armor'],
        accessory1: _equipment['accessory1'],
        accessory2: _equipment['accessory2'],
      ),
    );
    final gameState = ref.read(gameStateProvider);

    await DatabaseService.instance.saveGame(_currentSaveSlot, playerState, gameState);
    GameLogger.instance.log('SAVE', '빠른 저장 완료 (슬롯 $_currentSaveSlot)');
  }

  Future<void> _quickLoad() async {
    final save = await DatabaseService.instance.loadGame(_currentSaveSlot);
    if (save != null) {
      setState(() {
        _hp = save.playerState.hp;
        _maxHp = save.playerState.maxHp;
        _mana = save.playerState.mana;
        _maxMana = save.playerState.maxMana;
        _gold = save.playerState.gold;
        _heartGauge = save.playerState.heartGauge;
        _inventory = List.from(save.playerState.inventory);
        _equipment = {
          'weapon': save.playerState.equipment.weapon,
          'armor': save.playerState.equipment.armor,
          'accessory1': save.playerState.equipment.accessory1,
          'accessory2': save.playerState.equipment.accessory2,
        };
      });
      ref.read(gameStateProvider.notifier).loadState(save.gameState);
      GameLogger.instance.log('SAVE', '빠른 불러오기 완료 (슬롯 $_currentSaveSlot)');
    }
  }

  /// 메인 메뉴로 돌아가기
  void _returnToMainMenu() {
    setState(() {
      _isInMainMenu = true;
      _isGameStarted = false;
      _game = null;
    });
    AudioSystem.instance.playMainTitleBgm();
  }

  @override
  Widget build(BuildContext context) {
    // 메인 메뉴 화면
    if (_isInMainMenu) {
      return Scaffold(
        body: MainMenuOverlay(
          onNewGame: _startNewGame,
          onContinue: _continueGame,
          onLoadSlot: _loadGame,
        ),
      );
    }

    // 게임 화면
    return Scaffold(
      body: Stack(
        children: [
          // 게임
          if (_game != null) GameWidget(game: _game!),

          // HUD (로컬 상태 사용)
          HudOverlay(
            hp: _hp,
            maxHp: _maxHp,
            mana: _mana,
            maxMana: _maxMana,
            gold: _gold,
            heartGauge: _heartGauge,
            lastKey: _lastKey,
          ),

          // 상점 오버레이
          if (_isShopOpen)
            ShopOverlay(
              gold: _gold,
              onClose: _closeShop,
              onBuy: (itemId, cost) {
                if (_gold >= cost) {
                  setState(() => _gold -= cost);
                  GameLogger.instance.logItemBuy(itemId, cost, _gold);
                  // 아이템을 인벤토리에 추가
                  _addItemToInventory(itemId);
                }
              },
            ),

          // 인벤토리 오버레이
          if (_isInventoryOpen)
            InventoryOverlay(
              inventory: _inventory,
              equipment: _equipment,
              onClose: _closeInventory,
              onUseItem: _useItem,
              onEquipItem: _equipItem,
              onUnequipItem: _unequipItem,
            ),
        ],
      ),
    );
  }
}
