/// Arcana: The Three Hearts - 플레이어 캐릭터
/// PRD 4.2 하트 시스템 기반 플레이어 구현
/// Visual Upgrade: 픽셀아트 스타일 캐릭터
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/constants.dart';
import '../../data/model/item.dart';
import '../../data/model/room.dart';
import '../effects/effects.dart';
import '../enemies/base_enemy.dart';
import '../enemies/dummy_enemy.dart';
import '../managers/audio_manager.dart';
import '../maps/room_component.dart';

/// 플레이어 방향
enum PlayerDirection { up, down, left, right, idle }

/// 아이템 획득 콜백 타입
typedef OnItemPickup = void Function(Item item);

/// 게임 오버 콜백 타입
typedef OnGameOver = void Function();

/// 문 진입 콜백 타입
typedef OnDoorEnter = void Function(DoorDirection direction);

/// NPC 상호작용 콜백 타입
typedef OnNpcInteract = void Function();

/// 스킬 사용 콜백 타입
typedef OnSkillUse = void Function(int slotIndex);

/// 데미지 가함 콜백 타입
typedef OnDamageDealt = void Function(double damage);

/// 데미지 받음 콜백 타입
typedef OnDamageTaken = void Function(double damage);

/// 메인 플레이어 캐릭터 클래스
class ArcanaPlayer extends PositionComponent
    with CollisionCallbacks, KeyboardHandler, HasGameRef {
  ArcanaPlayer({
    required Vector2 position,
    this.onItemPickup,
    this.onGameOver,
    this.onDoorEnter,
    this.onNpcInteract,
    this.onSkillUse,
    this.onDamageDealt,
    this.onDamageTaken,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
          // Y-소팅: 초기값, update에서 동적 갱신
          priority: 1000,
        );

  /// 아이템 획득 콜백
  final OnItemPickup? onItemPickup;

  /// 게임 오버 콜백
  final OnGameOver? onGameOver;

  /// 문 진입 콜백
  final OnDoorEnter? onDoorEnter;

  /// NPC 상호작용 콜백
  final OnNpcInteract? onNpcInteract;

  /// 스킬 사용 콜백
  final OnSkillUse? onSkillUse;

  /// 데미지 가함 콜백 (심장 게이지 충전용)
  final OnDamageDealt? onDamageDealt;

  /// 데미지 받음 콜백 (심장 게이지 충전용)
  final OnDamageTaken? onDamageTaken;

  /// 현재 남은 심장 개수 (PRD 4.2: 최대 3개)
  int currentHearts = HeartConstants.maxHearts;

  /// 최대 체력
  double maxHealth = 100;

  /// 현재 체력
  double health = 100;

  /// 이동 속도
  double speed = PhysicsConstants.baseSpeed;

  /// 기본 공격력
  double baseAttack = 20;

  /// 기본 방어력
  double baseDefense = 5;

  /// 공격력 보너스 (장비)
  int attackBonus = 0;

  /// 방어력 보너스 (장비)
  int defenseBonus = 0;

  /// 현재 방향
  PlayerDirection direction = PlayerDirection.down;

  /// 이동 방향 벡터 (조이스틱용)
  Vector2 _velocity = Vector2.zero();

  /// 키보드 이동 방향 벡터
  Vector2 _keyboardVelocity = Vector2.zero();

  /// 공격 쿨다운 타이머
  double _attackCooldown = 0;

  /// 공격 쿨다운 시간 (초)
  static const double attackCooldownTime = 0.4;

  /// 공격 중인지 여부
  bool _isAttacking = false;

  /// 공격 지속 시간
  double _attackDuration = 0;

  /// 피격 무적 시간
  double _invincibleTimer = 0;

  /// 사망 여부
  bool isDead = false;

  /// 입력 활성화 여부
  bool _inputEnabled = true;

  /// 걷기 애니메이션 타이머
  double _walkTimer = 0;

  /// 이동 중 여부
  bool get _isMoving =>
      !_velocity.isZero() || !_keyboardVelocity.isZero();

  /// 피격 플래시 효과
  final HitFlashEffect _hitFlash = HitFlashEffect();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 히트박스 설정 (충돌 감지용)
    add(
      RectangleHitbox(
        size: Vector2(24, 24),
        position: Vector2(4, 4),
      ),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // 문 트리거와 충돌 시
    if (other is DoorTrigger) {
      onDoorEnter?.call(other.direction);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) return;

    // 무적 시간 감소
    if (_invincibleTimer > 0) {
      _invincibleTimer -= dt;
    }

    // 공격 쿨다운 감소
    if (_attackCooldown > 0) {
      _attackCooldown -= dt;
    }

    // 공격 지속 시간 처리
    if (_isAttacking) {
      _attackDuration -= dt;
      if (_attackDuration <= 0) {
        _isAttacking = false;
      }
    }

    // 이동 처리 (조이스틱)
    if (!_velocity.isZero()) {
      position += _velocity * speed * dt;
      _velocity = Vector2.zero();
    }

    // 이동 처리 (키보드 - 연속 이동)
    if (!_keyboardVelocity.isZero()) {
      position += _keyboardVelocity * speed * dt;
    }

    // 걷기 애니메이션 업데이트
    if (_isMoving) {
      _walkTimer += dt * 10;
    } else {
      _walkTimer = 0;
    }

    // 피격 플래시 업데이트
    _hitFlash.update(dt);

    // 화면 흔들림 업데이트
    ScreenShakeManager.updateAll(dt);

    // Y-소팅: Y좌표 기반 렌더링 순서 (높은 Y = 앞에 렌더링)
    priority = 1000 + position.y.toInt();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isDead) return;

    // 무적 상태일 때 깜빡임
    if (_invincibleTimer > 0 && (_invincibleTimer * 10).toInt() % 2 == 0) {
      return;
    }

    // 걷기 애니메이션 오프셋
    final walkBob = _isMoving ? sin(_walkTimer) * 2 : 0.0;
    final legSwing = _isMoving ? sin(_walkTimer) * 0.3 : 0.0;

    // 그림자
    _drawShadow(canvas);

    // 픽셀아트 스타일 캐릭터 렌더링
    _drawPixelCharacter(canvas, walkBob, legSwing);

    // 피격 플래시 오버레이
    _hitFlash.render(canvas, Rect.fromLTWH(0, 0, size.x, size.y));

    // 체력바
    _drawHealthBar(canvas);
  }

  /// 그림자 그리기 (향상된 버전 - 그라디언트 적용)
  void _drawShadow(Canvas canvas) {
    final center = Offset(size.x / 2, size.y - 2);

    // 외곽 부드러운 그림자
    final outerShadowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(center: center, width: 28, height: 10));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 28, height: 10),
      outerShadowPaint,
    );

    // 내부 진한 그림자
    final innerShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 16, height: 5),
      innerShadowPaint,
    );
  }

  /// 픽셀아트 스타일 캐릭터 그리기 (향상된 버전)
  void _drawPixelCharacter(Canvas canvas, double walkBob, double legSwing) {
    final centerX = size.x / 2;
    final baseColor = _getPlayerColor();
    final baseDark = _darkenColor(baseColor, 0.3);
    final baseLight = _lightenColor(baseColor, 0.2);

    // 개선된 색상 팔레트
    const skinColor = Color(0xFFFFD5B8);
    const skinDark = Color(0xFFE5B89C);
    const skinLight = Color(0xFFFFF0E6);
    const hairColor = Color(0xFF4A3728);
    const hairDark = Color(0xFF2D2118);
    const hairLight = Color(0xFF6B5344);
    const outlineColor = Color(0xFF1A1A2E);

    // === 다리 (그라디언트 적용) ===
    final leftLegOffset = _isMoving ? legSwing * 4 : 0.0;
    final rightLegOffset = _isMoving ? -legSwing * 4 : 0.0;

    // 다리 외곽선
    final legOutlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 왼쪽 다리
    final leftLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 7, 22 + leftLegOffset - walkBob, 5, 10),
      const Radius.circular(1.5),
    );
    _drawGradientRRect(canvas, leftLegRect, baseDark, baseColor);
    canvas.drawRRect(leftLegRect, legOutlinePaint);

    // 오른쪽 다리
    final rightLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 2, 22 + rightLegOffset - walkBob, 5, 10),
      const Radius.circular(1.5),
    );
    _drawGradientRRect(canvas, rightLegRect, baseDark, baseColor);
    canvas.drawRRect(rightLegRect, legOutlinePaint);

    // 신발 디테일
    final shoePaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 8, 29 + leftLegOffset - walkBob, 6, 4),
        const Radius.circular(1),
      ),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 2, 29 + rightLegOffset - walkBob, 6, 4),
        const Radius.circular(1),
      ),
      shoePaint,
    );

    // === 몸통 (그라디언트 쉐이딩) ===
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 8, 12 - walkBob, 16, 14),
      const Radius.circular(3),
    );
    _drawGradientRRect(canvas, bodyRect, baseDark, baseLight);

    // 몸통 외곽선
    final bodyOutlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(bodyRect, bodyOutlinePaint);

    // 몸통 하이라이트 (림 라이팅 효과)
    final rimLightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 6, 13 - walkBob, 3, 10),
        const Radius.circular(1.5),
      ),
      rimLightPaint,
    );

    // 옷 디테일 - 벨트
    final beltPaint = Paint()
      ..color = const Color(0xFF5C4033)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(centerX - 7, 22 - walkBob, 14, 3),
      beltPaint,
    );
    // 벨트 버클
    final bucklePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(centerX - 2, 22.5 - walkBob, 4, 2),
      bucklePaint,
    );

    // === 팔 (그라디언트 + 외곽선) ===
    void drawArm(double x, double y, double swingOffset) {
      final armRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y + swingOffset, 5, 10),
        const Radius.circular(2.5),
      );
      // 팔 그라디언트
      _drawGradientRRect(canvas, armRect, skinDark, skinLight);
      // 팔 외곽선
      final armOutline = Paint()
        ..color = outlineColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(armRect, armOutline);
    }

    switch (direction) {
      case PlayerDirection.left:
        drawArm(centerX - 12, 14 - walkBob, legSwing * 2);
      case PlayerDirection.right:
        drawArm(centerX + 7, 14 - walkBob, legSwing * 2);
      default:
        drawArm(centerX - 12, 14 - walkBob, legSwing * 2);
        drawArm(centerX + 7, 14 - walkBob, -legSwing * 2);
    }

    // === 머리 (그라디언트 쉐이딩) ===
    final headCenter = Offset(centerX, 8 - walkBob);

    // 머리 베이스 (그라디언트)
    final headGradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.2,
        colors: [skinLight, skinColor, skinDark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(center: headCenter, width: 16, height: 16));
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 14, height: 14),
      headGradientPaint,
    );

    // 머리 외곽선
    final headOutlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 14, height: 14),
      headOutlinePaint,
    );

    // 볼 홍조 (귀여움 추가)
    final blushPaint = Paint()
      ..color = const Color(0xFFFFB5B5).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    if (direction != PlayerDirection.up) {
      // 왼쪽 볼
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX - 4, 10 - walkBob),
          width: 4,
          height: 2.5,
        ),
        blushPaint,
      );
      // 오른쪽 볼
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX + 4, 10 - walkBob),
          width: 4,
          height: 2.5,
        ),
        blushPaint,
      );
    }

    // === 머리카락 (레이어드 스타일) ===
    // 머리카락 베이스
    final hairBasePaint = Paint()
      ..color = hairColor
      ..style = PaintingStyle.fill;

    // 윗머리 (더 풍성하게)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, 5 - walkBob),
        width: 16,
        height: 12,
      ),
      pi,
      pi,
      true,
      hairBasePaint,
    );

    // 머리카락 하이라이트 (광택)
    final hairHighlightPaint = Paint()
      ..color = hairLight.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX - 2, 3 - walkBob),
        width: 6,
        height: 4,
      ),
      pi * 1.2,
      pi * 0.6,
      true,
      hairHighlightPaint,
    );

    // 머리카락 그림자
    final hairShadowPaint = Paint()
      ..color = hairDark
      ..style = PaintingStyle.fill;

    // 방향에 따른 앞머리 스타일
    switch (direction) {
      case PlayerDirection.left:
        // 왼쪽 볼 때 - 옆머리 스타일
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX - 8, 2 - walkBob, 5, 7),
            const Radius.circular(2),
          ),
          hairBasePaint,
        );
        // 사이드 하이라이트
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX - 7, 3 - walkBob, 2, 4),
            const Radius.circular(1),
          ),
          hairHighlightPaint,
        );
      case PlayerDirection.right:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX + 3, 2 - walkBob, 5, 7),
            const Radius.circular(2),
          ),
          hairBasePaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX + 4, 3 - walkBob, 2, 4),
            const Radius.circular(1),
          ),
          hairHighlightPaint,
        );
      default:
        // 앞머리 - 삼각형 스타일 (더 세련되게)
        final bangPath = Path()
          ..moveTo(centerX - 5, 1 - walkBob)
          ..lineTo(centerX, 6 - walkBob)
          ..lineTo(centerX + 5, 1 - walkBob)
          ..quadraticBezierTo(centerX, 0 - walkBob, centerX - 5, 1 - walkBob);
        canvas.drawPath(bangPath, hairBasePaint);

        // 앞머리 하이라이트
        canvas.drawCircle(
          Offset(centerX - 2, 2 - walkBob),
          1.5,
          hairHighlightPaint,
        );
    }

    // 머리카락 외곽선
    final hairOutlinePaint = Paint()
      ..color = hairDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, 5 - walkBob),
        width: 16,
        height: 12,
      ),
      pi,
      pi,
      false,
      hairOutlinePaint,
    );

    // === 눈 ===
    _drawEyes(canvas, centerX, walkBob);

    // === 망토/어깨 장식 (선택적) ===
    if (currentHearts == 3) {
      // 풀 하트 상태에서 어깨 장식 표시
      final capeGlowPaint = Paint()
        ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, 16 - walkBob),
          width: 20,
          height: 6,
        ),
        capeGlowPaint,
      );
    }
  }

  /// RRect에 그라디언트 적용
  void _drawGradientRRect(Canvas canvas, RRect rrect, Color darkColor, Color lightColor) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightColor, darkColor],
      ).createShader(rrect.outerRect);
    canvas.drawRRect(rrect, paint);
  }

  /// 색상 어둡게
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// 색상 밝게
  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// 눈 그리기 (방향에 따라) - 향상된 버전
  void _drawEyes(Canvas canvas, double centerX, double walkBob) {
    const eyeWhiteColor = Color(0xFFFFFAF0);
    const eyeOutlineColor = Color(0xFF2D2D2D);
    const pupilColor = Color(0xFF1A1A2E);
    const irisColor = Color(0xFF4A6FA5);  // 파란 눈
    const eyeHighlightColor = Colors.white;

    switch (direction) {
      case PlayerDirection.up:
        // 뒷모습이므로 눈 안 보임
        // 대신 머리카락 뒷면 디테일
        final backHairPaint = Paint()
          ..color = const Color(0xFF3D2D1F)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX - 5, 6 - walkBob, 10, 4),
            const Radius.circular(2),
          ),
          backHairPaint,
        );
        return;

      case PlayerDirection.down:
      case PlayerDirection.idle:
        // 앞을 볼 때 - 정면 눈
        for (final offsetX in [-3.0, 3.0]) {
          final eyeCenter = Offset(centerX + offsetX, 8 - walkBob);

          // 눈 흰자 (타원형)
          final eyeWhitePaint = Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 1.0,
              colors: [eyeWhiteColor, const Color(0xFFE8E4E0)],
            ).createShader(Rect.fromCenter(center: eyeCenter, width: 7, height: 6));
          canvas.drawOval(
            Rect.fromCenter(center: eyeCenter, width: 6, height: 5),
            eyeWhitePaint,
          );

          // 눈 외곽선
          final eyeOutlinePaint = Paint()
            ..color = eyeOutlineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;
          canvas.drawOval(
            Rect.fromCenter(center: eyeCenter, width: 6, height: 5),
            eyeOutlinePaint,
          );

          // 홍채
          final irisCenter = Offset(eyeCenter.dx, eyeCenter.dy + 0.5);
          final irisPaint = Paint()
            ..shader = RadialGradient(
              colors: [irisColor, const Color(0xFF2A4A6A)],
            ).createShader(Rect.fromCenter(center: irisCenter, width: 4, height: 4));
          canvas.drawCircle(irisCenter, 2, irisPaint);

          // 눈동자
          final pupilPaint = Paint()
            ..color = pupilColor
            ..style = PaintingStyle.fill;
          canvas.drawCircle(irisCenter, 1, pupilPaint);

          // 눈 하이라이트 (생기 표현)
          final highlightPaint = Paint()
            ..color = eyeHighlightColor.withValues(alpha: 0.9)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(eyeCenter.dx - 1, eyeCenter.dy - 1),
            1,
            highlightPaint,
          );
          // 작은 보조 하이라이트
          canvas.drawCircle(
            Offset(eyeCenter.dx + 0.5, eyeCenter.dy + 1),
            0.5,
            highlightPaint..color = eyeHighlightColor.withValues(alpha: 0.5),
          );
        }

        // 눈썹 (표정 추가)
        final eyebrowPaint = Paint()
          ..color = const Color(0xFF4A3728)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

        // 왼쪽 눈썹
        canvas.drawLine(
          Offset(centerX - 5, 4 - walkBob),
          Offset(centerX - 1, 4.5 - walkBob),
          eyebrowPaint,
        );
        // 오른쪽 눈썹
        canvas.drawLine(
          Offset(centerX + 1, 4.5 - walkBob),
          Offset(centerX + 5, 4 - walkBob),
          eyebrowPaint,
        );

      case PlayerDirection.left:
        // 왼쪽 볼 때 - 측면 눈
        final eyeCenter = Offset(centerX - 3, 8 - walkBob);

        // 눈 흰자 (좁은 타원)
        final eyeWhitePaint = Paint()..color = eyeWhiteColor;
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 5, height: 4.5),
          eyeWhitePaint,
        );

        // 외곽선
        final outlinePaint = Paint()
          ..color = eyeOutlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 5, height: 4.5),
          outlinePaint,
        );

        // 홍채 (왼쪽으로 치우침)
        final irisPaint = Paint()..color = irisColor;
        canvas.drawCircle(Offset(eyeCenter.dx - 0.8, eyeCenter.dy), 1.8, irisPaint);

        // 눈동자
        final pupilPaint = Paint()..color = pupilColor;
        canvas.drawCircle(Offset(eyeCenter.dx - 0.8, eyeCenter.dy), 0.8, pupilPaint);

        // 하이라이트
        final highlightPaint = Paint()..color = eyeHighlightColor;
        canvas.drawCircle(Offset(eyeCenter.dx - 1.5, eyeCenter.dy - 1), 0.8, highlightPaint);

        // 눈썹
        final eyebrowPaint = Paint()
          ..color = const Color(0xFF4A3728)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(centerX - 5, 4.5 - walkBob),
          Offset(centerX - 1, 5 - walkBob),
          eyebrowPaint,
        );

      case PlayerDirection.right:
        // 오른쪽 볼 때
        final eyeCenter = Offset(centerX + 3, 8 - walkBob);

        final eyeWhitePaint = Paint()..color = eyeWhiteColor;
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 5, height: 4.5),
          eyeWhitePaint,
        );

        final outlinePaint = Paint()
          ..color = eyeOutlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 5, height: 4.5),
          outlinePaint,
        );

        final irisPaint = Paint()..color = irisColor;
        canvas.drawCircle(Offset(eyeCenter.dx + 0.8, eyeCenter.dy), 1.8, irisPaint);

        final pupilPaint = Paint()..color = pupilColor;
        canvas.drawCircle(Offset(eyeCenter.dx + 0.8, eyeCenter.dy), 0.8, pupilPaint);

        final highlightPaint = Paint()..color = eyeHighlightColor;
        canvas.drawCircle(Offset(eyeCenter.dx + 0.5, eyeCenter.dy - 1), 0.8, highlightPaint);

        final eyebrowPaint = Paint()
          ..color = const Color(0xFF4A3728)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(centerX + 1, 5 - walkBob),
          Offset(centerX + 5, 4.5 - walkBob),
          eyebrowPaint,
        );
    }
  }

  /// 체력바 그리기
  void _drawHealthBar(Canvas canvas) {
    final healthRatio = health / maxHealth;

    // 배경
    canvas.drawRect(
      Rect.fromLTWH(0, -12, size.x, 4),
      Paint()..color = Colors.red.shade900,
    );

    // 현재 체력
    canvas.drawRect(
      Rect.fromLTWH(0, -12, size.x * healthRatio, 4),
      Paint()..color = Colors.green,
    );
  }

  /// 심장 개수에 따른 플레이어 색상
  Color _getPlayerColor() {
    switch (currentHearts) {
      case 3:
        return Colors.blue;
      case 2:
        return Colors.blue.shade700;
      case 1:
        return Colors.blue.shade900;
      default:
        return Colors.grey;
    }
  }


  /// 공격 방향에 따른 오프셋
  Vector2 _getAttackOffset() {
    switch (direction) {
      case PlayerDirection.up:
        return Vector2(0, -24);
      case PlayerDirection.down:
        return Vector2(0, 24);
      case PlayerDirection.left:
        return Vector2(-24, 0);
      case PlayerDirection.right:
        return Vector2(24, 0);
      case PlayerDirection.idle:
        return Vector2(0, 24);
    }
  }

  /// 조이스틱 입력으로 이동
  void moveByJoystick(Vector2 delta) {
    if (isDead || !_inputEnabled) return;
    _velocity = delta.normalized();
    _updateDirection(delta);
  }

  /// 입력 활성화/비활성화 설정
  void setInputEnabled(bool enabled) {
    _inputEnabled = enabled;
    if (!enabled) {
      _keyboardVelocity = Vector2.zero();
      _velocity = Vector2.zero();
    }
  }

  /// 방향 업데이트
  void _updateDirection(Vector2 delta) {
    if (delta.x.abs() > delta.y.abs()) {
      direction = delta.x > 0 ? PlayerDirection.right : PlayerDirection.left;
    } else {
      direction = delta.y > 0 ? PlayerDirection.down : PlayerDirection.up;
    }
  }

  /// 키보드 입력 처리
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isDead || !_inputEnabled) {
      _keyboardVelocity = Vector2.zero();
      return true;
    }

    _keyboardVelocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _keyboardVelocity.y = -1;
      direction = PlayerDirection.up;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _keyboardVelocity.y = 1;
      direction = PlayerDirection.down;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _keyboardVelocity.x = -1;
      direction = PlayerDirection.left;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _keyboardVelocity.x = 1;
      direction = PlayerDirection.right;
    }

    // 공격 (스페이스바)
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      attack();
    }

    // NPC 상호작용 (E키)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyE) {
      onNpcInteract?.call();
    }

    // 스킬 사용 (1, 2, 3, 4 키)
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        onSkillUse?.call(0);
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        onSkillUse?.call(1);
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        onSkillUse?.call(2);
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        onSkillUse?.call(3);
      }
    }

    // 대각선 이동 시 정규화
    if (!_keyboardVelocity.isZero()) {
      _keyboardVelocity = _keyboardVelocity.normalized();
    }

    return true;
  }

  /// 공격 수행
  void attack() {
    if (isDead) return;
    if (_attackCooldown > 0) return;

    _attackCooldown = attackCooldownTime;
    _isAttacking = true;
    _attackDuration = 0.15;

    // 공격 사운드 재생
    AudioManager.instance.playSfx(SoundEffect.playerAttack);

    // 슬래시 이펙트 생성
    final attackOffset = _getAttackOffset();
    gameRef.world.add(
      SlashEffect(
        position: position + attackOffset,
        direction: direction,
        color: Colors.cyan,
        effectSize: 45,
      ),
    );

    // 화면 약한 흔들림
    ScreenShakeManager.lightShake();

    // 공격 범위 내의 적에게 데미지
    _dealDamageToEnemies();
  }

  /// 적에게 데미지 전달
  void _dealDamageToEnemies() {
    final attackRect = _getAttackRect();
    final damage = _calculateDamage();
    double totalDamageDealt = 0;

    // BaseEnemy 타입의 모든 적
    gameRef.world.children.whereType<BaseEnemy>().forEach((enemy) {
      if (attackRect.overlaps(enemy.toRect())) {
        enemy.takeDamage(damage);
        totalDamageDealt += damage;
      }
    });

    // DummyEnemy (Phase 1 호환)
    gameRef.world.children.whereType<DummyEnemy>().forEach((enemy) {
      if (attackRect.overlaps(enemy.toRect())) {
        enemy.takeDamage(damage);
        totalDamageDealt += damage;
      }
    });

    // 데미지를 가했으면 콜백 호출 (심장 게이지 충전)
    if (totalDamageDealt > 0) {
      onDamageDealt?.call(totalDamageDealt);
    }
  }

  /// 공격 범위 사각형 계산
  Rect _getAttackRect() {
    final attackOffset = _getAttackOffset();
    return Rect.fromCenter(
      center: Offset(
        position.x + attackOffset.x,
        position.y + attackOffset.y,
      ),
      width: 40,
      height: 40,
    );
  }

  /// PRD 4.1 데미지 공식 적용
  double _calculateDamage() {
    final totalAttack = baseAttack + attackBonus;
    final random = Random();
    final randomMultiplier = CombatConstants.damageRandomMin +
        random.nextDouble() *
            (CombatConstants.damageRandomMax - CombatConstants.damageRandomMin);

    return totalAttack * randomMultiplier;
  }

  /// 데미지 받기
  void takeDamage(double damage) {
    if (isDead) return;
    if (_invincibleTimer > 0) return;

    // 방어력 적용
    final totalDefense = baseDefense + defenseBonus;
    final reduction = totalDefense * CombatConstants.defenseMultiplier;
    var actualDamage = damage - reduction;
    if (actualDamage < CombatConstants.minimumDamage) {
      actualDamage = CombatConstants.minimumDamage.toDouble();
    }

    health -= actualDamage;

    // 데미지 받음 콜백 (심장 게이지 충전)
    onDamageTaken?.call(actualDamage);

    // 무적 시간
    _invincibleTimer = 0.5;

    // 피격 사운드 재생
    AudioManager.instance.playSfx(SoundEffect.playerHit);

    // 피격 플래시 효과
    _hitFlash.trigger();

    // 화면 흔들림
    ScreenShakeManager.mediumShake();

    // 히트스톱
    _applyHitStop();

    // 체력 체크
    if (health <= 0) {
      health = 0;
      _loseHeart();
    }
  }

  /// 히트스톱 효과
  void _applyHitStop() {
    // 대화 중이거나 이미 일시정지 상태면 히트스톱 스킵
    if (gameRef is ArcanaGameInterface) {
      final game = gameRef as ArcanaGameInterface;
      if (game.isGamePaused) {
        return;
      }
    }

    gameRef.pauseEngine();
    Future.delayed(
      Duration(milliseconds: (UIConstants.hitStopDuration * 1000).toInt()),
      () {
        // 게임이 여전히 히트스톱으로 인해 일시정지된 경우에만 재개
        if (gameRef.paused) {
          // 대화나 메뉴로 인한 일시정지가 아닌 경우에만 재개
          if (gameRef is ArcanaGameInterface) {
            final currentGame = gameRef as ArcanaGameInterface;
            if (!currentGame.isGamePaused) {
              gameRef.resumeEngine();
            }
          } else {
            // 인터페이스 미구현 시 기본 동작
            gameRef.resumeEngine();
          }
        }
      },
    );
  }

  /// 심장 잃기
  void _loseHeart() {
    if (currentHearts > 0) {
      currentHearts--;
      _applyHeartPenalty();

      if (currentHearts > 0) {
        // 체력 부분 회복
        health = maxHealth * 0.5;
      } else {
        // 게임 오버
        _die();
      }
    }
  }

  /// PRD 4.2 심장 페널티 적용
  void _applyHeartPenalty() {
    switch (currentHearts) {
      case 2:
        speed = PhysicsConstants.baseSpeed *
            (1 - HeartConstants.bodyLostSpeedPenalty);
      case 1:
        // 시야 감소 효과 (추후 구현)
        break;
      case 0:
        break;
    }
  }

  /// 사망 처리
  void _die() {
    isDead = true;
    // 사망 사운드 재생
    AudioManager.instance.playSfx(SoundEffect.playerDeath);
    onGameOver?.call();
  }

  /// 아이템 획득
  void pickupItem(Item item) {
    // 아이템 획득 사운드 재생
    AudioManager.instance.playSfx(SoundEffect.itemPickup);
    onItemPickup?.call(item);
  }

  /// 체력 회복
  void heal(int amount) {
    health += amount;
    if (health > maxHealth) {
      health = maxHealth;
    }
  }

  /// 장비 스탯 업데이트
  void updateEquipmentStats({int? attack, int? defense}) {
    if (attack != null) attackBonus = attack;
    if (defense != null) defenseBonus = defense;
  }

  /// 플레이어 리셋 (재시작용)
  void reset(Vector2 newPosition) {
    position = newPosition;
    currentHearts = HeartConstants.maxHearts;
    health = maxHealth;
    speed = PhysicsConstants.baseSpeed;
    isDead = false;
    _invincibleTimer = 0;
    _attackCooldown = 0;
    _isAttacking = false;
    direction = PlayerDirection.down;
  }
}

/// ArcanaGame 상태 접근용 인터페이스
/// 순환 참조 방지를 위해 별도 정의
abstract class ArcanaGameInterface {
  bool get isGamePaused;
  bool get isInDialogue;

  /// 적 처치 알림 (방 클리어 카운트용)
  void notifyEnemyKilled();
}
