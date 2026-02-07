/// Arcana: The Three Hearts - 플레이어 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'enemy.dart';
import 'systems/audio_system.dart';
import 'components/effects/screen_effects.dart';
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

  // 무기 스프라이트
  Sprite? _swordSprite;

  // 검기 이펙트
  double _slashEffectTimer = 0;
  static const double _slashEffectDuration = 0.25;
  int _currentSlashCombo = 0;

  // 피격 이펙트
  double _hitEffectTimer = 0;
  static const double _hitEffectDuration = 0.3;
  Vector2 _hitKnockback = Vector2.zero();

  // 공격 상태
  bool isAttacking = false;
  double _attackTimer = 0;
  static const double _attackDuration = 0.2; // 더 빠른 공격
  int _comboCount = 0;
  double _comboTimer = 0;
  static const double _comboWindow = 0.5; // 콤보 윈도우 확장

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
  static const double _attackEffectDuration = 0.3;

  // 공격 중 이동 속도 배율
  static const double _attackMoveSpeedMultiplier = 0.7;

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

    // 무기 스프라이트 로드
    try {
      _swordSprite = await Sprite.load('${assetPath}weapon_knight_sword.png');
    } catch (e) {
      debugPrint('무기 스프라이트 로드 실패: $e');
    }

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

    // 검기 이펙트 타이머
    if (_slashEffectTimer > 0) {
      _slashEffectTimer -= dt;
    }

    // 피격 이펙트 타이머
    if (_hitEffectTimer > 0) {
      _hitEffectTimer -= dt;
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
    } else if (moveDirection.length > 0) {
      final normalized = moveDirection.normalized();
      // 공격 중에도 이동 가능 (속도 감소)
      final currentSpeed = isAttacking ? speed * _attackMoveSpeedMultiplier : speed;
      position += normalized * currentSpeed * dt;
      // 공격 중이 아닐 때만 방향 전환
      if (!isAttacking && normalized.x != 0) {
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
    if (_isDashing) return 0;

    // 공격 중이라도 콤보 윈도우 내면 다음 공격 가능
    if (isAttacking && _attackTimer > _attackDuration * 0.3) return 0;

    isAttacking = true;
    _attackTimer = _attackDuration;
    _comboCount = (_comboCount + 1) % 3;

    // 공격 이펙트 타이머 시작
    _attackEffectTimer = _attackEffectDuration;

    // 공격 효과음
    AudioSystem.instance.playAttackSfx(_comboCount);

    // 검기 이펙트 시작
    _slashEffectTimer = _slashEffectDuration;
    _currentSlashCombo = _comboCount;

    // 범위 내 적에게 데미지 (리스트 복사본 사용)
    final damage = attackDamage + (_comboCount * 8); // 콤보 데미지 증가
    int hitCount = 0;

    for (final enemy in [...enemies]) {
      if (enemy.isDead) continue;

      final toEnemy = enemy.position - position;
      final distance = toEnemy.length;

      // 거리 체크 - 콤보에 따라 범위 증가
      final currentRange = attackRange + (_comboCount * 10);
      if (distance > currentRange) continue;

      // 방향 체크 (플레이어가 바라보는 방향의 적만)
      final dot = toEnemy.x * (_facingRight ? 1 : -1);
      if (dot < 0) continue; // 뒤에 있는 적은 무시

      enemy.takeDamage(damage);
      hitCount++;

      // 적 피격 효과음
      AudioSystem.instance.playEnemyHitSfx();

      // 3콤보 강공격 시 히트스톱 + 흔들림
      if (_comboCount == 2) {
        ScreenEffects.instance.onHeavyAttack();
      }
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

    // 대시 효과음
    AudioSystem.instance.playDashSfx();

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

    // 피격 효과음
    AudioSystem.instance.playHitSfx();

    // 화면 효과
    ScreenEffects.instance.onPlayerHit();

    // 데미지 숫자 표시
    final damageNumber = EffectFactory.createDamageNumber(
      position: position + Vector2(0, -20),
      damage: damage,
      color: Colors.red,
    );
    parent?.add(damageNumber);

    // 로그
    GameLogger.instance.logPlayerHit(damage, hp);

    _isInvulnerable = true;
    _invulnerableTimer = _invulnerableDuration;

    // 피격 이펙트
    _hitEffectTimer = _hitEffectDuration;
    _effectColor = Colors.red.withAlpha(200);
    _effectTimer = 0.15;
  }

  /// 완벽 회피 발동
  void _triggerPerfectDodge() {
    _perfectDodgeTriggered = true;

    // 완벽 회피 이펙트
    _effectColor = Colors.yellow;
    _effectTimer = 0.2;

    // 화면 효과
    ScreenEffects.instance.onPerfectDodge();

    // 무적 시간 연장
    _isInvulnerable = true;
    _invulnerableTimer = 0.3;

    // 콜백 호출
    onPerfectDodge?.call();

    GameLogger.instance.log('COMBAT', '완벽 회피 발동!');
  }

  /// 회복
  void heal(double amount) {
    final actualHeal = (hp + amount).clamp(0, maxHp) - hp;
    hp = (hp + amount).clamp(0, maxHp);
    onHpChanged?.call(hp, maxHp);

    // 회복 숫자 표시
    if (actualHeal > 0) {
      final healNumber = EffectFactory.createHealNumber(
        position: position + Vector2(0, -20),
        amount: actualHeal,
      );
      parent?.add(healNumber);
    }

    _effectColor = Colors.green.withAlpha(200);
    _effectTimer = 0.2;
  }

  @override
  void render(Canvas canvas) {
    // 피격 이펙트 (캐릭터 뒤에)
    if (_hitEffectTimer > 0) {
      _renderHitEffect(canvas);
    }

    super.render(canvas);

    // 검 항상 렌더링
    if (_swordSprite != null) {
      _renderSword(canvas);
    }

    // 검기 이펙트 (검 앞에)
    if (_slashEffectTimer > 0) {
      _renderSlashEffect(canvas);
    }
  }

  /// 검기(슬래시) 이펙트 렌더링
  void _renderSlashEffect(Canvas canvas) {
    final progress = 1.0 - (_slashEffectTimer / _slashEffectDuration);
    final alpha = ((1 - progress) * 200).toInt().clamp(0, 255);

    final direction = _facingRight ? 1.0 : -1.0;
    final offsetX = direction * 30;

    // 콤보별 다른 검기 패턴
    final slashColor = _currentSlashCombo == 2
        ? Colors.orange.withAlpha(alpha)
        : Colors.white.withAlpha(alpha);

    final paint = Paint()
      ..color = slashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + (_currentSlashCombo * 1.5)
      ..strokeCap = StrokeCap.round;

    // 검기 크기 (콤보에 따라 커짐)
    final size = 30.0 + (_currentSlashCombo * 15) + (progress * 20);

    // 검기 호 그리기
    final rect = Rect.fromCenter(
      center: Offset(offsetX, 0),
      width: size,
      height: size * 0.6,
    );

    // 콤보별 다른 각도
    double startAngle;
    double sweepAngle;
    if (_currentSlashCombo == 0) {
      startAngle = _facingRight ? -pi / 3 : pi * 2 / 3;
      sweepAngle = direction * pi * 0.7;
    } else if (_currentSlashCombo == 1) {
      startAngle = _facingRight ? pi / 3 : pi - pi / 3;
      sweepAngle = direction * -pi * 0.7;
    } else {
      startAngle = _facingRight ? -pi / 2 : pi / 2;
      sweepAngle = direction * pi;
    }

    canvas.drawArc(rect, startAngle, sweepAngle * (0.3 + progress * 0.7), false, paint);

    // 글로우 효과
    final glowPaint = Paint()
      ..color = slashColor.withAlpha((alpha * 0.4).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 + (_currentSlashCombo * 2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(rect, startAngle, sweepAngle * (0.3 + progress * 0.7), false, glowPaint);
  }

  /// 피격 이펙트 렌더링
  void _renderHitEffect(Canvas canvas) {
    final progress = 1.0 - (_hitEffectTimer / _hitEffectDuration);
    final alpha = ((1 - progress) * 150).toInt().clamp(0, 150);

    // 빨간 원형 충격파
    final wavePaint = Paint()
      ..color = Colors.red.withAlpha(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final waveRadius = 10.0 + progress * 25;
    canvas.drawCircle(Offset.zero, waveRadius, wavePaint);

    // X 모양 피격 마크
    final markAlpha = ((1 - progress * 0.5) * 200).toInt().clamp(0, 200);
    final markPaint = Paint()
      ..color = Colors.red.withAlpha(markAlpha)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final markSize = 8.0 + progress * 5;
    canvas.drawLine(
      Offset(-markSize, -markSize),
      Offset(markSize, markSize),
      markPaint,
    );
    canvas.drawLine(
      Offset(markSize, -markSize),
      Offset(-markSize, markSize),
      markPaint,
    );
  }

  /// 검 렌더링 (항상 들고 있음)
  void _renderSword(Canvas canvas) {
    if (_swordSprite == null) return;

    canvas.save();

    // 검 위치 (플레이어 옆)
    final direction = _facingRight ? 1.0 : -1.0;
    final offsetX = direction * 12;
    final offsetY = 2.0;

    canvas.translate(offsetX, offsetY);

    // 방향에 따라 뒤집기
    if (!_facingRight) {
      canvas.scale(-1, 1);
    }

    // 고정 각도 (약간 기울임)
    canvas.rotate(pi / 6);

    // 검 크기
    final swordSize = Vector2(10.0, 24.0);

    // 검 그리기
    _swordSprite!.render(
      canvas,
      position: Vector2(-swordSize.x * 0.5, -swordSize.y * 0.5),
      size: swordSize,
    );

    canvas.restore();
  }
}
