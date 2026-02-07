/// Arcana: The Three Hearts - 메인 게임 클래스
library;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import 'player.dart';
import 'enemy.dart';
import 'floor_component.dart';
import 'systems/map_loader.dart';
import 'systems/spawn_system.dart';
import 'systems/skill_system.dart';
import 'components/projectiles/skill_projectile.dart';
import '../utils/game_logger.dart';

/// 콜백 타입 정의
typedef HpChangedCallback = void Function(double hp, double maxHp);
typedef ValueChangedCallback<T> = void Function(T value);
typedef VoidCallback = void Function();
typedef FloorChangedCallback = void Function(int chapter, int floor);

/// 메인 게임 클래스
class ArcanaGame extends FlameGame with HasCollisionDetection {
  ArcanaGame({
    this.onPlayerHpChanged,
    this.onManaChanged,
    this.onGoldChanged,
    this.onHeartGaugeChanged,
    this.onEnemyKilled,
    this.onPerfectDodge,
    this.onFloorChanged,
    this.initialChapter = 1,
    this.initialFloor = 1,
  });

  // 콜백
  final HpChangedCallback? onPlayerHpChanged;
  final ValueChangedCallback<double>? onManaChanged;
  final ValueChangedCallback<int>? onGoldChanged;
  final ValueChangedCallback<int>? onHeartGaugeChanged;
  final VoidCallback? onEnemyKilled;
  final VoidCallback? onPerfectDodge;
  final FloorChangedCallback? onFloorChanged;

  // 초기 챕터/층
  final int initialChapter;
  final int initialFloor;

  // 게임 컴포넌트
  late Player player;
  SpawnSystem? _spawnSystem;
  MapComponent? _mapComponent;
  LoadedMap? _currentMap;
  SkillSystem? _skillSystem;

  // 장착된 스킬 (Q, E, R 슬롯)
  final List<String> equippedSkills = ['fireball', 'frost_nova', 'shadow_dash'];

  // 현재 챕터/층
  int currentChapter = 1;
  int currentFloor = 1;

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

  /// 적 목록 (SpawnSystem에서 가져오기)
  List<Enemy> get enemies => _spawnSystem?.enemies.toList() ?? [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    currentChapter = initialChapter;
    currentFloor = initialFloor;

    // 맵 로드 시도
    _currentMap = MapLoader.loadMapByChapterFloor(currentChapter, currentFloor);

    if (_currentMap != null) {
      // 맵이 있으면 맵 컴포넌트 추가
      _mapComponent = MapComponent(loadedMap: _currentMap!);
      world.add(_mapComponent!);

      // 플레이어 생성 (맵의 스폰 위치)
      player = Player(
        position: _currentMap!.playerSpawn.clone(),
        assetPath: _assetPath,
        onHpChanged: (hp, maxHp) {
          onPlayerHpChanged?.call(hp, maxHp);
        },
        onPerfectDodge: () {
          _triggerPerfectDodge();
        },
      );
      world.add(player);

      // 스폰 시스템으로 적 생성
      _spawnSystem = SpawnSystem(
        world: world,
        player: player,
        assetPath: _assetPath,
        onEnemyDeath: (e) => _onEnemyDeath(e),
        onEnemyAttackHit: (damage) => _onPlayerHitByEnemy(damage),
      );
      _spawnSystem!.spawnFromMap(_currentMap!, chapter: currentChapter);
    } else {
      // 맵이 없으면 기본 바닥 생성 (호환성)
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

      // 기본 적 스폰
      _spawnDefaultEnemies();
    }

    // 카메라 설정
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 2.5; // 2.5배 확대
    camera.follow(player);

    // 스킬 시스템 초기화
    _skillSystem = SkillSystem(
      player: player,
      world: world,
      getEnemies: () => enemies,
      onManaUsed: (amount) {
        mana = (mana - amount).clamp(0, maxMana);
        onManaChanged?.call(mana);
      },
      onCooldownStarted: (skillId, cooldown) {
        GameLogger.instance.log('SKILL', '$skillId 쿨다운 시작: ${cooldown}초');
      },
    );

    // 초기값 전달
    onGoldChanged?.call(gold);
    onManaChanged?.call(mana);
    onHeartGaugeChanged?.call(heartGauge);

    GameLogger.instance.log('GAME', '맵 로드: Ch$currentChapter F$currentFloor');
  }

  /// 기본 적 스폰 (맵 없을 때)
  void _spawnDefaultEnemies() {
    _spawnSystem = SpawnSystem(
      world: world,
      player: player,
      assetPath: _assetPath,
      onEnemyDeath: (e) => _onEnemyDeath(e),
      onEnemyAttackHit: (damage) => _onPlayerHitByEnemy(damage),
    );

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
      _spawnSystem!.spawnEnemyAt(pos, type);
      GameLogger.instance.logEnemySpawn(type, pos.x, pos.y);
    }
  }

  /// 다음 층으로 이동
  void goToNextFloor() {
    currentFloor++;

    // 맵 로드 시도
    final nextMap = MapLoader.loadMapByChapterFloor(currentChapter, currentFloor);

    if (nextMap == null) {
      // 다음 층 맵이 없으면 다음 챕터로
      currentChapter++;
      currentFloor = 1;

      final chapterMap = MapLoader.loadMapByChapterFloor(currentChapter, currentFloor);
      if (chapterMap == null) {
        // 더 이상 챕터가 없으면 승리
        GameLogger.instance.log('GAME', '게임 클리어!');
        return;
      }
    }

    _loadCurrentFloor();
    onFloorChanged?.call(currentChapter, currentFloor);
  }

  /// 현재 층 로드
  void _loadCurrentFloor() {
    // 기존 맵 제거
    _mapComponent?.removeFromParent();
    _spawnSystem?.clearEnemies();

    // 새 맵 로드
    _currentMap = MapLoader.loadMapByChapterFloor(currentChapter, currentFloor);

    if (_currentMap != null) {
      _mapComponent = MapComponent(loadedMap: _currentMap!);
      world.add(_mapComponent!);

      // 플레이어 위치 이동
      player.position = _currentMap!.playerSpawn.clone();

      // 적 스폰
      _spawnSystem?.spawnFromMap(_currentMap!, chapter: currentChapter);
    }

    GameLogger.instance.log('GAME', '층 이동: Ch$currentChapter F$currentFloor');
  }

  /// 적 사망
  void _onEnemyDeath(Enemy enemy) {
    // SpawnSystem이 적 목록 관리

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

    // 모든 적 처치 시 출구 활성화 체크
    if (_spawnSystem != null && _spawnSystem!.aliveEnemyCount == 0) {
      GameLogger.instance.log('GAME', '모든 적 처치! 출구 활성화');
    }
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
        // 스킬 (Q/E)
        if (key == LogicalKeyboardKey.keyQ) {
          _useSkill(0);
        }
        if (key == LogicalKeyboardKey.keyE) {
          _useSkill(1);
        }
        // 세 번째 스킬 (X)
        if (key == LogicalKeyboardKey.keyX) {
          _useSkill(2);
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
    if (_skillSystem == null) return;
    if (slotIndex < 0 || slotIndex >= equippedSkills.length) return;

    final skillId = equippedSkills[slotIndex];
    final result = _skillSystem!.useSkill(skillId, mana);

    if (result.success) {
      GameLogger.instance.log('SKILL', '${result.message}');
    } else {
      GameLogger.instance.log('SKILL', '스킬 사용 실패: ${result.message}');
    }
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

  // 플레이어 이전 위치 (충돌 시 롤백용)
  Vector2 _playerPreviousPosition = Vector2.zero();

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

    // 플레이어 위치 저장 (충돌 롤백용)
    _playerPreviousPosition = player.position.clone();

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

    // 스킬 시스템 업데이트
    _skillSystem?.update(scaledDt);

    // 투사체 충돌 체크
    _checkProjectileCollisions();

    // 벽 충돌 체크 (맵이 있을 때만)
    if (_mapComponent != null && _mapComponent!.isColliding(player.position, player.size)) {
      player.position = _playerPreviousPosition;
    }

    // 출구 체크 (모든 적 처치 후)
    if (_currentMap != null && _spawnSystem != null && _spawnSystem!.aliveEnemyCount == 0) {
      final exitDistance = (player.position - _currentMap!.exitPoint).length;
      if (exitDistance < 30) {
        goToNextFloor();
      }
    }

    // 데미지 타일 체크
    if (_mapComponent != null) {
      final tileDamage = _mapComponent!.getDamageAt(player.position);
      if (tileDamage > 0) {
        player.takeDamage(tileDamage * scaledDt);
      }
    }
  }

  /// 투사체 충돌 체크
  void _checkProjectileCollisions() {
    // 월드에서 모든 투사체 컴포넌트 찾기
    final projectiles = world.children.whereType<SkillProjectile>().toList();

    for (final projectile in projectiles) {
      for (final enemy in enemies) {
        if (projectile.checkCollision(enemy)) {
          // 마나 회복 (적중 시 +5)
          mana = (mana + 5).clamp(0, maxMana);
          onManaChanged?.call(mana);
        }
      }
    }
  }
}
