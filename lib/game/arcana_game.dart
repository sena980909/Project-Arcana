/// Arcana: The Three Hearts - 메인 게임 클래스
library;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import 'player.dart';
import 'enemy.dart';
import 'floor_component.dart';
import '../utils/game_logger.dart';

/// 콜백 타입 정의
typedef HpChangedCallback = void Function(double hp, double maxHp);
typedef ValueChangedCallback<T> = void Function(T value);
typedef VoidCallback = void Function();

/// 메인 게임 클래스
class ArcanaGame extends FlameGame with HasCollisionDetection {
  ArcanaGame({
    this.onPlayerHpChanged,
    this.onManaChanged,
    this.onGoldChanged,
    this.onHeartGaugeChanged,
    this.onEnemyKilled,
    this.onPerfectDodge,
  });

  // 콜백
  final HpChangedCallback? onPlayerHpChanged;
  final ValueChangedCallback<double>? onManaChanged;
  final ValueChangedCallback<int>? onGoldChanged;
  final ValueChangedCallback<int>? onHeartGaugeChanged;
  final VoidCallback? onEnemyKilled;
  final VoidCallback? onPerfectDodge;

  // 게임 컴포넌트
  late Player player;
  final List<Enemy> enemies = [];

  // 게임 상태
  int gold = 100;
  int heartGauge = 0;
  double mana = 100;
  double maxMana = 100;
  bool debugMode = false;

  // 슬로우 모션 상태
  double _slowMotionTimer = 0;
  double _timeScale = 1.0;

  // 에셋 경로
  static const String _assetPath =
      'itchio/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/';

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 바닥 생성
    world.add(FloorComponent());

    // 플레이어 생성
    player = Player(
      position: Vector2(400, 300),
      assetPath: _assetPath,
      onHpChanged: (hp, maxHp) {
        onPlayerHpChanged?.call(hp, maxHp);
      },
      onPerfectDodge: () {
        _triggerPerfectDodge();
      },
    );
    world.add(player);

    // 적 생성
    _spawnEnemies();

    // 카메라 설정
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 2.5; // 2.5배 확대
    camera.follow(player);

    // 초기값 전달
    onGoldChanged?.call(gold);
    onManaChanged?.call(mana);
    onHeartGaugeChanged?.call(heartGauge);
  }

  /// 적 스폰
  void _spawnEnemies() {
    final spawnPositions = [
      Vector2(600, 200),
      Vector2(200, 400),
      Vector2(700, 450),
      Vector2(150, 150),
    ];

    final enemyTypes = ['goblin', 'skelet', 'orc_warrior', 'imp'];

    for (int i = 0; i < spawnPositions.length; i++) {
      final pos = spawnPositions[i];
      final type = enemyTypes[i % enemyTypes.length];
      final enemy = Enemy(
        position: pos,
        assetPath: _assetPath,
        enemyType: type,
        player: player,
        onDeath: (e) => _onEnemyDeath(e),
        onAttackHit: (damage) => _onPlayerHitByEnemy(damage),
      );
      enemies.add(enemy);
      world.add(enemy);
      GameLogger.instance.logEnemySpawn(type, pos.x, pos.y);
    }
  }

  /// 적 사망
  void _onEnemyDeath(Enemy enemy) {
    enemies.remove(enemy);

    // 골드 획득
    final goldReward = 10 + enemy.maxHp ~/ 5;
    gold += goldReward;
    onGoldChanged?.call(gold);

    // 마나 획득 (처치 시 +15)
    mana = (mana + 15).clamp(0, maxMana);
    onManaChanged?.call(mana);

    // 골드 로그
    GameLogger.instance.logGoldGain(goldReward, gold);

    // 심장 게이지 충전
    heartGauge = (heartGauge + 5).clamp(0, 100);
    onHeartGaugeChanged?.call(heartGauge);

    // 적 처치 콜백
    onEnemyKilled?.call();
  }

  /// 플레이어가 적에게 맞았을 때
  void _onPlayerHitByEnemy(double damage) {
    player.takeDamage(damage);
  }

  /// 완벽 회피 발동
  void _triggerPerfectDodge() {
    // 심장 게이지 +10
    heartGauge = (heartGauge + 10).clamp(0, 100);
    onHeartGaugeChanged?.call(heartGauge);

    // 슬로우 모션 0.2초
    _slowMotionTimer = 0.2;
    _timeScale = 0.3;

    // 콜백
    onPerfectDodge?.call();

    GameLogger.instance.log('COMBAT', '완벽 회피! 심장 게이지: $heartGauge');
  }

  /// 플레이어 회복
  void healPlayer(double amount) {
    player.heal(amount);
  }

  /// 마나 회복
  void restoreMana(double amount) {
    mana = (mana + amount).clamp(0, maxMana);
    onManaChanged?.call(mana);
  }

  /// 마나 사용
  bool useMana(double amount) {
    if (mana >= amount) {
      mana -= amount;
      onManaChanged?.call(mana);
      return true;
    }
    return false;
  }

  /// 심장 게이지 사용 (궁극기)
  bool useHeartGauge() {
    if (heartGauge >= 100) {
      heartGauge = 0;
      onHeartGaugeChanged?.call(heartGauge);
      return true;
    }
    return false;
  }

  /// 모든 적 처치 (디버그)
  void killAllEnemies() {
    for (final enemy in [...enemies]) {
      enemy.takeDamage(9999);
    }
  }

  /// 디버그 모드 토글
  void toggleDebug() {
    debugMode = !debugMode;
  }

  // 이전 프레임의 키 상태 (중복 방지)
  final Set<LogicalKeyboardKey> _previousKeys = {};

  /// 키보드 입력 처리
  void _handleKeyboardInput() {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // 이동 처리
    Vector2 direction = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      direction.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      direction.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      direction.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      direction.x += 1;
    }

    player.moveDirection = direction;

    // 새로 눌린 키만 처리 (KeyDown 시뮬레이션)
    for (final key in keysPressed) {
      if (!_previousKeys.contains(key)) {
        // 공격 (J키 또는 스페이스)
        if (key == LogicalKeyboardKey.keyJ ||
            key == LogicalKeyboardKey.space) {
          final hitCount = player.attack(enemies);
          // 적중 시 마나 +5
          if (hitCount > 0) {
            mana = (mana + 5 * hitCount).clamp(0, maxMana);
            onManaChanged?.call(mana);
          }
        }
        // 대시 (Shift)
        if (key == LogicalKeyboardKey.shiftLeft ||
            key == LogicalKeyboardKey.shiftRight) {
          player.dash();
        }
        // 스킬 (Q/W/E)
        if (key == LogicalKeyboardKey.keyQ) {
          _useSkill(0);
        }
        if (key == LogicalKeyboardKey.keyW) {
          // W는 이동에 사용되므로 스킬 사용은 별도 조합 필요
          // 일단 비활성화
        }
        // 궁극기 (R)
        if (key == LogicalKeyboardKey.keyR) {
          _useUltimate();
        }
      }
    }

    _previousKeys.clear();
    _previousKeys.addAll(keysPressed);
  }

  /// 스킬 사용
  void _useSkill(int slotIndex) {
    // TODO: 스킬 시스템 구현 후 연결
    GameLogger.instance.log('SKILL', '스킬 슬롯 $slotIndex 사용 시도');
  }

  /// 궁극기 사용
  void _useUltimate() {
    if (heartGauge >= 100) {
      heartGauge = 0;
      onHeartGaugeChanged?.call(heartGauge);

      // TODO: 궁극기 효과 구현
      GameLogger.instance.log('SKILL', '궁극기 발동!');

      // 임시: 모든 적에게 대미지
      for (final enemy in [...enemies]) {
        enemy.takeDamage(100);
      }
    }
  }

  // 마나 콜백 최적화용
  double _lastManaCallback = 0;
  static const double _manaCallbackInterval = 0.1; // 0.1초마다만 콜백

  @override
  void update(double dt) {
    // 슬로우 모션 처리
    if (_slowMotionTimer > 0) {
      _slowMotionTimer -= dt;
      if (_slowMotionTimer <= 0) {
        _timeScale = 1.0;
      }
    }

    // 시간 스케일 적용
    final scaledDt = dt * _timeScale;

    // 키보드 입력 처리
    _handleKeyboardInput();

    // 마나 자연 회복 (초당 2)
    final prevMana = mana;
    mana = (mana + 2 * scaledDt).clamp(0, maxMana);

    // 마나 콜백 - 일정 간격으로만 호출
    _lastManaCallback += dt;
    if (_lastManaCallback >= _manaCallbackInterval && (mana - prevMana).abs() > 0.01) {
      onManaChanged?.call(mana);
      _lastManaCallback = 0;
    }

    super.update(scaledDt);
  }
}
