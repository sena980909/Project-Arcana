/// Arcana: The Three Hearts - 적 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'player.dart';
import 'systems/map_loader.dart';
import 'components/effects/telegraph_component.dart';
import 'components/effects/screen_effects.dart';
import '../utils/game_logger.dart';
import '../data/models/monster_data.dart';
import '../data/repositories/config_repository.dart';

/// 적 사망 콜백
typedef EnemyDeathCallback = void Function(Enemy enemy);

/// 적 공격 적중 콜백
typedef AttackHitCallback = void Function(double damage);

/// 적 컴포넌트
class Enemy extends PositionComponent {
  Enemy({
    required Vector2 position,
    required this.assetPath,
    required this.enemyType,
    required this.player,
    this.onDeath,
    this.onAttackHit,
    this.monsterData,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        );

  final String assetPath;
  final String enemyType;
  final Player player;
  final EnemyDeathCallback? onDeath;
  final AttackHitCallback? onAttackHit;
  final MonsterData? monsterData;

  // 스탯
  late double hp;
  late double maxHp;
  late double speed;
  late double attackDamage;
  late double detectionRange;
  late double attackRange;
  late List<AttackPattern> attackPatterns;

  // 상태
  bool isDead = false;

  // AI 상태
  Vector2 _moveDirection = Vector2.zero();
  double _actionTimer = 0;
  bool _isChasing = false;

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

  // 사망 파티클
  final List<_DeathParticle> _deathParticles = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupStats();
    await _loadAnimations();

    _animationComponent = SpriteAnimationComponent(
      animation: _idleAnimation,
      size: Vector2(32, 32),
      anchor: Anchor.center,
    );
    add(_animationComponent!);
  }

  void _setupStats() {
    // ConfigRepository에서 데이터 가져오기 시도
    final data = monsterData ?? ConfigRepository.instance.getMonster(enemyType);

    if (data != null) {
      maxHp = data.hp;
      speed = data.speed;
      attackDamage = data.damage;
      detectionRange = data.detectionRange;
      attackRange = data.attackRange;
      attackPatterns = data.attackPatterns;
    } else {
      // 기본값 (호환성 유지)
      switch (enemyType) {
        case 'goblin':
          maxHp = 30;
          speed = 50;
          attackDamage = 5;
          detectionRange = 120;
          attackRange = 25;
        case 'skelet':
          maxHp = 40;
          speed = 40;
          attackDamage = 8;
          detectionRange = 150;
          attackRange = 30;
        case 'orc_warrior':
          maxHp = 60;
          speed = 35;
          attackDamage = 12;
          detectionRange = 100;
          attackRange = 35;
        case 'imp':
          maxHp = 25;
          speed = 70;
          attackDamage = 4;
          detectionRange = 180;
          attackRange = 20;
        default:
          maxHp = 30;
          speed = 45;
          attackDamage = 5;
          detectionRange = 120;
          attackRange = 25;
      }

      // 기본 공격 패턴 생성
      attackPatterns = [
        AttackPattern(
          name: 'basic_attack',
          damage: attackDamage,
          range: attackRange,
          telegraphDuration: 0.5,
          attackDuration: 0.2,
          cooldown: 2.0,
          shape: 'arc',
          angle: 90,
        ),
      ];
    }
    hp = maxHp;
  }

  Future<void> _loadAnimations() async {
    _idleAnimation = await _loadAnimation('${enemyType}_idle_anim', 4, 0.15);
    _runAnimation = await _loadAnimation('${enemyType}_run_anim', 4, 0.1);
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
              '${assetPath}${enemyType}_idle_anim_f${i % 4}.png');
          sprites.add(fallback);
        } catch (e2) {
          try {
            final fallback =
                await Sprite.load('${assetPath}goblin_idle_anim_f${i % 4}.png');
            sprites.add(fallback);
          } catch (e3) {
            // 무시
          }
        }
      }
    }
    if (sprites.isEmpty) {
      sprites.add(await Sprite.load('${assetPath}goblin_idle_anim_f0.png'));
    }
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) {
      _deathTimer += dt;

      // 파티클 업데이트
      for (final p in _deathParticles) {
        p.update(dt);
      }

      if (_animationComponent != null) {
        if (_deathTimer < 0.3) {
          // 페이즈 1 (0~0.3초): 빨간→흰 깜빡임 (3회)
          final blinkPhase = (_deathTimer * 10).floor() % 2;
          if (blinkPhase == 0) {
            _animationComponent!.paint.color = Colors.red;
          } else {
            _animationComponent!.paint.color = Colors.white;
          }
        } else {
          // 페이즈 2 (0.3~0.8초): 반투명 + 납작해짐
          final fadeProgress = ((_deathTimer - 0.3) / 0.5).clamp(0.0, 1.0);
          final alpha = ((1.0 - fadeProgress) * 255).toInt().clamp(0, 255);
          _animationComponent!.paint.color = Colors.white.withAlpha(alpha);

          // 납작해짐 (scaleY 축소)
          final scaleY = 1.0 - fadeProgress * 0.7;
          final scaleX = 1.0 + fadeProgress * 0.2; // 약간 옆으로 퍼짐
          _animationComponent!.scale = Vector2(
            (_facingRight ? scaleX : -scaleX),
            scaleY,
          );
          // 아래로 내려감 (납작해지니 바닥 고정)
          _animationComponent!.position.y += dt * 8;
        }
      }
      if (_deathTimer >= 0.8) {
        removeFromParent();
      }
      return;
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
  }

  void _updateAI(double dt) {
    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    if (distance < detectionRange) {
      _isChasing = true;

      // 공격 범위 내에서 쿨다운이 끝났으면 공격
      if (distance <= attackRange && _attackCooldownTimer <= 0 && !_isAttacking) {
        _startAttack();
      } else if (distance > attackRange * 0.6) {
        // 추적: 매 프레임 플레이어 방향으로 부드럽게 추적
        final targetDir = toPlayer.normalized();
        // 기존 방향과 보간하여 부드러운 이동 (급격한 방향전환 방지)
        if (_moveDirection.length > 0) {
          _moveDirection = (_moveDirection * 0.7 + targetDir * 0.3).normalized();
        } else {
          _moveDirection = targetDir;
        }
        if (toPlayer.x.abs() > 2) {
          _facingRight = toPlayer.x > 0;
        }
      } else {
        // 공격 대기: 완전 정지 대신 약간 선회
        _moveDirection = Vector2.zero();
      }
    } else {
      _isChasing = false;

      // 배회 AI (타이머 기반)
      _actionTimer -= dt;
      if (_actionTimer <= 0) {
        if (Random().nextDouble() < 0.3) {
          final angle = Random().nextDouble() * 2 * pi;
          _moveDirection = Vector2(cos(angle), sin(angle));
          _facingRight = _moveDirection.x > 0;
        } else {
          _moveDirection = Vector2.zero();
        }
        _actionTimer = 1.0 + Random().nextDouble() * 1.5;
      }
    }
  }

  /// 공격 시작
  void _startAttack() {
    if (_isAttacking || attackPatterns.isEmpty) return;

    _isAttacking = true;
    _moveDirection = Vector2.zero();

    // 공격 패턴 선택
    final pattern = attackPatterns[_currentAttackIndex % attackPatterns.length];
    _currentAttackIndex++;

    // 플레이어 방향 계산
    final toPlayer = player.position - position;
    final direction = atan2(toPlayer.y, toPlayer.x);

    // 텔레그래프 생성
    _createTelegraph(pattern, direction);
  }

  /// 텔레그래프 생성
  void _createTelegraph(AttackPattern pattern, double direction) {
    TelegraphComponent telegraph;

    switch (pattern.shape) {
      case 'circle':
        telegraph = TelegraphFactory.circle(
          radius: pattern.range,
          duration: pattern.telegraphDuration,
          onComplete: () => _executeAttack(pattern, direction),
        );
      case 'rectangle':
        telegraph = TelegraphFactory.rectangle(
          width: pattern.width > 0 ? pattern.width : pattern.range,
          height: pattern.height > 0 ? pattern.height : 30,
          duration: pattern.telegraphDuration,
          direction: direction,
          onComplete: () => _executeAttack(pattern, direction),
        );
      case 'arc':
      default:
        telegraph = TelegraphFactory.arc(
          radius: pattern.range,
          angle: pattern.angle > 0 ? pattern.angle : 90,
          duration: pattern.telegraphDuration,
          direction: direction,
          onComplete: () => _executeAttack(pattern, direction),
        );
    }

    telegraph.position = position.clone();
    parent?.add(telegraph);
    _currentTelegraph = telegraph;
  }

  /// 공격 실행
  void _executeAttack(AttackPattern pattern, double direction) {
    _currentTelegraph = null;

    // 죽은 상태면 공격 안 함
    if (isDead) {
      _isAttacking = false;
      return;
    }

    // 플레이어와의 거리/방향 체크
    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    bool hitPlayer = false;

    switch (pattern.shape) {
      case 'circle':
        // 원형: 범위 내 체크
        hitPlayer = distance <= pattern.range;
      case 'rectangle':
        // 사각형: 방향과 범위 체크
        final playerDir = atan2(toPlayer.y, toPlayer.x);
        final angleDiff = (playerDir - direction).abs();
        final normalizedAngle = angleDiff > pi ? 2 * pi - angleDiff : angleDiff;
        final width = pattern.width > 0 ? pattern.width : pattern.range;
        final height = pattern.height > 0 ? pattern.height : 30;

        // 간단한 사각형 충돌 체크
        final along = toPlayer.x * cos(direction) + toPlayer.y * sin(direction);
        final perp = (-toPlayer.x * sin(direction) + toPlayer.y * cos(direction)).abs();

        hitPlayer = along > 0 && along < width && perp < height / 2;
      case 'arc':
      default:
        // 호: 범위와 각도 체크
        if (distance <= pattern.range) {
          final playerDir = atan2(toPlayer.y, toPlayer.x);
          final angleDiff = (playerDir - direction).abs();
          final normalizedAngle = angleDiff > pi ? 2 * pi - angleDiff : angleDiff;
          final halfAngle = (pattern.angle > 0 ? pattern.angle : 90) * pi / 360;
          hitPlayer = normalizedAngle <= halfAngle;
        }
    }

    // 피격 처리
    if (hitPlayer) {
      // 플레이어가 무적이 아닌 경우에만 데미지
      if (!player.isInvulnerable) {
        onAttackHit?.call(pattern.damage);
        GameLogger.instance.log('COMBAT', '$enemyType의 ${pattern.name} 공격 적중! 데미지: ${pattern.damage}');
      } else {
        GameLogger.instance.log('COMBAT', '$enemyType의 ${pattern.name} 공격 회피됨 (무적)');
      }
    }

    // 공격 후 쿨다운
    _attackCooldownTimer = pattern.cooldown;
    _isAttacking = false;

    // 공격 직후 바로 추적 재개
    if (_isChasing) {
      final toPlayer = player.position - position;
      if (toPlayer.length > 0) {
        _moveDirection = toPlayer.normalized();
      }
    }
  }

  void _updateMovement(double dt) {
    if (_moveDirection.length > 0) {
      final previousPosition = position.clone();
      position += _moveDirection * speed * dt;

      // 맵 경계 확인 (MapComponent가 있는 경우)
      final mapComponent = parent?.children.whereType<MapComponent>().firstOrNull;
      if (mapComponent != null) {
        if (mapComponent.isColliding(position, size)) {
          position = previousPosition; // 벽에 부딪히면 롤백
          _moveDirection = Vector2.zero(); // 이동 중지
        }
      }
    }
    _animationComponent?.scale.x = _facingRight ? 1 : -1;
  }

  void _updateAnimation() {
    if (_animationComponent == null) return;

    if (_isAttacking) {
      // 공격 중에는 idle 애니메이션 (공격 전용 없음)
      _animationComponent!.animation = _idleAnimation;
    } else {
      _animationComponent!.animation =
          _moveDirection.length > 0 ? _runAnimation : _idleAnimation;
    }
  }

  void takeDamage(double damage) {
    if (isDead) return;

    hp -= damage;
    _hitFlashTimer = 0.1;
    _animationComponent?.paint.color = Colors.red;

    // 데미지 숫자 표시
    final isCritical = damage > attackDamage * 1.5;
    final damageNumber = EffectFactory.createDamageNumber(
      position: position + Vector2(0, -20),
      damage: damage,
      isCritical: isCritical,
    );
    parent?.add(damageNumber);

    // 로그
    GameLogger.instance.logEnemyHit(enemyType, damage, hp);

    // 넉백 (벽 충돌 체크)
    final knockbackDir = (position - player.position).normalized();
    final knockbackPos = position + knockbackDir * 15;
    final mapComponent = parent?.children.whereType<MapComponent>().firstOrNull;
    if (mapComponent != null && mapComponent.isColliding(knockbackPos, size)) {
      // 벽이면 넉백 절반만 시도
      final halfKnockback = position + knockbackDir * 7;
      if (!mapComponent.isColliding(halfKnockback, size)) {
        position = halfKnockback;
      }
      // 둘 다 벽이면 넉백 안 함
    } else {
      position = knockbackPos;
    }

    if (hp <= 0) {
      _die();
    }
  }

  void _die() {
    isDead = true;

    // 진행 중인 텔레그래프 제거
    _currentTelegraph?.removeFromParent();
    _currentTelegraph = null;

    GameLogger.instance.logEnemyDeath(enemyType, position.x, position.y, remainingHp: hp);
    onDeath?.call(this);

    // 사망 즉시: 빨간 플래시
    _animationComponent?.paint.color = Colors.red;
    _deathTimer = 0;

    // 사망 파티클 생성 (3~5개)
    final rng = Random();
    final particleCount = 3 + rng.nextInt(3);
    for (int i = 0; i < particleCount; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40.0 + rng.nextDouble() * 60;
      _deathParticles.add(_DeathParticle(
        x: 0,
        y: 0,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        radius: 2.0 + rng.nextDouble() * 2,
        life: 0.5 + rng.nextDouble() * 0.3,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // HP 바
    if (hp < maxHp && !isDead) {
      final hpRatio = hp / maxHp;
      const barWidth = 30.0;
      const barHeight = 4.0;

      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -22, barWidth, barHeight),
        Paint()..color = Colors.grey.shade800,
      );

      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -22, barWidth * hpRatio, barHeight),
        Paint()..color = hpRatio > 0.3 ? Colors.green : Colors.red,
      );
    }

    // 공격 중 표시 (디버그)
    if (_isAttacking) {
      canvas.drawCircle(
        const Offset(0, -28),
        3,
        Paint()..color = Colors.orange,
      );
    }

    // 사망 파티클 렌더링
    if (isDead) {
      _renderDeathParticles(canvas);
    }
  }

  /// 사망 파티클 렌더링
  void _renderDeathParticles(Canvas canvas) {
    for (final p in _deathParticles) {
      if (p.life <= 0) continue;
      final alpha = (p.life / p.maxLife * 255).toInt().clamp(0, 255);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (p.life / p.maxLife),
        Paint()..color = Color.fromARGB(alpha, 255, 100, 60),
      );
      // 글로우
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * 2 * (p.life / p.maxLife),
        Paint()
          ..color = Color.fromARGB((alpha * 0.3).toInt(), 255, 150, 80)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }
}

/// 사망 파티클 데이터
class _DeathParticle {
  _DeathParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required double life,
  }) : life = life, maxLife = life;

  double x, y;
  double vx, vy;
  double radius;
  double life;
  final double maxLife;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vx *= 0.95; // 감속
    vy *= 0.95;
    life -= dt;
  }
}
