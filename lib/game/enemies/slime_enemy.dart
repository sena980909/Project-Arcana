/// Arcana: The Three Hearts - 슬라임 적
/// Chapter 1 기본 몬스터
library;

import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/model/enemy_data.dart';
import '../effects/effects.dart';
import 'base_enemy.dart';

/// 슬라임 적 클래스 (향상된 그래픽)
class SlimeEnemy extends BaseEnemy {
  SlimeEnemy({required super.position})
      : super(
          data: Enemies.slime,
        );

  /// 통통 튀는 애니메이션용 타이머
  double _bounceTimer = 0;

  /// 반짝임 타이머
  double _shimmerTimer = 0;

  /// 슬라임 색상 팔레트
  static const _baseColor = Color(0xFF4ADE80);  // 밝은 초록
  static const _darkColor = Color(0xFF22C55E);  // 어두운 초록
  static const _lightColor = Color(0xFF86EFAC); // 하이라이트
  static const _coreColor = Color(0xFF166534);  // 핵심부

  @override
  void update(double dt) {
    super.update(dt);

    // 애니메이션 타이머
    _bounceTimer += dt * 3.5;
    _shimmerTimer += dt * 2;
  }

  @override
  void renderEnemy(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 튀는 효과 계산
    final bounceOffset = sin(_bounceTimer) * 2.5;
    final squishFactor = 1.0 + cos(_bounceTimer) * 0.12;
    final bodyHeight = 20 - bounceOffset.abs();
    final bodyWidth = 24 * squishFactor;

    // === 그림자 (그라디언트) ===
    final shadowCenter = Offset(centerX, size.y - 3);
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: shadowCenter,
        width: bodyWidth + 8,
        height: 10,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: shadowCenter, width: bodyWidth + 4, height: 8),
      shadowPaint,
    );

    // === 슬라임 몸체 (다층 그라디언트) ===
    final bodyCenter = Offset(centerX, centerY - bounceOffset);
    final slimeColor = _getSlimeColor();
    final slimeDark = _darkenColor(slimeColor, 0.2);
    final slimeLight = _lightenColor(slimeColor, 0.15);

    // 외곽 글로우
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          slimeColor.withValues(alpha: 0.3),
          slimeColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: bodyCenter,
        width: bodyWidth + 12,
        height: bodyHeight + 8,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: bodyCenter, width: bodyWidth + 8, height: bodyHeight + 4),
      glowPaint,
    );

    // 메인 몸체 (젤리 그라디언트)
    final bodyGradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.5),
        radius: 1.2,
        colors: [slimeLight, slimeColor, slimeDark, _coreColor],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCenter(
        center: bodyCenter,
        width: bodyWidth,
        height: bodyHeight,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: bodyCenter, width: bodyWidth, height: bodyHeight),
      bodyGradientPaint,
    );

    // 외곽선 (약간 어두운 테두리)
    final outlinePaint = Paint()
      ..color = slimeDark.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: bodyCenter, width: bodyWidth, height: bodyHeight),
      outlinePaint,
    );

    // === 내부 반투명 레이어 (젤리 질감) ===
    final innerGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.2, 0.3),
        radius: 0.8,
        colors: [
          slimeLight.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(bodyCenter.dx + 3, bodyCenter.dy + 2),
        width: bodyWidth * 0.6,
        height: bodyHeight * 0.5,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyCenter.dx + 3, bodyCenter.dy + 2),
        width: bodyWidth * 0.5,
        height: bodyHeight * 0.4,
      ),
      innerGlowPaint,
    );

    // === 메인 하이라이트 (반짝이는 효과) ===
    final shimmerIntensity = (sin(_shimmerTimer) + 1) / 2 * 0.3 + 0.5;
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: shimmerIntensity)
      ..style = PaintingStyle.fill;

    // 큰 하이라이트
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 5, centerY - 5 - bounceOffset),
        width: 7,
        height: 5,
      ),
      highlightPaint,
    );

    // 작은 하이라이트
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 2, centerY - 7 - bounceOffset),
        width: 3,
        height: 2,
      ),
      highlightPaint..color = Colors.white.withValues(alpha: shimmerIntensity * 0.8),
    );

    // === 눈 (더 표정있게) ===
    _drawEyes(canvas, bounceOffset, squishFactor);

    // === 입 (귀여운 표정) ===
    _drawMouth(canvas, bounceOffset);
  }

  /// 체력에 따른 슬라임 색상
  Color _getSlimeColor() {
    final healthRatio = health / data.maxHealth;

    if (healthRatio > 0.6) {
      return _baseColor;
    } else if (healthRatio > 0.3) {
      // 손상됨 - 약간 탁한 색
      return const Color(0xFF6EE7A0);
    } else {
      // 위험 상태 - 어둡고 불안정한 색
      return const Color(0xFF16A34A);
    }
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

  /// 눈 그리기 (향상된 버전)
  void _drawEyes(Canvas canvas, double bounceOffset, double squishFactor) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    final eyeY = centerY - 1 - bounceOffset;

    // 눈 간격 (스퀴시에 따라 조절)
    final eyeSpacing = 5.0 * squishFactor;

    for (final offsetX in [-eyeSpacing, eyeSpacing]) {
      final eyeCenter = Offset(centerX + offsetX, eyeY);

      // 눈 외곽 (약간 투명한 흰색)
      final eyeOuterPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 6, height: 5),
        eyeOuterPaint,
      );

      // 눈동자 (검은색, 약간 위를 봄)
      final pupilPaint = Paint()
        ..color = const Color(0xFF1A1A2E)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeCenter.dx, eyeCenter.dy - 0.5),
          width: 4,
          height: 4.5,
        ),
        pupilPaint,
      );

      // 눈 하이라이트 (생기)
      final highlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(eyeCenter.dx - 1.2, eyeCenter.dy - 1.2),
        1.2,
        highlightPaint,
      );
      // 보조 하이라이트
      canvas.drawCircle(
        Offset(eyeCenter.dx + 0.5, eyeCenter.dy + 0.5),
        0.5,
        highlightPaint,
      );
    }
  }

  /// 입 그리기 (귀여운 표정)
  void _drawMouth(Canvas canvas, double bounceOffset) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    final mouthY = centerY + 4 - bounceOffset;

    final mouthPaint = Paint()
      ..color = _coreColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 웃는 입
    final mouthPath = Path()
      ..moveTo(centerX - 3, mouthY)
      ..quadraticBezierTo(centerX, mouthY + 2.5, centerX + 3, mouthY);

    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  void spawnDeathEffect() {
    // 슬라임 특유의 액체 튀김 이펙트
    gameRef.world.add(
      ParticleFactory.createSlimeSplash(
        position: position,
        color: _baseColor,
        particleCount: 18,
      ),
    );
  }
}

/// 고블린 적 클래스 (향상된 그래픽)
class GoblinEnemy extends BaseEnemy {
  GoblinEnemy({required super.position})
      : super(
          data: Enemies.goblin,
        );

  /// 무기 휘두르기 타이머
  double _weaponTimer = 0;

  /// 숨쉬기 애니메이션 타이머
  double _breathTimer = 0;

  // 색상 팔레트
  static const _skinColor = Color(0xFF5D8A4A);    // 고블린 피부
  static const _skinDark = Color(0xFF3D5A2A);     // 어두운 피부
  static const _skinLight = Color(0xFF7DAA6A);    // 밝은 피부
  static const _clothColor = Color(0xFF8B6914);   // 옷 색상
  static const _clothDark = Color(0xFF5C4510);    // 어두운 옷
  static const _eyeColor = Color(0xFFDC2626);     // 빨간 눈

  @override
  void update(double dt) {
    super.update(dt);
    _weaponTimer += dt * 4;
    _breathTimer += dt * 2.5;
  }

  @override
  void renderEnemy(Canvas canvas) {
    final centerX = size.x / 2;
    final weaponSwing = sin(_weaponTimer) * 0.25;
    final breathOffset = sin(_breathTimer) * 0.8;

    // === 그림자 (그라디언트) ===
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(centerX, size.y - 1),
        width: 24,
        height: 10,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, size.y - 1), width: 20, height: 6),
      shadowPaint,
    );

    // === 무기 (뒤에 그림) ===
    _drawWeapon(canvas, centerX, weaponSwing);

    // === 다리 (그라디언트 + 외곽선) ===
    final legOutlinePaint = Paint()
      ..color = _clothDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final offsetX in [-6.0, 2.0]) {
      final legRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + offsetX, 24, 4, 8),
        const Radius.circular(1.5),
      );
      final legPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_clothColor, _clothDark],
        ).createShader(legRect.outerRect);
      canvas.drawRRect(legRect, legPaint);
      canvas.drawRRect(legRect, legOutlinePaint);

      // 신발
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(centerX + offsetX - 1, 30, 6, 3),
          const Radius.circular(1),
        ),
        Paint()..color = const Color(0xFF4A3728),
      );
    }

    // === 몸통 (그라디언트 쉐이딩) ===
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 8, 14 - breathOffset, 16, 12),
      const Radius.circular(3),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_clothColor, _clothDark],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // 몸통 외곽선
    canvas.drawRRect(bodyRect, Paint()
      ..color = _clothDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // 옷 디테일 - 가죽 밴드
    final bandPaint = Paint()..color = const Color(0xFF3D2D1F);
    canvas.drawRect(
      Rect.fromLTWH(centerX - 7, 16 - breathOffset, 14, 2),
      bandPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 7, 22 - breathOffset, 14, 2),
      bandPaint,
    );

    // === 팔 ===
    final armPaint = Paint()
      ..shader = LinearGradient(
        colors: [_skinLight, _skinDark],
      ).createShader(const Rect.fromLTWH(0, 0, 5, 8));

    // 왼팔
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 11, 15 - breathOffset, 4, 9),
        const Radius.circular(2),
      ),
      armPaint,
    );
    // 오른팔
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 7, 15 - breathOffset, 4, 9),
        const Radius.circular(2),
      ),
      armPaint,
    );

    // === 머리 (녹색 피부 그라디언트) ===
    final headCenter = Offset(centerX, 10 - breathOffset);
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.2,
        colors: [_skinLight, _skinColor, _skinDark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(center: headCenter, width: 16, height: 16));
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 14, height: 14),
      headPaint,
    );

    // 머리 외곽선
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 14, height: 14),
      Paint()
        ..color = _skinDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // === 뾰족한 귀 (그라디언트) ===
    _drawEars(canvas, centerX, breathOffset);

    // === 눈 (사악한 빨간 눈) ===
    _drawGoblinEyes(canvas, centerX, breathOffset);

    // === 코 ===
    final noseCenter = Offset(centerX, 12 - breathOffset);
    canvas.drawOval(
      Rect.fromCenter(center: noseCenter, width: 4, height: 3),
      Paint()..color = _skinDark,
    );
    // 콧구멍
    canvas.drawCircle(
      Offset(centerX - 1, 12.5 - breathOffset),
      0.8,
      Paint()..color = const Color(0xFF2D3A20),
    );
    canvas.drawCircle(
      Offset(centerX + 1, 12.5 - breathOffset),
      0.8,
      Paint()..color = const Color(0xFF2D3A20),
    );

    // === 입 (사악한 이빨 미소) ===
    _drawMouth(canvas, centerX, breathOffset);
  }

  /// 귀 그리기
  void _drawEars(Canvas canvas, double centerX, double breathOffset) {
    for (final side in [-1.0, 1.0]) {
      final earPath = Path();
      final baseX = centerX + side * 7;
      final tipX = centerX + side * 15;

      earPath.moveTo(baseX, 8 - breathOffset);
      earPath.lineTo(tipX, 1 - breathOffset);
      earPath.lineTo(baseX - side * 1, 5 - breathOffset);
      earPath.close();

      // 귀 그라디언트
      final earPaint = Paint()
        ..shader = LinearGradient(
          begin: side > 0 ? Alignment.centerLeft : Alignment.centerRight,
          end: side > 0 ? Alignment.centerRight : Alignment.centerLeft,
          colors: [_skinColor, _skinDark],
        ).createShader(earPath.getBounds());
      canvas.drawPath(earPath, earPaint);

      // 귀 외곽선
      canvas.drawPath(earPath, Paint()
        ..color = _skinDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);

      // 귀 내부
      final innerEarPath = Path();
      innerEarPath.moveTo(baseX + side * 1, 7 - breathOffset);
      innerEarPath.lineTo(tipX - side * 3, 3 - breathOffset);
      innerEarPath.lineTo(baseX, 6 - breathOffset);
      innerEarPath.close();
      canvas.drawPath(innerEarPath, Paint()
        ..color = const Color(0xFFE8B4B4).withValues(alpha: 0.5));
    }
  }

  /// 고블린 눈 그리기
  void _drawGoblinEyes(Canvas canvas, double centerX, double breathOffset) {
    for (final offsetX in [-3.5, 3.5]) {
      final eyeCenter = Offset(centerX + offsetX, 9 - breathOffset);

      // 노란 눈 흰자
      final eyeWhitePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFEF9C3),
            const Color(0xFFFDE047),
          ],
        ).createShader(Rect.fromCenter(center: eyeCenter, width: 6, height: 5));
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 5.5, height: 4.5),
        eyeWhitePaint,
      );

      // 눈 외곽선
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 5.5, height: 4.5),
        Paint()
          ..color = const Color(0xFF854D0E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // 빨간 눈동자 (세로로 긴 동공)
      final pupilPaint = Paint()
        ..shader = RadialGradient(
          colors: [_eyeColor, const Color(0xFF991B1B)],
        ).createShader(Rect.fromCenter(center: eyeCenter, width: 4, height: 4));
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 2.5, height: 3.5),
        pupilPaint,
      );

      // 세로 동공 (고양이 눈처럼)
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 1, height: 3),
        Paint()..color = Colors.black,
      );

      // 눈 하이라이트
      canvas.drawCircle(
        Offset(eyeCenter.dx - 1, eyeCenter.dy - 1),
        0.8,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  /// 입 그리기 (이빨)
  void _drawMouth(Canvas canvas, double centerX, double breathOffset) {
    final mouthY = 15.5 - breathOffset;

    // 입 배경 (어두운 구멍)
    final mouthPath = Path();
    mouthPath.moveTo(centerX - 5, mouthY);
    mouthPath.quadraticBezierTo(centerX, mouthY + 3, centerX + 5, mouthY);
    mouthPath.lineTo(centerX + 4, mouthY + 1);
    mouthPath.quadraticBezierTo(centerX, mouthY + 2, centerX - 4, mouthY + 1);
    mouthPath.close();

    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF1F2937));

    // 이빨
    final toothPaint = Paint()..color = const Color(0xFFFFFBEB);
    // 왼쪽 송곳니
    canvas.drawPath(
      Path()
        ..moveTo(centerX - 4, mouthY)
        ..lineTo(centerX - 3, mouthY + 2.5)
        ..lineTo(centerX - 2, mouthY)
        ..close(),
      toothPaint,
    );
    // 오른쪽 송곳니
    canvas.drawPath(
      Path()
        ..moveTo(centerX + 2, mouthY)
        ..lineTo(centerX + 3, mouthY + 2.5)
        ..lineTo(centerX + 4, mouthY)
        ..close(),
      toothPaint,
    );
  }

  /// 무기 그리기 (향상된 곤봉)
  void _drawWeapon(Canvas canvas, double centerX, double swing) {
    canvas.save();
    canvas.translate(centerX + 10, 18);
    canvas.rotate(swing - 0.5);

    // 곤봉 손잡이 (그라디언트)
    final handleRect = const Rect.fromLTWH(-2.5, -13, 5, 15);
    final handlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF5C4033), Color(0xFF3D2817), Color(0xFF5C4033)],
      ).createShader(handleRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(1.5)),
      handlePaint,
    );

    // 손잡이 감긴 가죽
    final leatherPaint = Paint()
      ..color = const Color(0xFF2D1F14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(-2, -10 + i * 3.5),
        Offset(2, -11 + i * 3.5),
        leatherPaint,
      );
    }

    // 곤봉 머리 (금속 그라디언트)
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [Color(0xFF9CA3AF), Color(0xFF4B5563), Color(0xFF1F2937)],
      ).createShader(const Rect.fromLTWH(-5, -22, 10, 12));
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, -15),
        width: 10,
        height: 12,
      ),
      headPaint,
    );

    // 곤봉 외곽선
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, -15),
        width: 10,
        height: 12,
      ),
      Paint()
        ..color = const Color(0xFF374151)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // 스파이크 (날카롭게)
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * pi * 2 - pi / 2;
      final baseX = cos(angle) * 5;
      final baseY = -15 + sin(angle) * 6;
      final tipX = cos(angle) * 9;
      final tipY = -15 + sin(angle) * 10;

      final spikePath = Path()
        ..moveTo(baseX - cos(angle + pi / 2) * 2, baseY - sin(angle + pi / 2) * 2)
        ..lineTo(tipX, tipY)
        ..lineTo(baseX + cos(angle + pi / 2) * 2, baseY + sin(angle + pi / 2) * 2)
        ..close();

      canvas.drawPath(spikePath, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFD1D5DB), const Color(0xFF6B7280)],
        ).createShader(spikePath.getBounds()));

      // 스파이크 하이라이트
      canvas.drawCircle(
        Offset(baseX + cos(angle) * 2, baseY + sin(angle) * 2),
        1,
        Paint()..color = Colors.white.withValues(alpha: 0.4),
      );
    }

    canvas.restore();
  }

  @override
  void spawnDeathEffect() {
    // 고블린 사망 시 연기/먼지 이펙트
    gameRef.world.add(
      ParticleFactory.createSmokeEffect(
        position: position,
        color: Colors.brown.shade400,
        particleCount: 14,
      ),
    );

    // 추가 폭발 이펙트
    gameRef.world.add(
      ParticleFactory.createExplosion(
        position: position,
        color: Colors.green.shade600,
        particleCount: 10,
        speed: 60,
      ),
    );
  }
}
