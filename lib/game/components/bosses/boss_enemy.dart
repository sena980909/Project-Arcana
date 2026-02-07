/// Arcana: The Three Hearts - 보스 적 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../player.dart';
import '../../enemy.dart';
import '../effects/telegraph_component.dart';
import '../../../utils/game_logger.dart';
import '../../../data/models/monster_data.dart';
import '../../../data/repositories/config_repository.dart';
import '../../systems/audio_system.dart';

/// 보스 페이즈 정보
class BossPhase {
  const BossPhase({
    required this.name,
    required this.hpThreshold,
    this.speedMultiplier = 1.0,
    this.damageMultiplier = 1.0,
    this.patterns = const [],
  });

  final String name;
  final double hpThreshold; // HP% 임계값
  final double speedMultiplier;
  final double damageMultiplier;
  final List<String> patterns;
}

/// 보스 대사 콜백
typedef BossDialogueCallback = void Function(String dialogue, String type);

/// 보스 사망 콜백
typedef BossDeathCallback = void Function(BossEnemy boss);

/// 보스 적 컴포넌트
/// 일반 적과 달리 페이즈 전환, 특수 공격 패턴, 대사 시스템을 지원합니다.
class BossEnemy extends PositionComponent {
  BossEnemy({
    required Vector2 position,
    required this.assetPath,
    required this.bossId,
    required this.player,
    this.onDeath,
    this.onDialogue,
    this.onPhaseChange,
    this.onAttackHit,
  }) : super(
          position: position,
          size: Vector2(64, 64), // 보스는 더 큰 사이즈
          anchor: Anchor.center,
        );

  final String assetPath;
  final String bossId;
  final Player player;
  final BossDeathCallback? onDeath;
  final BossDialogueCallback? onDialogue;
  final void Function(int phase)? onPhaseChange;
  final void Function(double damage)? onAttackHit;

  // 스탯
  late double hp;
  late double maxHp;
  late double baseSpeed;
  late double baseAttackDamage;
  late double detectionRange;
  late double attackRange;
  late List<AttackPattern> allAttackPatterns;
  late List<BossPhase> phases;
  late Map<String, String> dialogues;

  // 현재 페이즈
  int currentPhase = 0;
  List<AttackPattern> currentPatterns = [];

  // 상태
  bool isDead = false;
  bool _introPlayed = false;

  // AI 상태
  Vector2 _moveDirection = Vector2.zero();
  double _actionTimer = 0;

  // 공격 상태
  bool _isAttacking = false;
  double _attackCooldownTimer = 0;
  int _currentAttackIndex = 0;
  TelegraphComponent? _currentTelegraph;

  // 애니메이션
  SpriteAnimation? _idleAnimation;
  SpriteAnimation? _runAnimation;
  SpriteAnimationComponent? _animationComponent;
  bool _facingRight = true;

  // 이펙트 타이머
  double _hitFlashTimer = 0;
  double _deathTimer = 0;
  double _phaseTransitionTimer = 0;

  // 현재 스탯 (페이즈별 배율 적용)
  double get currentSpeed => baseSpeed * (phases.isNotEmpty && currentPhase < phases.length
      ? phases[currentPhase].speedMultiplier : 1.0);
  double get currentDamage => baseAttackDamage * (phases.isNotEmpty && currentPhase < phases.length
      ? phases[currentPhase].damageMultiplier : 1.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupStats();
    await _loadAnimations();

    _animationComponent = SpriteAnimationComponent(
      animation: _idleAnimation,
      size: Vector2(64, 64),
      anchor: Anchor.center,
    );
    add(_animationComponent!);
  }

  void _setupStats() {
    final data = ConfigRepository.instance.getMonster(bossId);

    if (data != null) {
      maxHp = data.hp;
      baseSpeed = data.speed;
      baseAttackDamage = data.damage;
      detectionRange = data.detectionRange;
      attackRange = data.attackRange;
      allAttackPatterns = data.attackPatterns;

      // 페이즈 설정 (기본값)
      phases = [
        BossPhase(
          name: '페이즈 1',
          hpThreshold: 100,
          speedMultiplier: 1.0,
          damageMultiplier: 1.0,
          patterns: allAttackPatterns.take(2).map((p) => p.name).toList(),
        ),
        BossPhase(
          name: '페이즈 2',
          hpThreshold: 50,
          speedMultiplier: 1.3,
          damageMultiplier: 1.2,
          patterns: allAttackPatterns.map((p) => p.name).toList(),
        ),
      ];

      // 대사 설정 (기본값)
      dialogues = {
        'intro': '....',
        'phase2': '...!',
        'death': '......',
      };
    } else {
      // 기본값
      maxHp = 500;
      baseSpeed = 40;
      baseAttackDamage = 20;
      detectionRange = 300;
      attackRange = 60;
      allAttackPatterns = [
        AttackPattern(
          name: 'basic_attack',
          damage: 20,
          range: 60,
          telegraphDuration: 1.0,
          attackDuration: 0.3,
          cooldown: 2.0,
          shape: 'arc',
          angle: 120,
        ),
      ];
      phases = [
        const BossPhase(name: '페이즈 1', hpThreshold: 100),
        const BossPhase(name: '페이즈 2', hpThreshold: 50, speedMultiplier: 1.3),
      ];
      dialogues = {};
    }

    hp = maxHp;
    _updateCurrentPatterns();
  }

  void _updateCurrentPatterns() {
    if (phases.isEmpty || currentPhase >= phases.length) {
      currentPatterns = allAttackPatterns;
      return;
    }

    final phasePatterns = phases[currentPhase].patterns;
    if (phasePatterns.isEmpty) {
      currentPatterns = allAttackPatterns;
    } else {
      currentPatterns = allAttackPatterns
          .where((p) => phasePatterns.contains(p.name))
          .toList();
      if (currentPatterns.isEmpty) {
        currentPatterns = allAttackPatterns;
      }
    }
  }

  Future<void> _loadAnimations() async {
    // big_demon 스프라이트 사용
    _idleAnimation = await _loadAnimation('big_demon_idle_anim', 4, 0.2);
    _runAnimation = await _loadAnimation('big_demon_run_anim', 4, 0.15);
  }

  Future<SpriteAnimation> _loadAnimation(
    String baseName,
    int frameCount,
    double stepTime,
  ) async {
    final sprites = <Sprite>[];
    for (int i = 0; i < frameCount; i++) {
      try {
        final sprite = await Sprite.load('${assetPath}${baseName}_f$i.png');
        sprites.add(sprite);
      } catch (e) {
        try {
          final fallback = await Sprite.load(
              '${assetPath}big_demon_idle_anim_f${i % 4}.png');
          sprites.add(fallback);
        } catch (e2) {
          // 무시
        }
      }
    }
    if (sprites.isEmpty) {
      sprites.add(await Sprite.load('${assetPath}big_demon_idle_anim_f0.png'));
    }
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) {
      _deathTimer += dt;
      if (_deathTimer >= 1.0) {
        removeFromParent();
      }
      return;
    }

    // 페이즈 전환 중
    if (_phaseTransitionTimer > 0) {
      _phaseTransitionTimer -= dt;
      return;
    }

    // 인트로 대사
    if (!_introPlayed) {
      _introPlayed = true;
      _playDialogue('intro');
    }

    // 피격 플래시
    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;
      if (_hitFlashTimer <= 0) {
        _animationComponent?.paint.color = Colors.white;
      }
    }

    // 공격 쿨다운
    if (_attackCooldownTimer > 0) {
      _attackCooldownTimer -= dt;
    }

    _updateAI(dt);

    // 공격 중이 아닐 때만 이동
    if (!_isAttacking) {
      _updateMovement(dt);
    }

    _updateAnimation();
    _checkPhaseTransition();
  }

  void _updateAI(double dt) {
    _actionTimer -= dt;
    if (_actionTimer > 0) return;

    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    if (distance < detectionRange) {
      // 공격 범위 내에서 쿨다운이 끝났으면 공격
      if (distance <= attackRange && _attackCooldownTimer <= 0 && !_isAttacking) {
        _startAttack();
      } else if (distance > attackRange * 0.7) {
        // 공격 범위 밖이면 추적
        _moveDirection = toPlayer.normalized();
        _facingRight = _moveDirection.x > 0;
      } else {
        _moveDirection = Vector2.zero();
      }
    } else {
      _moveDirection = Vector2.zero();
    }

    _actionTimer = 0.1;
  }

  void _startAttack() {
    if (_isAttacking || currentPatterns.isEmpty) return;

    _isAttacking = true;
    _moveDirection = Vector2.zero();

    // 공격 패턴 선택 (랜덤)
    final pattern = currentPatterns[Random().nextInt(currentPatterns.length)];
    _currentAttackIndex++;

    // 플레이어 방향 계산
    final toPlayer = player.position - position;
    final direction = atan2(toPlayer.y, toPlayer.x);

    _createTelegraph(pattern, direction);
  }

  void _createTelegraph(AttackPattern pattern, double direction) {
    TelegraphComponent telegraph;

    // 페이즈에 따른 색상 변경
    final color = currentPhase == 0 ? Colors.blue : Colors.red;

    switch (pattern.shape) {
      case 'circle':
        telegraph = TelegraphFactory.circle(
          radius: pattern.range,
          duration: pattern.telegraphDuration,
          color: color,
          onComplete: () => _executeAttack(pattern, direction),
        );
      case 'rectangle':
        telegraph = TelegraphFactory.rectangle(
          width: pattern.width > 0 ? pattern.width : pattern.range,
          height: pattern.height > 0 ? pattern.height : 40,
          duration: pattern.telegraphDuration,
          direction: direction,
          color: color,
          onComplete: () => _executeAttack(pattern, direction),
        );
      case 'arc':
      default:
        telegraph = TelegraphFactory.arc(
          radius: pattern.range,
          angle: pattern.angle > 0 ? pattern.angle : 120,
          duration: pattern.telegraphDuration,
          direction: direction,
          color: color,
          onComplete: () => _executeAttack(pattern, direction),
        );
    }

    telegraph.position = position.clone();
    parent?.add(telegraph);
    _currentTelegraph = telegraph;
  }

  void _executeAttack(AttackPattern pattern, double direction) {
    _currentTelegraph = null;

    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    bool hitPlayer = false;

    switch (pattern.shape) {
      case 'circle':
        hitPlayer = distance <= pattern.range;
      case 'rectangle':
        final width = pattern.width > 0 ? pattern.width : pattern.range;
        final height = pattern.height > 0 ? pattern.height : 40;
        final along = toPlayer.x * cos(direction) + toPlayer.y * sin(direction);
        final perp = (-toPlayer.x * sin(direction) + toPlayer.y * cos(direction)).abs();
        hitPlayer = along > 0 && along < width && perp < height / 2;
      case 'arc':
      default:
        if (distance <= pattern.range) {
          final playerDir = atan2(toPlayer.y, toPlayer.x);
          final angleDiff = (playerDir - direction).abs();
          final normalizedAngle = angleDiff > pi ? 2 * pi - angleDiff : angleDiff;
          final halfAngle = (pattern.angle > 0 ? pattern.angle : 120) * pi / 360;
          hitPlayer = normalizedAngle <= halfAngle;
        }
    }

    if (hitPlayer && !player.isInvulnerable) {
      final damage = pattern.damage * (phases.isNotEmpty && currentPhase < phases.length
          ? phases[currentPhase].damageMultiplier : 1.0);
      onAttackHit?.call(damage);
      GameLogger.instance.log('BOSS', '${pattern.name} 공격 적중! 데미지: $damage');
    }

    _attackCooldownTimer = pattern.cooldown;
    _isAttacking = false;
  }

  void _updateMovement(double dt) {
    if (_moveDirection.length > 0) {
      position += _moveDirection * currentSpeed * dt;
    }
    _animationComponent?.scale.x = _facingRight ? 1 : -1;
  }

  void _updateAnimation() {
    if (_animationComponent == null) return;

    if (_isAttacking || _phaseTransitionTimer > 0) {
      _animationComponent!.animation = _idleAnimation;
    } else {
      _animationComponent!.animation =
          _moveDirection.length > 0 ? _runAnimation : _idleAnimation;
    }
  }

  void _checkPhaseTransition() {
    if (phases.isEmpty) return;

    final hpPercent = (hp / maxHp) * 100;

    for (int i = phases.length - 1; i >= 0; i--) {
      if (hpPercent <= phases[i].hpThreshold && currentPhase < i) {
        _transitionToPhase(i);
        break;
      }
    }
  }

  void _transitionToPhase(int newPhase) {
    if (newPhase == currentPhase) return;

    currentPhase = newPhase;
    _updateCurrentPatterns();
    _phaseTransitionTimer = 1.0; // 1초 무적

    // 페이즈 전환 대사
    if (newPhase == 1) {
      _playDialogue('phase2');
    }

    onPhaseChange?.call(currentPhase);
    GameLogger.instance.log('BOSS', '페이즈 전환: ${phases[currentPhase].name}');

    // 페이즈 전환 이펙트
    _animationComponent?.paint.color = Colors.purple;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isDead) {
        _animationComponent?.paint.color = Colors.white;
      }
    });
  }

  void _playDialogue(String type) {
    final dialogue = dialogues[type];
    if (dialogue != null && dialogue.isNotEmpty) {
      onDialogue?.call(dialogue, type);
    }
  }

  void takeDamage(double damage) {
    if (isDead || _phaseTransitionTimer > 0) return;

    hp -= damage;
    _hitFlashTimer = 0.15;
    _animationComponent?.paint.color = Colors.red;

    GameLogger.instance.log('BOSS', '$bossId 피격: 데미지 $damage, 남은 HP: $hp');

    // 넉백 (보스는 약하게)
    final knockbackDir = (position - player.position).normalized();
    position += knockbackDir * 5;

    if (hp <= 0) {
      _die();
    }
  }

  void _die() {
    isDead = true;

    _currentTelegraph?.removeFromParent();
    _currentTelegraph = null;

    _playDialogue('death');
    GameLogger.instance.log('BOSS', '$bossId 처치!');

    onDeath?.call(this);
    _animationComponent?.paint.color = Colors.grey;
    _deathTimer = 0;

    // 보스 BGM 정지
    AudioSystem.instance.playVictoryBgm();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // HP 바 (보스는 위에 더 크게)
    if (!isDead) {
      final hpRatio = hp / maxHp;
      const barWidth = 60.0;
      const barHeight = 6.0;

      // 배경
      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -40, barWidth, barHeight),
        Paint()..color = Colors.grey.shade800,
      );

      // HP
      final hpColor = currentPhase == 0 ? Colors.green : Colors.orange;
      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -40, barWidth * hpRatio, barHeight),
        Paint()..color = hpRatio > 0.3 ? hpColor : Colors.red,
      );

      // 테두리
      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -40, barWidth, barHeight),
        Paint()
          ..color = Colors.white.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // 페이즈 표시
      if (phases.isNotEmpty && currentPhase < phases.length) {
        final phaseIndicator = Paint()
          ..color = currentPhase == 0 ? Colors.blue : Colors.red
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(barWidth / 2 + 8, -37), 4, phaseIndicator);
      }

      // 페이즈 전환 중 표시
      if (_phaseTransitionTimer > 0) {
        final shieldPaint = Paint()
          ..color = Colors.purple.withAlpha(100)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, 40, shieldPaint);
      }
    }
  }
}
