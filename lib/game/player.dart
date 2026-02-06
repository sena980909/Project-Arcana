/// Arcana: The Three Hearts - 플레이어 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'enemy.dart';
import '../utils/game_logger.dart';

/// HP 변경 콜백
typedef HpChangedCallback = void Function(double hp, double maxHp);

/// 콜백
typedef VoidCallback = void Function();

/// 플레이어 컴포넌트
class Player extends PositionComponent with HasGameRef {
  Player({
    required Vector2 position,
    required this.assetPath,
    this.onHpChanged,
    this.onPerfectDodge,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        );

  final String assetPath;
  final HpChangedCallback? onHpChanged;
  final VoidCallback? onPerfectDodge;

  // 스탯
  double hp = 100;
  double maxHp = 100;
  double speed = 150;
  double attackRange = 60;
  double attackDamage = 25;

  // 이동
  Vector2 moveDirection = Vector2.zero();
  bool _facingRight = true;

  // 애니메이션
  SpriteAnimation? _idleAnimation;
  SpriteAnimation? _runAnimation;
  SpriteAnimationComponent? _animationComponent;

  // 공격 상태
  bool isAttacking = false;
  double _attackTimer = 0;
  static const double _attackDuration = 0.25;
  int _comboCount = 0;
  double _comboTimer = 0;
  static const double _comboWindow = 0.4;

  // 대시 상태
  bool _isDashing = false;
  double _dashTimer = 0;
  static const double _dashDuration = 0.15;
  static const double _dashSpeed = 500;
  static const double _dashCooldown = 0.6;
  double _dashCooldownTimer = 0;
  Vector2 _dashDirection = Vector2.zero();

  // 무적 프레임
  bool _isInvulnerable = false;
  double _invulnerableTimer = 0;
  static const double _invulnerableDuration = 0.5;

  // 완벽 회피 윈도우
  double _perfectDodgeWindow = 0;
  static const double _perfectDodgeWindowDuration = 0.15;
  bool _perfectDodgeTriggered = false;

  // 이펙트
  double _effectTimer = 0;
  Color _effectColor = Colors.white;

  // 공격 이펙트 (직접 렌더링)
  double _attackEffectTimer = 0;
  static const double _attackEffectDuration = 0.2;

  /// 무적 상태 여부 (외부에서 확인용)
  bool get isInvulnerable => _isInvulnerable;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 애니메이션 로드
    _idleAnimation = await _loadAnimation('knight_m_idle_anim', 4, 0.15);
    _runAnimation = await _loadAnimation('knight_m_run_anim', 4, 0.08);

    _animationComponent = SpriteAnimationComponent(
      animation: _idleAnimation,
      size: Vector2(32, 32),
      anchor: Anchor.center,
    );
    add(_animationComponent!);

    // HP 초기값 전달
    onHpChanged?.call(hp, maxHp);
  }

  /// 애니메이션 로드
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
        debugPrint('Failed to load sprite: ${assetPath}${baseName}_f$i.png');
      }
    }
    if (sprites.isEmpty) {
      sprites.add(await Sprite.load('${assetPath}knight_m_idle_anim_f0.png'));
    }
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateTimers(dt);
    _updateMovement(dt);
    _updateAnimation();
    _updateEffect(dt);
  }

  void _updateTimers(double dt) {
    // 공격 타이머
    if (isAttacking) {
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        isAttacking = false;
        _comboTimer = _comboWindow;
      }
    }

    // 공격 이펙트 타이머
    if (_attackEffectTimer > 0) {
      _attackEffectTimer -= dt;
    }

    // 콤보 타이머
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        _comboCount = 0;
      }
    }

    // 대시 타이머
    if (_isDashing) {
      _dashTimer -= dt;
      if (_dashTimer <= 0) {
        _isDashing = false;
      }
    }

    // 대시 쿨다운
    if (_dashCooldownTimer > 0) {
      _dashCooldownTimer -= dt;
    }

    // 완벽 회피 윈도우 타이머
    if (_perfectDodgeWindow > 0) {
      _perfectDodgeWindow -= dt;
      if (_perfectDodgeWindow <= 0) {
        _perfectDodgeTriggered = false;
      }
    }

    // 무적 타이머
    if (_isInvulnerable) {
      _invulnerableTimer -= dt;
      if (_invulnerableTimer <= 0) {
        _isInvulnerable = false;
      }
    }
  }

  void _updateEffect(double dt) {
    if (_effectTimer > 0) {
      _effectTimer -= dt;
      _animationComponent?.paint.color = _effectColor;
      if (_effectTimer <= 0) {
        _animationComponent?.paint.color = Colors.white;
      }
    }

    // 무적 중 깜빡임
    if (_isInvulnerable && _effectTimer <= 0) {
      final alpha = ((_invulnerableTimer * 10) % 2 < 1) ? 100 : 255;
      _animationComponent?.paint.color = Colors.white.withAlpha(alpha);
    }

    // 완벽 회피 윈도우 중 이펙트
    if (_perfectDodgeWindow > 0 && !_perfectDodgeTriggered) {
      _animationComponent?.paint.color = Colors.cyan.withAlpha(200);
    }
  }

  void _updateMovement(double dt) {
    if (_isDashing) {
      position += _dashDirection * _dashSpeed * dt;
    } else if (!isAttacking && moveDirection.length > 0) {
      final normalized = moveDirection.normalized();
      position += normalized * speed * dt;
      if (normalized.x != 0) {
        _facingRight = normalized.x > 0;
      }
    }
    _animationComponent?.scale.x = _facingRight ? 1 : -1;
  }

  void _updateAnimation() {
    if (_animationComponent == null) return;
    if (_isDashing || isAttacking) return;

    if (moveDirection.length > 0) {
      _animationComponent!.animation = _runAnimation;
    } else {
      _animationComponent!.animation = _idleAnimation;
    }
  }

  /// 공격 (적 리스트를 받아서 데미지 처리, 적중 수 반환)
  int attack(List<Enemy> enemies) {
    if (isAttacking || _isDashing) return 0;

    isAttacking = true;
    _attackTimer = _attackDuration;
    _comboCount = (_comboCount + 1) % 3;

    // 공격 이펙트 타이머 시작
    _attackEffectTimer = _attackEffectDuration;

    // 공격 색상 이펙트
    _effectColor = Colors.white;
    _effectTimer = 0.05;

    // 공격 방향으로 살짝 이동 (런지)
    final lungeDir = Vector2(_facingRight ? 1 : -1, 0);
    position += lungeDir * 8;

    // 범위 내 적에게 데미지 (리스트 복사본 사용)
    final damage = attackDamage + (_comboCount * 5);
    int hitCount = 0;

    for (final enemy in [...enemies]) {
      if (enemy.isDead) continue;

      final toEnemy = enemy.position - position;
      final distance = toEnemy.length;

      // 거리 체크
      if (distance > attackRange) continue;

      // 방향 체크 (플레이어가 바라보는 방향의 적만)
      final dot = toEnemy.x * (_facingRight ? 1 : -1);
      if (dot < 0) continue; // 뒤에 있는 적은 무시

      enemy.takeDamage(damage);
      hitCount++;
    }

    // 공격 로그
    GameLogger.instance.logPlayerAttack(_comboCount, damage, hitCount);

    return hitCount;
  }

  /// 대시
  void dash() {
    if (_isDashing || _dashCooldownTimer > 0) return;

    _isDashing = true;
    _dashTimer = _dashDuration;
    _dashCooldownTimer = _dashCooldown;

    if (moveDirection.length > 0) {
      _dashDirection = moveDirection.normalized();
    } else {
      _dashDirection = Vector2(_facingRight ? 1 : -1, 0);
    }

    _isInvulnerable = true;
    _invulnerableTimer = _dashDuration + 0.05;

    // 완벽 회피 윈도우 시작
    _perfectDodgeWindow = _perfectDodgeWindowDuration;
    _perfectDodgeTriggered = false;

    // 대시 이펙트
    _effectColor = Colors.cyan.withAlpha(150);
    _effectTimer = 0.1;

    // 로그
    GameLogger.instance.logPlayerDash(position.x, position.y);
  }

  /// 피격 처리
  void takeDamage(double damage) {
    if (_isInvulnerable || hp <= 0) {
      // 완벽 회피 체크
      if (_perfectDodgeWindow > 0 && !_perfectDodgeTriggered) {
        _triggerPerfectDodge();
      }
      return;
    }

    hp = (hp - damage).clamp(0, maxHp);
    onHpChanged?.call(hp, maxHp);

    // 로그
    GameLogger.instance.logPlayerHit(damage, hp);

    _isInvulnerable = true;
    _invulnerableTimer = _invulnerableDuration;

    _effectColor = Colors.red.withAlpha(200);
    _effectTimer = 0.15;
  }

  /// 완벽 회피 발동
  void _triggerPerfectDodge() {
    _perfectDodgeTriggered = true;

    // 완벽 회피 이펙트
    _effectColor = Colors.yellow;
    _effectTimer = 0.2;

    // 무적 시간 연장
    _isInvulnerable = true;
    _invulnerableTimer = 0.3;

    // 콜백 호출
    onPerfectDodge?.call();

    GameLogger.instance.log('COMBAT', '완벽 회피 발동!');
  }

  /// 회복
  void heal(double amount) {
    hp = (hp + amount).clamp(0, maxHp);
    onHpChanged?.call(hp, maxHp);

    _effectColor = Colors.green.withAlpha(200);
    _effectTimer = 0.2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 공격 이펙트 렌더링
    if (_attackEffectTimer > 0) {
      final progress = 1.0 - (_attackEffectTimer / _attackEffectDuration);
      final alpha = ((1 - progress) * 200).toInt();

      // 콤보에 따른 색상
      final colors = [
        Colors.white.withAlpha(alpha),
        Colors.yellow.withAlpha(alpha),
        Colors.orange.withAlpha(alpha),
      ];
      final color = colors[_comboCount % 3];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // 슬래시 효과 위치
      final offsetX = _facingRight ? 25.0 : -25.0;

      // 슬래시 호
      final rect = Rect.fromCenter(
        center: Offset(offsetX, 0),
        width: 40 * (0.8 + progress * 0.4),
        height: 30 * (0.8 + progress * 0.4),
      );

      final startAngle = _facingRight ? -pi / 3 : pi * 2 / 3;
      final sweepAngle = (_facingRight ? 1 : -1) * pi * 2 / 3;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      // 슬래시 라인
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      final lineLength = 20.0 + progress * 10;
      final lineAngle = _facingRight
          ? -pi / 6 + (_comboCount * pi / 8)
          : pi + pi / 6 - (_comboCount * pi / 8);

      canvas.drawLine(
        Offset(offsetX, 0),
        Offset(offsetX + cos(lineAngle) * lineLength, sin(lineAngle) * lineLength),
        linePaint,
      );
    }

    // 완벽 회피 윈도우 표시 (디버그)
    if (_perfectDodgeWindow > 0 && !_perfectDodgeTriggered) {
      final indicatorPaint = Paint()
        ..color = Colors.cyan.withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset.zero, 20, indicatorPaint);
    }
  }
}
