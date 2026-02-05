/// Arcana: The Three Hearts - 슬래시 공격 이펙트
/// 검기/베기 시각 효과
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../characters/player.dart';

/// 슬래시 이펙트 컴포넌트
class SlashEffect extends PositionComponent {
  SlashEffect({
    required Vector2 position,
    required this.direction,
    this.color = Colors.white,
    this.effectSize = 40.0,
    this.duration = 0.15,
  }) : super(position: position, anchor: Anchor.center);

  /// 공격 방향
  final PlayerDirection direction;

  /// 슬래시 색상
  final Color color;

  /// 슬래시 크기
  final double effectSize;

  /// 지속 시간
  final double duration;

  /// 경과 시간
  double _elapsed = 0;

  /// 시작 각도
  double _startAngle = 0;

  /// 스윙 진행도 (0~1)
  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 방향에 따른 시작 각도 설정
    switch (direction) {
      case PlayerDirection.up:
        _startAngle = -pi * 0.75;
      case PlayerDirection.down:
        _startAngle = pi * 0.25;
      case PlayerDirection.left:
        _startAngle = pi * 0.75;
      case PlayerDirection.right:
        _startAngle = -pi * 0.25;
      case PlayerDirection.idle:
        _startAngle = pi * 0.25;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 페이드 아웃 알파
    final alpha = 1.0 - progress;

    // 스윙 각도 (시작 → 끝으로 휘두름)
    final sweepAngle = pi * 0.5 * progress;
    final currentAngle = _startAngle + sweepAngle;

    // 슬래시 호 그리기
    _drawSlashArc(canvas, currentAngle, alpha);

    // 추가 잔상 효과
    if (progress < 0.5) {
      _drawTrailEffect(canvas, currentAngle, alpha);
    }
  }

  /// 메인 슬래시 호 그리기
  void _drawSlashArc(Canvas canvas, double angle, double alpha) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * (1 - progress * 0.5)
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // 슬래시 궤적 (부채꼴 형태)
    final sweepAngle = pi * 0.4;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: effectSize * (0.8 + progress * 0.4),
      height: effectSize * (0.8 + progress * 0.4),
    );

    path.addArc(rect, angle - sweepAngle / 2, sweepAngle);

    canvas.drawPath(path, paint);

    // 내부 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final innerRect = Rect.fromCenter(
      center: Offset.zero,
      width: effectSize * 0.7,
      height: effectSize * 0.7,
    );

    final innerPath = Path();
    innerPath.addArc(innerRect, angle - sweepAngle / 3, sweepAngle * 0.6);
    canvas.drawPath(innerPath, highlightPaint);
  }

  /// 잔상 효과 그리기
  void _drawTrailEffect(Canvas canvas, double angle, double alpha) {
    // 여러 레이어의 잔상
    for (int i = 1; i <= 3; i++) {
      final trailAlpha = alpha * 0.3 * (1 - i / 4);
      final trailAngle = angle - (pi * 0.1 * i * progress);

      final trailPaint = Paint()
        ..color = color.withValues(alpha: trailAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4 - i).toDouble()
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: effectSize * (0.7 + i * 0.1),
        height: effectSize * (0.7 + i * 0.1),
      );

      final path = Path();
      path.addArc(rect, trailAngle, pi * 0.3);
      canvas.drawPath(path, trailPaint);
    }
  }
}

/// 임팩트 이펙트 (충돌 시 발생)
class ImpactEffect extends PositionComponent {
  ImpactEffect({
    required Vector2 position,
    this.color = Colors.yellow,
    this.effectSize = 30.0,
    this.duration = 0.2,
  }) : super(position: position, anchor: Anchor.center);

  final Color color;
  final double effectSize;
  final double duration;
  double _elapsed = 0;

  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final alpha = 1.0 - progress;
    final currentSize = effectSize * (0.5 + progress * 0.5);

    // 외곽 링
    final ringPaint = Paint()
      ..color = color.withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - progress);

    canvas.drawCircle(Offset.zero, currentSize, ringPaint);

    // 내부 플래시
    if (progress < 0.3) {
      final flashAlpha = (1 - progress / 0.3) * 0.8;
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: flashAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset.zero, currentSize * 0.5, flashPaint);
    }

    // 스파크 라인
    _drawSparkLines(canvas, alpha, currentSize);
  }

  /// 스파크 라인 그리기
  void _drawSparkLines(Canvas canvas, double alpha, double currentSize) {
    final sparkPaint = Paint()
      ..color = color.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * (1 - progress)
      ..strokeCap = StrokeCap.round;

    const sparkCount = 8;
    for (int i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * pi * 2;
      final innerRadius = currentSize * 0.3;
      final outerRadius = currentSize * (0.8 + progress * 0.3);

      final startX = cos(angle) * innerRadius;
      final startY = sin(angle) * innerRadius;
      final endX = cos(angle) * outerRadius;
      final endY = sin(angle) * outerRadius;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        sparkPaint,
      );
    }
  }
}
