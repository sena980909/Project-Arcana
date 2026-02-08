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

/// 완벽 회피 콜백
typedef PerfectDodgeCallback = void Function();

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
  final PerfectDodgeCallback? onPerfectDodge;

  // 스탯
  double hp = 100;
  double maxHp = 100;
  double speed = 150;
  double attackRange = 60;
  double attackDamage = 25;

  // 버프 배율 (스킬 시스템에서 설정)
  double buffDamageMultiplier = 1.0;
  double buffDefenseMultiplier = 1.0;
  double buffSpeedMultiplier = 1.0;

  // 이동
  Vector2 moveDirection = Vector2.zero();
  bool _facingRight = true;
  Vector2 _lastAimDirection = Vector2(1, 0);

  /// 스킬/투사체 조준 방향
  Vector2 get aimDirection => _lastAimDirection.clone();

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

  // 공격 상태
  bool isAttacking = false;
  double _attackTimer = 0;
  static const double _attackDuration = 0.25;
  int _comboCount = 0;
  double _comboTimer = 0;
  static const double _comboWindow = 0.5;
  double _attackCooldownTimer = 0;
  static const double _attackCooldown = 0.12; // 공격 간 최소 쿨타임

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

  // 아이들 검 흔들림
  double _idleBobTimer = 0;

  // 사망 상태
  bool isDead = false;

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
    _idleBobTimer += dt;

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

    // 공격 쿨타임
    if (_attackCooldownTimer > 0) {
      _attackCooldownTimer -= dt;
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
      final alpha = ((_invulnerableTimer * 10) % 2 < 1) ? 120 : 255;
      _animationComponent?.paint.color = Colors.white.withAlpha(alpha);
    }

    // 무적 종료 시 색상 완전 복원
    if (!_isInvulnerable && _effectTimer <= 0 && _perfectDodgeWindow <= 0) {
      _animationComponent?.paint.color = Colors.white;
    }

    // 완벽 회피 윈도우 중 이펙트
    if (_perfectDodgeWindow > 0 && !_perfectDodgeTriggered) {
      _animationComponent?.paint.color = Colors.cyan.withAlpha(200);
    }

    // 사망 상태: 회색
    if (isDead) {
      _animationComponent?.paint.color = Colors.grey.withAlpha(150);
    }
  }

  void _updateMovement(double dt) {
    if (isDead) return;
    if (_isDashing) {
      position += _dashDirection * _dashSpeed * dt;
    } else if (moveDirection.length > 0) {
      final normalized = moveDirection.normalized();
      // 조준 방향 업데이트 (이동 시 항상)
      _lastAimDirection = normalized.clone();
      // 공격 중에도 이동 가능 (속도 감소)
      final currentSpeed = (isAttacking ? speed * _attackMoveSpeedMultiplier : speed) * buffSpeedMultiplier;
      position += normalized * currentSpeed * dt;
      // 공격 중이 아닐 때만 방향 전환
      if (!isAttacking && normalized.x != 0) {
        _facingRight = normalized.x > 0;
      }
    }
    // 정지 시 조준 방향: 바라보는 방향 (수평)
    if (moveDirection.length == 0 && !_isDashing) {
      _lastAimDirection = Vector2(_facingRight ? 1 : -1, 0);
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
    if (isDead || _isDashing) return 0;
    if (_attackCooldownTimer > 0) return 0;

    // 공격 중이라도 콤보 윈도우 내면 다음 공격 가능
    if (isAttacking && _attackTimer > _attackDuration * 0.3) return 0;

    isAttacking = true;
    _attackTimer = _attackDuration;
    _attackCooldownTimer = _attackCooldown;
    _comboCount = (_comboCount + 1) % 3;

    // 공격 이펙트 타이머 시작
    _attackEffectTimer = _attackEffectDuration;

    // 공격 효과음
    AudioSystem.instance.playAttackSfx(_comboCount);

    // 검기 이펙트 시작
    _slashEffectTimer = _slashEffectDuration;
    _currentSlashCombo = _comboCount;

    // 범위 내 적에게 데미지 (리스트 복사본 사용)
    final damage = (attackDamage + (_comboCount * 8)) * buffDamageMultiplier; // 콤보 + 버프 적용
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
    if (isDead || _isDashing || _dashCooldownTimer > 0) return;

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

    final actualDamage = damage * buffDefenseMultiplier;
    hp = (hp - actualDamage).clamp(0, maxHp);
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

  /// 환경 피해 (무적 무시, 이펙트 없음)
  void takeEnvironmentDamage(double damage) {
    if (hp <= 0) return;
    hp = (hp - damage).clamp(0, maxHp);
    onHpChanged?.call(hp, maxHp);
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

  /// 검기(슬래시) 이펙트 렌더링 - 호(arc) 형태 휘두르기
  void _renderSlashEffect(Canvas canvas) {
    final progress = 1.0 - (_slashEffectTimer / _slashEffectDuration);
    final alpha = ((1 - progress) * 220).toInt().clamp(0, 255);

    final direction = _facingRight ? 1.0 : -1.0;
    final centerX = direction * 18;

    // 푸른색 검기 (3콤보는 밝은 하늘색)
    final baseColor = _currentSlashCombo == 2
        ? Color.fromARGB(alpha, 100, 200, 255)
        : Color.fromARGB(alpha, 60, 140, 255);

    // 호 반지름 (콤보에 따라 커짐)
    final arcRadius = 26.0 + (_currentSlashCombo * 10) + (progress * 8);
    final arcWidth = 4.0 + (_currentSlashCombo * 1.5);

    // 콤보별 호 각도 범위 (sweep 방향)
    double startAngle;
    double sweepAngle;

    if (_currentSlashCombo == 0) {
      // 콤보 0: 위에서 아래로 (반시계 호)
      startAngle = _facingRight ? -pi * 0.6 : pi * 0.6;
      sweepAngle = (_facingRight ? 1 : -1) * pi * 0.7;
    } else if (_currentSlashCombo == 1) {
      // 콤보 1: 아래에서 위로 (시계 호)
      startAngle = _facingRight ? pi * 0.3 : pi * 0.7;
      sweepAngle = (_facingRight ? -1 : 1) * pi * 0.7;
    } else {
      // 콤보 2 (강타): 넓은 180도 수평 휘두르기
      startAngle = _facingRight ? -pi * 0.5 : pi * 0.5;
      sweepAngle = (_facingRight ? 1 : -1) * pi;
    }

    // progress에 따라 sweep 범위 확장
    final currentSweep = sweepAngle * progress;

    // 부채꼴 면적 채우기
    final arcPath = Path();
    final rect = Rect.fromCircle(center: Offset(centerX, 0), radius: arcRadius);
    arcPath.moveTo(centerX, 0);
    arcPath.arcTo(rect, startAngle, currentSweep, false);
    arcPath.close();

    final fillPaint = Paint()
      ..color = baseColor.withAlpha((alpha * 0.5).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawPath(arcPath, fillPaint);

    // 호 외곽선 (코어 라인) - sweep 끝부분 강조
    final corePaint = Paint()
      ..color = Color.fromARGB(alpha, 200, 230, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcWidth * 0.6
      ..strokeCap = StrokeCap.round;

    // 현재 sweep 위치의 끝 선분 (칼날 끝)
    final tipAngle = startAngle + currentSweep;
    final tipX = centerX + cos(tipAngle) * arcRadius;
    final tipY = sin(tipAngle) * arcRadius;
    canvas.drawLine(Offset(centerX, 0), Offset(tipX, tipY), corePaint);

    // 호 궤적 (외곽 arc)
    final arcStrokePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, currentSweep, false, arcStrokePaint);

    // 글로우 효과
    final glowPaint = Paint()
      ..color = baseColor.withAlpha((alpha * 0.3).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcWidth + 6 + (_currentSlashCombo * 2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawArc(rect, startAngle, currentSweep, false, glowPaint);
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

  /// 검 렌더링 (스윙 애니메이션 포함)
  void _renderSword(Canvas canvas) {
    if (_swordSprite == null) return;

    final direction = _facingRight ? 1.0 : -1.0;

    double swordAngle;
    double handleX;
    double handleY;

    if (isAttacking && _attackTimer > 0) {
      final progress = 1.0 - (_attackTimer / _attackDuration);
      final eased = _easeOutQuad(progress);

      // 콤보별 다른 스윙 궤적
      switch (_currentSlashCombo) {
        case 1: // 1타: 가로 베기 (위→아래 대각선)
          swordAngle = _lerpDouble(-pi / 3, pi * 3 / 4, eased);
          handleX = direction * (8 + eased * 12);
          handleY = -2 + eased * 4;
        case 2: // 2타: 올려베기 (아래→위)
          swordAngle = _lerpDouble(pi * 3 / 4, -pi / 4, eased);
          handleX = direction * (12 - eased * 2);
          handleY = 4 - eased * 10;
        default: // 3타(0): 내려찍기 강타
          final slamEased = _easeOutCubic(progress);
          swordAngle = _lerpDouble(-pi * 2 / 3, pi / 2, slamEased);
          handleX = direction * (6 + slamEased * 14);
          handleY = -8 + slamEased * 16;
      }

      // 스윙 잔상 렌더링
      _renderSwingTrail(canvas, direction, handleX, handleY, progress);
    } else {
      // 대기 자세: 부드러운 흔들림
      swordAngle = pi / 5;
      handleX = direction * 10;
      handleY = 4 + sin(_idleBobTimer * 2.5) * 1.5;
    }

    // 검 본체 렌더링
    canvas.save();
    canvas.translate(handleX, handleY);
    if (!_facingRight) {
      canvas.scale(-1, 1);
    }
    canvas.rotate(swordAngle);

    final swordSize = Vector2(10.0, 24.0);
    _swordSprite!.render(
      canvas,
      position: Vector2(-swordSize.x / 2, -swordSize.y),
      size: swordSize,
    );

    canvas.restore();
  }

  /// 스윙 잔상 렌더링
  void _renderSwingTrail(
      Canvas canvas, double direction, double handleX, double handleY, double progress) {
    const trailCount = 3;
    final isHeavy = _currentSlashCombo == 0;
    final trailColor = isHeavy ? const Color(0xFFFF8800) : const Color(0xFFCCDDFF);

    for (int i = trailCount; i >= 1; i--) {
      final trailProgress = (progress - i * 0.12).clamp(0.0, 1.0);
      if (trailProgress <= 0) continue;

      double trailAngle;
      switch (_currentSlashCombo) {
        case 1: // 가로 베기
          trailAngle = _lerpDouble(-pi / 3, pi * 3 / 4, _easeOutQuad(trailProgress));
        case 2: // 올려베기
          trailAngle = _lerpDouble(pi * 3 / 4, -pi / 4, _easeOutQuad(trailProgress));
        default: // 내려찍기
          trailAngle = _lerpDouble(-pi * 2 / 3, pi / 2, _easeOutCubic(trailProgress));
      }

      final alpha = (60 - i * 15).clamp(0, 255);

      canvas.save();
      canvas.translate(handleX, handleY);
      if (!_facingRight) canvas.scale(-1, 1);
      canvas.rotate(trailAngle);

      final bladePaint = Paint()
        ..color = trailColor.withAlpha(alpha)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        const Offset(0, 0),
        const Offset(0, -22),
        bladePaint,
      );

      canvas.restore();
    }
  }

  /// 이징: 빠른 시작 → 감속
  double _easeOutQuad(double t) => t * (2 - t);

  /// 이징: 더 강한 감속 (강타용)
  double _easeOutCubic(double t) => 1 - pow(1 - t, 3).toDouble();

  /// 선형 보간
  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
