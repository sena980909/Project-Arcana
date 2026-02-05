/// Arcana: The Three Hearts - 보스: 그림자 자아
/// Chapter 5 보스 - 기억의 심연
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/enemy_data.dart';
import '../../data/model/item.dart';
import '../characters/player.dart';
import '../effects/effects.dart';
import '../managers/audio_manager.dart';
import 'base_enemy.dart';

/// 그림자 자아 데이터
const shadowSelfData = EnemyData(
  type: EnemyType.boss,
  name: '그림자 자아',
  maxHealth: 900,
  attack: 30,
  defense: 10,
  speed: 60,
  detectRange: 400,
  attackRange: 80,
  attackCooldown: 2.0,
  dropTable: [
    DropEntry(item: Items.shadowFragment, dropRate: 1.0),
    DropEntry(item: Items.largeHealthPotion, dropRate: 1.0, minQuantity: 2, maxQuantity: 4),
  ],
  expReward: 500,
  goldReward: 350,
);

/// 그림자 페이즈
enum ShadowPhase {
  denial,     // Phase 1: 부정 (HP 100%~60%) - 플레이어 복사
  anger,      // Phase 2: 분노 (HP 60%~30%) - 어둠 기술
  acceptance, // Phase 3: 수용 (HP 30%~0%) - 접근 필요
}

/// 그림자 상태
enum ShadowState {
  idle,
  float,          // 부유
  mirrorDash,     // 거울 돌진 (Phase 1)
  mirrorSlash,    // 거울 슬래시 (Phase 1)
  darknessBlast,  // 어둠 발사 (Phase 2)
  darkVortex,     // 어둠 소용돌이 (Phase 2)
  weakAttack,     // 약한 공격 (Phase 3)
  phaseTransition,
  waitingForApproach, // Phase 3 특수: 접근 대기
  dead,
}

/// 그림자 자아 - 자기 자신과의 싸움
class BossShadow extends BaseEnemy {
  BossShadow({required super.position, this.onDefeat, this.onIntegration})
      : super(data: shadowSelfData) {
    size = Vector2(64, 64);
  }

  /// 처치 콜백
  final VoidCallback? onDefeat;

  /// 통합 콜백 (Phase 3 접근 시)
  final VoidCallback? onIntegration;

  /// 현재 페이즈
  ShadowPhase _phase = ShadowPhase.denial;
  ShadowPhase get phase => _phase;

  /// 페이즈 체크용 게터
  bool get isInAngerPhase => _phase == ShadowPhase.anger;
  bool get isInAcceptancePhase => _phase == ShadowPhase.acceptance;
  bool get isWaitingForIntegration => _state == ShadowState.waitingForApproach;

  /// 현재 상태
  ShadowState _state = ShadowState.float;

  /// 공격 타이머
  double _attackTimer = 0;

  /// 거울 쿨다운
  double _mirrorCooldown = 0;
  static const double mirrorCooldownTime = 2.5;

  /// 어둠 쿨다운
  double _darknessCooldown = 0;
  static const double darknessCooldownTime = 3.0;

  /// 소용돌이 쿨다운
  double _vortexCooldown = 0;
  static const double vortexCooldownTime = 5.0;

  /// 패턴 카운터
  int _patternCount = 0;

  /// 시각 효과
  double _floatOffset = 0;
  double _pulseTimer = 0;
  double _smokeTimer = 0;
  final List<_ShadowSmoke> _smokeParts = [];

  /// 눈 빛 효과
  double _eyeGlow = 1.0;

  /// Phase 3 특수: 약화 정도
  double _weakenMultiplier = 1.0;

  /// Phase 3 특수: 통합 체크 타이머
  double _integrationCheckTimer = 0;
  bool _integrationTriggered = false;
  static const double _integrationRange = 48.0;

  /// 페이즈 전환 중
  bool _isTransitioning = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _state = ShadowState.float;
  }

  @override
  void update(double dt) {
    // 죽음 상태면 스킵
    if (_state == ShadowState.dead) return;

    // 페이즈 업데이트
    _updatePhase();

    // 시각 효과 업데이트
    _updateVisuals(dt);

    // 연기 업데이트
    _updateSmoke(dt);

    // 쿨다운 감소
    _mirrorCooldown = (_mirrorCooldown - dt).clamp(0.0, double.infinity);
    _darknessCooldown = (_darknessCooldown - dt).clamp(0.0, double.infinity);
    _vortexCooldown = (_vortexCooldown - dt).clamp(0.0, double.infinity);
    _attackTimer += dt;

    // 페이즈 전환 중
    if (_isTransitioning) {
      if (_attackTimer > 2.0) {
        _completePhaseTransition();
      }
      return;
    }

    // Phase 3 통합 체크
    if (_state == ShadowState.waitingForApproach && !_integrationTriggered) {
      _checkIntegration(dt);
    }

    // AI 로직
    _updateAI(dt);

    super.update(dt);
  }

  void _updatePhase() {
    final hpPercent = health / data.maxHealth;

    if (!_isTransitioning) {
      if (_phase == ShadowPhase.denial && hpPercent <= 0.60) {
        _startPhaseTransition(ShadowPhase.anger);
      } else if (_phase == ShadowPhase.anger && hpPercent <= 0.30) {
        _startPhaseTransition(ShadowPhase.acceptance);
      }
    }
  }

  void _startPhaseTransition(ShadowPhase newPhase) {
    _isTransitioning = true;
    _attackTimer = 0;
    _state = ShadowState.phaseTransition;

    // 화면 효과
    ScreenShakeManager.heavyShake();

    // 페이즈별 효과
    if (newPhase == ShadowPhase.anger) {
      // 어둠 폭발
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.purple.shade900,
          particleCount: 40,
          speed: 180,
        ),
      );
    } else if (newPhase == ShadowPhase.acceptance) {
      // 약해지는 효과
      _weakenMultiplier = 0.5;
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.white,
          particleCount: 30,
          speed: 100,
        ),
      );
    }

    _phase = newPhase;
  }

  void _completePhaseTransition() {
    _isTransitioning = false;
    _attackTimer = 0;

    if (_phase == ShadowPhase.acceptance) {
      _state = ShadowState.waitingForApproach;
    } else {
      _state = ShadowState.float;
    }
  }

  void _checkIntegration(double dt) {
    _integrationCheckTimer += dt;

    if (_integrationCheckTimer >= 0.5) {
      _integrationCheckTimer = 0;

      final player = _findPlayer();
      if (player != null) {
        final distance = player.position.distanceTo(position);

        // 플레이어가 충분히 가까우면 통합
        if (distance <= _integrationRange) {
          _integrationTriggered = true;
          _state = ShadowState.dead;
          onIntegration?.call();
        }
      }
    }
  }

  void _updateVisuals(double dt) {
    // 부유 효과
    _floatOffset = sin(_pulseTimer * 2.5) * 6;

    // 맥동 효과
    _pulseTimer += dt;

    // 눈 빛 효과
    _eyeGlow = 0.7 + sin(_pulseTimer * 3) * 0.3;

    // Phase 3: 점점 투명해짐
    if (_phase == ShadowPhase.acceptance) {
      _weakenMultiplier = max(0.3, _weakenMultiplier - dt * 0.02);
    }
  }

  void _updateSmoke(double dt) {
    _smokeTimer += dt;

    // 연기 생성
    if (_smokeTimer >= 0.1) {
      _smokeTimer = 0;
      _smokeParts.add(_ShadowSmoke(
        offset: Vector2(
          (Random().nextDouble() - 0.5) * 30,
          (Random().nextDouble() - 0.5) * 30,
        ),
      ));
    }

    // 연기 업데이트
    for (final smoke in _smokeParts.toList()) {
      smoke.life -= dt;
      smoke.offset.y -= dt * 20;
      smoke.opacity = (smoke.life / smoke.maxLife).clamp(0, 1);

      if (smoke.life <= 0) {
        _smokeParts.remove(smoke);
      }
    }
  }

  void _updateAI(double dt) {
    if (_integrationTriggered) return;

    final player = _findPlayer();
    if (player == null) return;

    if (_state == ShadowState.waitingForApproach) {
      // Phase 3: 약한 공격만
      if (_attackTimer >= 4.0) {
        _attackTimer = 0;
        _executeWeakAttack(player);
      }
      return;
    }

    // 페이즈별 공격
    switch (_phase) {
      case ShadowPhase.denial:
        _executeDenialCombat(dt, player);
      case ShadowPhase.anger:
        _executeAngerCombat(dt, player);
      case ShadowPhase.acceptance:
        // 이미 위에서 처리됨
        break;
    }
  }

  /// Phase 1: 플레이어 복사 공격
  void _executeDenialCombat(double dt, ArcanaPlayer player) {
    if (_attackTimer < 2.0) return;

    _patternCount = (_patternCount + 1) % 3;

    switch (_patternCount) {
      case 0:
        if (_mirrorCooldown <= 0) {
          _executeMirrorDash(player);
          _mirrorCooldown = mirrorCooldownTime;
        }
      case 1:
        _executeMirrorSlash(player);
      case 2:
        _executeMirrorWave(player);
    }

    _attackTimer = 0;
  }

  void _executeMirrorDash(ArcanaPlayer player) {
    _state = ShadowState.mirrorDash;

    final direction = (player.position - position).normalized();
    final targetPos = position + direction * 120;

    // 돌진 (수동 이동)
    _dashTo(targetPos, 0.3);

    // 대미지 영역
    _spawnDashHitbox(direction);
  }

  void _dashTo(Vector2 target, double duration) {
    final startPos = position.clone();
    final diff = target - startPos;
    double elapsed = 0;

    // 간단한 타이머 기반 이동
    Future<void> animateDash() async {
      while (elapsed < duration && isMounted) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        elapsed += 0.016;
        final t = (elapsed / duration).clamp(0.0, 1.0);
        final eased = Curves.easeOut.transform(t);
        position = startPos + diff * eased;
      }
      if (isMounted) _state = ShadowState.float;
    }
    animateDash();
  }

  void _spawnDashHitbox(Vector2 direction) {
    final hitbox = _ShadowDashHitbox(
      direction: direction,
      damage: (data.attack * 0.8).toInt(),
    );
    hitbox.position = position.clone();
    parent?.add(hitbox);
  }

  void _executeMirrorSlash(ArcanaPlayer player) {
    _state = ShadowState.mirrorSlash;

    final direction = (player.position - position).normalized();

    for (var i = -1; i <= 1; i++) {
      final angle = atan2(direction.y, direction.x) + i * 0.3;
      final slashDir = Vector2(cos(angle), sin(angle));

      final slash = _ShadowSlash(
        direction: slashDir,
        damage: (data.attack * 0.6).toInt(),
      );
      slash.position = position.clone();
      parent?.add(slash);
    }

    AudioManager.instance.playSfx(SoundEffect.playerAttack);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (isMounted) _state = ShadowState.float;
    });
  }

  void _executeMirrorWave(ArcanaPlayer player) {
    // 플레이어 위치에 시간차 파동
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (!isMounted) return;
        final wave = _ShadowWave(
          damage: (data.attack * 0.5).toInt(),
          delay: i * 0.2,
        );
        wave.position = player.position.clone();
        parent?.add(wave);
      });
    }
  }

  /// Phase 2: 어둠의 힘
  void _executeAngerCombat(double dt, ArcanaPlayer player) {
    if (_attackTimer < 1.5) return;

    _patternCount = (_patternCount + 1) % 4;

    switch (_patternCount) {
      case 0:
        if (_darknessCooldown <= 0) {
          _executeDarknessBlast();
          _darknessCooldown = darknessCooldownTime;
        }
      case 1:
        if (_vortexCooldown <= 0) {
          _executeDarkVortex(player);
          _vortexCooldown = vortexCooldownTime;
        }
      case 2:
        _executeShadowTentacles(player);
      case 3:
        _executeMirrorSlash(player); // 복합 패턴
    }

    _attackTimer = 0;
  }

  void _executeDarknessBlast() {
    _state = ShadowState.darknessBlast;

    // 8방향 어둠 발사
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final direction = Vector2(cos(angle), sin(angle));

      final orb = _DarknessOrb(
        direction: direction,
        damage: (data.attack * 0.4).toInt(),
      );
      orb.position = position.clone();
      parent?.add(orb);
    }

    AudioManager.instance.playSfx(SoundEffect.playerAttack);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (isMounted) _state = ShadowState.float;
    });
  }

  void _executeDarkVortex(ArcanaPlayer player) {
    _state = ShadowState.darkVortex;

    final vortex = _DarkVortex(
      targetPos: player.position.clone(),
      damage: (data.attack * 0.3).toInt(),
      pullStrength: 50.0,
    );
    parent?.add(vortex);

    AudioManager.instance.playSfx(SoundEffect.bossAppear);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (isMounted) _state = ShadowState.float;
    });
  }

  void _executeShadowTentacles(ArcanaPlayer player) {
    // 바닥에서 솟아오르는 촉수들
    for (var i = 0; i < 5; i++) {
      final offset = Vector2(
        (Random().nextDouble() - 0.5) * 200,
        (Random().nextDouble() - 0.5) * 200,
      );

      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!isMounted) return;
        final tentacle = _ShadowTentacle(
          damage: (data.attack * 0.5).toInt(),
        );
        tentacle.position = player.position + offset;
        parent?.add(tentacle);
      });
    }
  }

  /// Phase 3: 약한 공격 (통합 대기)
  void _executeWeakAttack(ArcanaPlayer player) {
    // HP가 1이 되면 공격 중지
    if (health <= 1) return;

    _state = ShadowState.weakAttack;

    final direction = (player.position - position).normalized();
    final weakSlash = _ShadowSlash(
      direction: direction,
      damage: (data.attack * _weakenMultiplier * 0.3).toInt(),
      isWeak: true,
    );
    weakSlash.position = position.clone();
    parent?.add(weakSlash);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (isMounted) _state = ShadowState.waitingForApproach;
    });
  }

  ArcanaPlayer? _findPlayer() {
    try {
      return gameRef.world.children.whereType<ArcanaPlayer>().first;
    } catch (_) {
      return null;
    }
  }

  @override
  void takeDamage(double damage) {
    // Phase 3에서 HP 1 이하로 떨어지지 않음 (통합 필요)
    if (_phase == ShadowPhase.acceptance && health - damage < 1) {
      health = 1;
      return;
    }

    super.takeDamage(damage);
  }

  @override
  void renderEnemy(Canvas canvas) {
    final phaseOpacity = _phase == ShadowPhase.acceptance
        ? _weakenMultiplier
        : 1.0;

    // 연기 파티클
    for (final smoke in _smokeParts) {
      final smokePos = Offset(
        size.x / 2 + smoke.offset.x,
        size.y / 2 + smoke.offset.y + _floatOffset,
      );
      canvas.drawCircle(
        smokePos,
        smoke.size,
        Paint()
          ..color = const Color(0xFF1A1A2E).withValues(alpha: smoke.opacity * phaseOpacity * 0.6),
      );
    }

    // 메인 바디 (검은 안개 형태)
    final bodyRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2 + _floatOffset),
      width: 48,
      height: 56,
    );

    // 그림자 바디
    final bodyGradient = RadialGradient(
      colors: [
        Color.fromRGBO(0, 0, 0, 0.9 * phaseOpacity),
        Color.fromRGBO(26, 26, 46, 0.7 * phaseOpacity),
        const Color.fromRGBO(26, 26, 46, 0.0),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawOval(
      bodyRect,
      Paint()..shader = bodyGradient.createShader(bodyRect),
    );

    // 핏빛 눈
    final eyeY = size.y / 2 - 8 + _floatOffset;
    final leftEyeX = size.x / 2 - 8;
    final rightEyeX = size.x / 2 + 8;

    // 눈 발광
    final eyeGlowPaint = Paint()
      ..color = Color.fromRGBO(200, 30, 30, _eyeGlow * phaseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(leftEyeX, eyeY), 6, eyeGlowPaint);
    canvas.drawCircle(Offset(rightEyeX, eyeY), 6, eyeGlowPaint);

    // 눈 코어
    final eyeCorePaint = Paint()
      ..color = Color.fromRGBO(255, 50, 50, phaseOpacity);

    canvas.drawCircle(Offset(leftEyeX, eyeY), 3, eyeCorePaint);
    canvas.drawCircle(Offset(rightEyeX, eyeY), 3, eyeCorePaint);

    // Phase별 특수 효과
    switch (_phase) {
      case ShadowPhase.denial:
        _renderMirrorEffect(canvas);
      case ShadowPhase.anger:
        _renderDarknessAura(canvas);
      case ShadowPhase.acceptance:
        _renderWeakeningEffect(canvas);
    }
  }

  void _renderMirrorEffect(Canvas canvas) {
    // 주변에 희미한 분신들
    final mirrorPaint = Paint()
      ..color = const Color(0x201A1A2E);

    for (var i = 0; i < 4; i++) {
      final angle = _pulseTimer + i * pi / 2;
      final offset = Offset(
        cos(angle) * 30,
        sin(angle) * 30,
      );

      canvas.drawCircle(
        Offset(size.x / 2 + offset.dx, size.y / 2 + offset.dy + _floatOffset),
        20,
        mirrorPaint,
      );
    }
  }

  void _renderDarknessAura(Canvas canvas) {
    // 분노의 오라
    final auraPaint = Paint()
      ..color = Color.fromRGBO(30, 0, 50, 0.3 + sin(_pulseTimer * 4) * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2 + _floatOffset),
      50 + sin(_pulseTimer * 3) * 10,
      auraPaint,
    );
  }

  void _renderWeakeningEffect(Canvas canvas) {
    // 점점 빛으로 변하는 효과
    final lightAmount = 1.0 - _weakenMultiplier;

    if (lightAmount > 0.3) {
      final lightPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, lightAmount * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2 + _floatOffset),
        30,
        lightPaint,
      );
    }
  }
}

/// 연기 파티클
class _ShadowSmoke {
  _ShadowSmoke({required this.offset});

  Vector2 offset;
  double life = 0.8;
  final double maxLife = 0.8;
  double opacity = 1.0;
  double size = 8.0;
}

/// 그림자 돌진 히트박스
class _ShadowDashHitbox extends PositionComponent with HasGameRef {
  _ShadowDashHitbox({
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(60, 30));

  final Vector2 direction;
  final int damage;
  double _lifetime = 0.3;

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * 400 * dt;
    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Color.fromRGBO(50, 0, 80, 0.6 * (_lifetime / 0.3));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );
  }
}

/// 그림자 슬래시
class _ShadowSlash extends PositionComponent with HasGameRef {
  _ShadowSlash({
    required this.direction,
    required this.damage,
    this.isWeak = false,
  }) : super(size: Vector2(40, 20));

  final Vector2 direction;
  final int damage;
  final bool isWeak;
  double _lifetime = 0.4;

  @override
  void update(double dt) {
    super.update(dt);

    final speed = isWeak ? 150.0 : 300.0;
    position += direction * speed * dt;
    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = isWeak ? 0.3 : 0.7;
    final color = isWeak
        ? Color.fromRGBO(100, 100, 100, opacity * (_lifetime / 0.4))
        : Color.fromRGBO(50, 0, 80, opacity * (_lifetime / 0.4));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color,
    );
  }
}

/// 그림자 파동
class _ShadowWave extends PositionComponent with HasGameRef {
  _ShadowWave({
    required this.damage,
    required this.delay,
  }) : super(size: Vector2(100, 100), anchor: Anchor.center);

  final int damage;
  final double delay;
  double _timer = 0;
  double _radius = 0;
  bool _triggered = false;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer < delay) return;

    if (!_triggered) {
      _triggered = true;
    }

    _radius += dt * 150;

    if (_radius > 80) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_triggered) {
      // 경고 표시
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        40,
        Paint()
          ..color = const Color(0x40FF0000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      return;
    }

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      _radius,
      Paint()
        ..color = Color.fromRGBO(30, 0, 50, 0.5 * (1 - _radius / 80))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
  }
}

/// 어둠 구체
class _DarknessOrb extends PositionComponent with HasGameRef {
  _DarknessOrb({
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(20, 20), anchor: Anchor.center);

  final Vector2 direction;
  final int damage;
  double _lifetime = 2.0;

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * 120 * dt;
    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Color.fromRGBO(20, 0, 40, 0.8 * (_lifetime / 2.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, paint);

    // 코어
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      5,
      Paint()..color = Color.fromRGBO(80, 0, 120, _lifetime / 2.0),
    );
  }
}

/// 어둠 소용돌이
class _DarkVortex extends PositionComponent with HasGameRef {
  _DarkVortex({
    required this.targetPos,
    required this.damage,
    required this.pullStrength,
  }) : super(size: Vector2(120, 120), anchor: Anchor.center);

  final Vector2 targetPos;
  final int damage;
  final double pullStrength;
  double _lifetime = 2.5;
  double _rotation = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = targetPos;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _rotation += dt * 5;
    _lifetime -= dt;

    // 플레이어 끌어당기기
    try {
      final player = gameRef.world.children.whereType<ArcanaPlayer>().first;
      final toVortex = position - player.position;
      final distance = toVortex.length;

      if (distance < 80 && distance > 10) {
        final pullDir = toVortex.normalized();
        player.position += pullDir * pullStrength * dt;
      }
    } catch (_) {
      // 플레이어 없음
    }

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);

    // 소용돌이 링들
    for (var i = 0; i < 4; i++) {
      final radius = 20.0 + i * 15;
      final opacity = 0.5 * (_lifetime / 2.5) * (1 - i / 4);

      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = Color.fromRGBO(30, 0, 60, opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.restore();
  }
}

/// 그림자 촉수
class _ShadowTentacle extends PositionComponent with HasGameRef {
  _ShadowTentacle({required this.damage})
      : super(size: Vector2(30, 80), anchor: Anchor.bottomCenter);

  final int damage;
  double _timer = 0;
  double _height = 0;
  bool _warning = true;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer < 0.5) {
      return;
    }

    _warning = false;

    if (_timer < 1.0) {
      _height = (_timer - 0.5) * 2 * 80;
    } else if (_timer < 1.5) {
      _height = 80;
    } else {
      _height = 80 * (1 - (_timer - 1.5) / 0.3);
    }

    if (_timer > 1.8) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_warning) {
      // 경고 표시
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.x / 2, 0), width: 30, height: 10),
        Paint()
          ..color = const Color(0x60FF0000)
          ..style = PaintingStyle.fill,
      );
      return;
    }

    // 촉수 그리기
    final path = Path();
    path.moveTo(size.x / 2 - 8, 0);
    path.quadraticBezierTo(
      size.x / 2 - 5,
      -_height / 2,
      size.x / 2,
      -_height,
    );
    path.quadraticBezierTo(
      size.x / 2 + 5,
      -_height / 2,
      size.x / 2 + 8,
      0,
    );
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xDD200030),
    );
  }
}
