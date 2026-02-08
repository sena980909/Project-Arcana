/// Arcana: The Three Hearts - 메인 게임 클래스
library;

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'player.dart';
import 'enemy.dart';
import 'floor_component.dart';
import 'systems/map_loader.dart';
import 'systems/spawn_system.dart';
import 'systems/skill_system.dart';
import 'components/projectiles/skill_projectile.dart';
import 'components/effects/screen_effects.dart';
import 'components/effects/telegraph_component.dart';
import 'components/npc_component.dart';
import 'systems/audio_system.dart';
import '../utils/game_logger.dart';

/// 콜백 타입 정의
typedef HpChangedCallback = void Function(double hp, double maxHp);
typedef ValueChangedCallback<T> = void Function(T value);
typedef GameVoidCallback = void Function();
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
    this.onShopRequested,
    this.initialChapter = 1,
    this.initialFloor = 1,
  });

  // 콜백
  final HpChangedCallback? onPlayerHpChanged;
  final ValueChangedCallback<double>? onManaChanged;
  final ValueChangedCallback<int>? onGoldChanged;
  final ValueChangedCallback<int>? onHeartGaugeChanged;
  final GameVoidCallback? onEnemyKilled;
  final GameVoidCallback? onPerfectDodge;
  final FloorChangedCallback? onFloorChanged;
  final GameVoidCallback? onShopRequested;

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

  // 스테이지 클리어 상태
  bool _isStageCleared = false;
  double _stageClearTimer = 0;
  static const double _stageClearDelay = 2.0;
  StageClearComponent? _stageClearNotification;

  // 게임 오버 상태
  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;
  GameOverComponent? _gameOverComponent;

  // 적 스폰 여부 추적 (폴백 스테이지 클리어 검출용)
  bool _hasSpawnedEnemies = false;

  // 모바일 입력
  Vector2 mobileDirection = Vector2.zero();

  // 에셋 경로
  static const String _assetPath =
      'itchio/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/';

  /// 적 목록 (SpawnSystem에서 가져오기)
  List<Enemy> get enemies => _spawnSystem?.enemies.toList() ?? [];

  /// 현재 상호작용 가능한 NPC
  NpcComponent? get nearbyNpc {
    final npcs = _spawnSystem?.npcs ?? [];
    for (final npc in npcs) {
      if (npc.isPlayerNearby) return npc;
    }
    return null;
  }

  /// 화면 플래시 색상
  Color? get flashColor => ScreenEffects.instance.flashColor;

  /// 화면 플래시 알파
  double get flashAlpha => ScreenEffects.instance.flashAlpha;

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
      _hasSpawnedEnemies = _spawnSystem!.enemies.isNotEmpty;
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
      _hasSpawnedEnemies = true;
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

  // 게임 클리어 상태
  bool _isGameCleared = false;

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
        _isGameCleared = true;
        _showVictoryScreen();
        GameLogger.instance.log('GAME', '게임 클리어!');
        return;
      }
    }

    _loadCurrentFloor();
    onFloorChanged?.call(currentChapter, currentFloor);
  }

  /// 승리 화면 표시
  void _showVictoryScreen() {
    final victory = _VictoryComponent(followTarget: player);
    world.add(victory);
    ScreenEffects.instance.flash(color: Colors.yellow.withAlpha(120), duration: 1.0);
    AudioSystem.instance.playVictoryBgm();
  }

  /// 현재 층 로드
  void _loadCurrentFloor() {
    // 스테이지 클리어 상태 리셋
    _isStageCleared = false;
    _hasSpawnedEnemies = false;
    _stageClearNotification?.removeFromParent();
    _stageClearNotification = null;

    // 기존 맵 제거
    _mapComponent?.removeFromParent();
    _spawnSystem?.clearEnemies();

    // 투사체, 이펙트 등 잔여 컴포넌트 제거
    _cleanupWorldComponents();

    // 새 맵 로드
    _currentMap = MapLoader.loadMapByChapterFloor(currentChapter, currentFloor);

    if (_currentMap != null) {
      _mapComponent = MapComponent(loadedMap: _currentMap!);
      world.add(_mapComponent!);

      // 플레이어 위치 이동
      player.position = _currentMap!.playerSpawn.clone();

      // 적 스폰
      _spawnSystem!.spawnFromMap(_currentMap!, chapter: currentChapter);
      _hasSpawnedEnemies = _spawnSystem!.enemies.isNotEmpty;
    }

    GameLogger.instance.log('GAME', '층 이동: Ch$currentChapter F$currentFloor');
  }

  /// 월드에서 투사체, 이펙트 등 잔여 컴포넌트 제거
  void _cleanupWorldComponents() {
    final toRemove = <Component>[];
    for (final child in world.children) {
      if (child is SkillProjectile ||
          child is AreaEffectComponent ||
          child is BuffEffectComponent ||
          child is DamageNumberComponent ||
          child is StageClearComponent ||
          child is GameOverComponent ||
          child is TelegraphComponent) {
        toRemove.add(child);
      }
    }
    for (final c in toRemove) {
      c.removeFromParent();
    }
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

    // 모든 적 처치 시 자동 스테이지 클리어
    if (_spawnSystem != null && _spawnSystem!.aliveEnemyCount == 0 && !_isStageCleared) {
      _isStageCleared = true;
      _stageClearTimer = _stageClearDelay;

      // 스테이지 클리어 알림
      _stageClearNotification = StageClearComponent(followTarget: player);
      world.add(_stageClearNotification!);

      // 스테이지 클리어 보상: HP 15% 회복
      final healAmount = player.maxHp * 0.15;
      player.heal(healAmount);

      // 화면 효과
      ScreenEffects.instance.flash(color: Colors.yellow.withAlpha(80), duration: 0.3);

      GameLogger.instance.log('GAME', '모든 적 처치! HP +${healAmount.toInt()} 회복. ${_stageClearDelay}초 후 다음 스테이지');
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

  /// 게임 재시작
  void _restartGame() {
    _isGameOver = false;
    _gameOverComponent?.removeFromParent();
    _gameOverComponent = null;

    // 플레이어 상태 리셋
    player.hp = player.maxHp;
    player.isDead = false;
    player.onHpChanged?.call(player.hp, player.maxHp);

    // 마나 리셋
    mana = maxMana;
    onManaChanged?.call(mana);

    // 심장 게이지 리셋
    heartGauge = 0;
    onHeartGaugeChanged?.call(heartGauge);

    // 버프 배율 리셋
    player.buffDamageMultiplier = 1.0;
    player.buffDefenseMultiplier = 1.0;
    player.buffSpeedMultiplier = 1.0;

    // 골드 리셋
    gold = 100;
    onGoldChanged?.call(gold);

    // 챕터/층 리셋 (처음부터)
    currentChapter = 1;
    currentFloor = 1;

    // 잔여 컴포넌트 정리
    _cleanupWorldComponents();

    // 처음 층 리로드
    _loadCurrentFloor();
    onFloorChanged?.call(currentChapter, currentFloor);

    // 챕터 BGM 복원
    AudioSystem.instance.playChapterBgm(currentChapter);
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

    // 모바일 조이스틱 방향 합산
    if (mobileDirection.length > 0) {
      direction += mobileDirection;
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
        // NPC 상호작용 (F)
        if (key == LogicalKeyboardKey.keyF) {
          _checkNpcInteraction();
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

  /// 모바일 공격
  void mobileAttack() {
    if (_isGameOver || player.isDead) return;
    final hitCount = player.attack(enemies);
    if (hitCount > 0) {
      mana = (mana + 5 * hitCount).clamp(0, maxMana);
      onManaChanged?.call(mana);
    }
  }

  /// 모바일 대시
  void mobileDash() {
    if (_isGameOver || player.isDead) return;
    player.dash();
  }

  /// 모바일 스킬
  void mobileSkill(int slot) {
    if (_isGameOver || player.isDead) return;
    _useSkill(slot);
  }

  /// 모바일 궁극기
  void mobileUltimate() {
    if (_isGameOver || player.isDead) return;
    _useUltimate();
  }

  /// 모바일 재시작 (게임 오버 시)
  void mobileRestart() {
    if (_isGameOver) {
      _restartGame();
    }
  }

  /// NPC 상호작용 체크
  void _checkNpcInteraction() {
    final npc = nearbyNpc;
    if (npc == null) return;

    if (npc.npcType == 'merchant') {
      onShopRequested?.call();
    }
  }

  /// 모바일 NPC 상호작용
  void mobileInteract() {
    if (_isGameOver || player.isDead) return;
    _checkNpcInteraction();
  }

  // 마나 콜백 최적화용
  double _lastManaCallback = 0;
  static const double _manaCallbackInterval = 0.1; // 0.1초마다만 콜백

  // 플레이어 이전 위치 (충돌 시 롤백용)
  Vector2 _playerPreviousPosition = Vector2.zero();

  @override
  void update(double dt) {
    // 화면 효과 업데이트 (항상)
    ScreenEffects.instance.update(dt);

    // 카메라 흔들림 적용 (항상)
    final shakeOffset = ScreenEffects.instance.shakeOffset;
    camera.viewfinder.position = player.position + shakeOffset;

    // ===== 게임 오버 처리 (최우선) =====
    if (player.hp <= 0 && !_isGameOver) {
      _isGameOver = true;
      player.isDead = true;
      _gameOverComponent = GameOverComponent(followTarget: player);
      world.add(_gameOverComponent!);
      ScreenEffects.instance.flash(color: Colors.red.withAlpha(120), duration: 0.5);
      AudioSystem.instance.playGameOverBgm();
      GameLogger.instance.log('GAME', '게임 오버!');
    }

    if (_isGameOver) {
      // 게임 오버 중에는 R키 재시작만 처리
      final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
      for (final key in keysPressed) {
        if (!_previousKeys.contains(key) && key == LogicalKeyboardKey.keyR) {
          _restartGame();
        }
      }
      _previousKeys.clear();
      _previousKeys.addAll(keysPressed);
      super.update(dt);
      return;
    }

    // ===== 스테이지 클리어 자동 전환 =====
    if (_isStageCleared) {
      _stageClearTimer -= dt;
      if (_stageClearTimer <= 0) {
        _isStageCleared = false;
        _stageClearNotification?.removeFromParent();
        _stageClearNotification = null;
        goToNextFloor();
      }
    }

    // ===== 폴백: 적이 모두 죽었는데 스테이지 클리어가 안 된 경우 =====
    if (!_isStageCleared && _spawnSystem != null) {
      final aliveCount = _spawnSystem!.aliveEnemyCount;
      final totalCount = _spawnSystem!.enemies.length;
      // 적이 스폰된 적이 있고(totalCount는 alive만이므로 0이면 다 죽은 것), 모든 적이 죽었으면
      if (aliveCount == 0 && _hasSpawnedEnemies) {
        _isStageCleared = true;
        _stageClearTimer = _stageClearDelay;

        _stageClearNotification = StageClearComponent(followTarget: player);
        world.add(_stageClearNotification!);

        ScreenEffects.instance.flash(color: Colors.yellow.withAlpha(80), duration: 0.3);
        GameLogger.instance.log('GAME', '(폴백) 모든 적 처치! ${_stageClearDelay}초 후 다음 스테이지');
      }
    }

    // ===== 슬로우 모션 처리 =====
    if (_slowMotionTimer > 0) {
      _slowMotionTimer -= dt;
      if (_slowMotionTimer <= 0) {
        _timeScale = 1.0;
      }
    }

    // 히트스톱 적용
    final effectTimeScale = ScreenEffects.instance.timeScale;
    final scaledDt = dt * _timeScale * effectTimeScale;

    // 플레이어 위치 저장 (충돌 롤백용)
    _playerPreviousPosition = player.position.clone();

    // 키보드 입력 처리
    _handleKeyboardInput();

    // 마나 자연 회복 (초당 2)
    final prevMana = mana;
    mana = (mana + 2 * scaledDt).clamp(0, maxMana);

    // 마나 콜백 - 정수 단위 변경 시만 호출
    _lastManaCallback += dt;
    if (_lastManaCallback >= _manaCallbackInterval && mana.toInt() != prevMana.toInt()) {
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

    // 데미지 타일 체크 (환경 피해: 무적 무시, 지속 피해)
    if (_mapComponent != null) {
      final tileDamage = _mapComponent!.getDamageAt(player.position);
      if (tileDamage > 0) {
        player.takeEnvironmentDamage(tileDamage * scaledDt);
      }
    }

    // 접촉 데미지 체크 (적과 플레이어 충돌)
    _checkContactDamage(scaledDt);
  }

  // 접촉 데미지 쿨다운
  double _contactDamageCooldown = 0;
  static const double _contactDamageInterval = 0.4; // 0.4초마다 접촉 데미지

  /// 적과의 접촉 데미지 체크
  void _checkContactDamage(double dt) {
    if (player.isInvulnerable) return;
    if (_contactDamageCooldown > 0) {
      _contactDamageCooldown -= dt;
      return;
    }

    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      final distance = (enemy.position - player.position).length;
      const contactRange = 18.0; // 접촉 판정 범위

      if (distance < contactRange) {
        final contactDamage = enemy.attackDamage * 0.6; // 접촉 데미지 = 공격력의 60%
        player.takeDamage(contactDamage);
        _contactDamageCooldown = _contactDamageInterval;

        // 넉백 (플레이어)
        final knockDir = (player.position - enemy.position).normalized();
        final knockPos = player.position + knockDir * 25;
        if (_mapComponent == null || !_mapComponent!.isColliding(knockPos, player.size)) {
          player.position = knockPos;
        }

        // 화면 흔들림 (접촉 피격 피드백)
        ScreenEffects.instance.shake(intensity: 1.5, duration: 0.1);

        break; // 프레임당 한 번만
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

/// 승리 화면 컴포넌트
class _VictoryComponent extends PositionComponent {
  _VictoryComponent({required this.followTarget});

  final PositionComponent followTarget;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position = followTarget.position;
  }

  @override
  void render(Canvas canvas) {
    final fadeIn = (_elapsed / 0.8).clamp(0.0, 1.0);
    final alpha = (fadeIn * 255).toInt();

    // 어두운 배경
    canvas.drawRect(
      const Rect.fromLTWH(-200, -150, 400, 300),
      Paint()..color = Color.fromARGB((alpha * 0.5).toInt(), 0, 0, 30),
    );

    // "VICTORY!" 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'VICTORY!',
        style: TextStyle(
          color: Color.fromARGB(alpha, 255, 215, 0),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          shadows: [
            Shadow(
              color: Color.fromARGB(alpha, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 - 10),
    );

    // 안내
    if (_elapsed > 2.0) {
      final subAlpha = ((_elapsed - 2.0) / 0.5).clamp(0.0, 1.0);
      final subPainter = TextPainter(
        text: TextSpan(
          text: 'Congratulations!',
          style: TextStyle(
            color: Color.fromARGB((subAlpha * 200).toInt(), 255, 255, 255),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      subPainter.layout();
      subPainter.paint(
        canvas,
        Offset(-subPainter.width / 2, 15),
      );
    }
  }
}
