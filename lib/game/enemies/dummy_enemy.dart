/// Arcana: The Three Hearts - 허수아비 적
/// PRD Phase 1: "때리면 흔들리고 데미지 숫자 뜨는" 테스트용 적
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../characters/player.dart';

/// 허수아비 적 클래스
class DummyEnemy extends PositionComponent with CollisionCallbacks, HasGameRef {
  DummyEnemy({required Vector2 position})
      : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
          // Y-소팅: 초기값
          priority: 1000,
        );

  /// 최대 체력
  double maxLife = 100;

  /// 현재 체력
  double life = 100;

  /// 흔들림 효과 타이머
  double _shakeTimer = 0;

  /// 흔들림 강도
  double _shakeIntensity = 0;

  /// 원래 위치 (흔들림 복귀용)
  Vector2? _originalPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 히트박스 설정
    add(
      RectangleHitbox(
        size: Vector2(28, 28),
        position: Vector2(2, 2),
      ),
    );

    _originalPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 흔들림 효과 업데이트
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      _applyShakeEffect();
    } else if (_originalPosition != null && _shakeIntensity > 0) {
      position = _originalPosition!.clone();
      _shakeIntensity = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centerX = size.x / 2;

    // 색상 팔레트
    final baseColor = _getHealthColor();
    final darkColor = _darkenColor(baseColor, 0.2);
    final lightColor = _lightenColor(baseColor, 0.15);

    // === 그림자 ===
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(centerX, size.y - 1),
        width: 28,
        height: 10,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, size.y - 1), width: 22, height: 6),
      shadowPaint,
    );

    // === 지지대 (십자가 모양) ===
    // 세로 지지대
    final polePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [darkColor, lightColor, darkColor],
      ).createShader(Rect.fromLTWH(centerX - 3, 10, 6, 22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 3, 10, 6, 22),
        const Radius.circular(1),
      ),
      polePaint,
    );

    // === 팔 (가로 막대) ===
    final armRect = Rect.fromLTWH(2, 14, size.x - 4, 5);
    final armPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightColor, baseColor, darkColor],
      ).createShader(armRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(armRect, const Radius.circular(2)),
      armPaint,
    );

    // 팔 끝 장식
    for (final x in [4.0, size.x - 6]) {
      canvas.drawCircle(
        Offset(x, 16.5),
        3,
        Paint()..color = darkColor,
      );
    }

    // === 머리 (자루 포대) ===
    final headCenter = Offset(centerX, 6);
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [
          const Color(0xFFD2B48C),  // 베이지
          const Color(0xFFC4A86A),  // 어두운 베이지
          const Color(0xFF8B7355),  // 갈색
        ],
      ).createShader(Rect.fromCircle(center: headCenter, radius: 10));
    canvas.drawCircle(headCenter, 9, headPaint);

    // 머리 외곽선
    canvas.drawCircle(
      headCenter,
      9,
      Paint()
        ..color = const Color(0xFF5D4E37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 자루 매듭
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 4, 1), width: 4, height: 3),
      Paint()..color = const Color(0xFF8B7355),
    );

    // === 얼굴 (X 표시 눈과 바느질 입) ===
    final facePaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // X 눈 (왼쪽)
    canvas.drawLine(Offset(centerX - 5, 4), Offset(centerX - 2, 7), facePaint);
    canvas.drawLine(Offset(centerX - 5, 7), Offset(centerX - 2, 4), facePaint);

    // X 눈 (오른쪽)
    canvas.drawLine(Offset(centerX + 2, 4), Offset(centerX + 5, 7), facePaint);
    canvas.drawLine(Offset(centerX + 2, 7), Offset(centerX + 5, 4), facePaint);

    // 바느질 입
    final mouthPath = Path()
      ..moveTo(centerX - 4, 10)
      ..lineTo(centerX - 2, 11)
      ..lineTo(centerX, 10)
      ..lineTo(centerX + 2, 11)
      ..lineTo(centerX + 4, 10);
    canvas.drawPath(mouthPath, facePaint..strokeWidth = 1);

    // === 짚 장식 ===
    final strawPaint = Paint()
      ..color = const Color(0xFFDAA520)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 목에서 나오는 짚
    for (int i = 0; i < 5; i++) {
      final startX = centerX - 4 + i * 2.0;
      final endX = startX + (i - 2) * 1.5;
      canvas.drawLine(
        Offset(startX, 12),
        Offset(endX, 14 + (i % 2) * 2),
        strawPaint,
      );
    }

    // 팔 끝에서 나오는 짚
    for (final baseX in [0.0, size.x - 2]) {
      for (int i = 0; i < 3; i++) {
        canvas.drawLine(
          Offset(baseX + (baseX == 0 ? 2 : 0), 16),
          Offset(baseX + (baseX == 0 ? -2 : 4) + i * 1.5, 20.0 + i),
          strawPaint,
        );
      }
    }

    // === 체력바 표시 ===
    _drawHealthBar(canvas);
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

  /// 체력에 따른 색상 변화
  Color _getHealthColor() {
    final healthRatio = life / maxLife;
    if (healthRatio > 0.6) {
      return const Color(0xFF8B4513);  // 건강한 나무색
    } else if (healthRatio > 0.3) {
      return const Color(0xFFCD853F);  // 손상된 나무색
    } else {
      return const Color(0xFFD2691E);  // 위험 상태
    }
  }

  /// 체력바 그리기 (향상된)
  void _drawHealthBar(Canvas canvas) {
    final healthRatio = (life / maxLife).clamp(0.0, 1.0);
    final barWidth = size.x - 4;

    // 배경
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, -10, barWidth, 5),
      const Radius.circular(2),
    );
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xFF3D0000));

    // 체력 바
    if (healthRatio > 0) {
      final fgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, -10, barWidth * healthRatio, 5),
        const Radius.circular(2),
      );
      final fgPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4ADE80),
            const Color(0xFF22C55E),
          ],
        ).createShader(fgRect.outerRect);
      canvas.drawRRect(fgRect, fgPaint);
    }

    // 외곽선
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  /// 데미지 받기
  void takeDamage(double damage) {
    // PRD 4.1 데미지 공식 적용
    final actualDamage = _calculateActualDamage(damage);

    life -= actualDamage;

    // 데미지 숫자 표시
    _showDamageText(actualDamage);

    // 흔들림 효과
    _startShakeEffect();

    // 히트스톱 효과
    _applyHitStop();

    // 사망 처리
    if (life <= 0) {
      removeFromParent();
    }
  }

  /// PRD 4.1 데미지 공식: DEF * 0.5 만큼 감소
  double _calculateActualDamage(double rawDamage) {
    const double defense = 5.0;
    final reduction = defense * CombatConstants.defenseMultiplier;
    final actualDamage = rawDamage - reduction;

    return actualDamage < CombatConstants.minimumDamage
        ? CombatConstants.minimumDamage.toDouble()
        : actualDamage;
  }

  /// 데미지 숫자 팝업 표시
  void _showDamageText(double damage) {
    final damageText = DamageTextComponent(
      text: damage.toInt().toString(),
      position: Vector2(0, -20),
    );
    add(damageText);
  }

  /// 흔들림 효과 시작
  void _startShakeEffect() {
    _shakeTimer = 0.2;
    _shakeIntensity = 4.0;
    _originalPosition ??= position.clone();
  }

  /// 흔들림 효과 적용
  void _applyShakeEffect() {
    if (_originalPosition == null) return;

    final random = Random();
    final offsetX = (random.nextDouble() - 0.5) * 2 * _shakeIntensity;
    final offsetY = (random.nextDouble() - 0.5) * 2 * _shakeIntensity;

    position = _originalPosition! + Vector2(offsetX, offsetY);
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
        if (gameRef.paused) {
          // 대화나 메뉴로 인한 일시정지가 아닌 경우에만 재개
          if (gameRef is ArcanaGameInterface) {
            final currentGame = gameRef as ArcanaGameInterface;
            if (!currentGame.isGamePaused) {
              gameRef.resumeEngine();
            }
          } else {
            gameRef.resumeEngine();
          }
        }
      },
    );
  }
}

/// 데미지 텍스트 컴포넌트
class DamageTextComponent extends PositionComponent {
  DamageTextComponent({
    required this.text,
    required Vector2 position,
  }) : super(position: position);

  final String text;
  double _elapsed = 0;
  final double duration = UIConstants.damageNumberDuration;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    final progress = _elapsed / duration;

    if (progress >= 1.0) {
      removeFromParent();
      return;
    }

    // 위로 떠오르는 효과
    position.y -= 30 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = _elapsed / duration;
    final opacity = 1.0 - progress;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.yellow.withValues(alpha: opacity),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: opacity),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
  }
}
