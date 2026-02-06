/// Arcana: The Three Hearts - 텔레그래프 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 텔레그래프 형태
enum TelegraphShape {
  circle,
  rectangle,
  arc,
  cone,
}

/// 텔레그래프 컴포넌트
/// 적의 공격 예고 영역을 표시합니다.
class TelegraphComponent extends PositionComponent {
  TelegraphComponent({
    required this.shape,
    required this.duration,
    this.radius = 50,
    this.width = 0,
    this.height = 0,
    this.angle = 90,
    this.direction = 0, // 라디안
    this.color = Colors.red,
    this.onComplete,
  }) : super(anchor: Anchor.center);

  final TelegraphShape shape;
  final double duration;
  final double radius;
  final double width;
  final double height;
  final double angle; // arc/cone 형태일 때 각도 (도)
  final double direction; // 방향 (라디안)
  final Color color;
  final void Function()? onComplete;

  double _elapsed = 0;
  bool _isComplete = false;

  /// 진행률 (0.0 ~ 1.0)
  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  /// 완료 여부
  bool get isComplete => _isComplete;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    if (_elapsed >= duration && !_isComplete) {
      _isComplete = true;
      onComplete?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 진행도에 따른 알파값
    final alpha = (50 + progress * 150).toInt();
    final fillColor = color.withAlpha(alpha);
    final borderColor = color.withAlpha((alpha + 50).clamp(0, 255));

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (shape) {
      case TelegraphShape.circle:
        _renderCircle(canvas, fillPaint, borderPaint);
      case TelegraphShape.rectangle:
        _renderRectangle(canvas, fillPaint, borderPaint);
      case TelegraphShape.arc:
        _renderArc(canvas, fillPaint, borderPaint);
      case TelegraphShape.cone:
        _renderCone(canvas, fillPaint, borderPaint);
    }

    // 경고 깜빡임 (완료 직전)
    if (progress > 0.7) {
      final flashAlpha = ((sin(_elapsed * 20) + 1) * 50).toInt();
      final flashPaint = Paint()
        ..color = Colors.white.withAlpha(flashAlpha)
        ..style = PaintingStyle.fill;

      switch (shape) {
        case TelegraphShape.circle:
          canvas.drawCircle(Offset.zero, radius * progress, flashPaint);
        case TelegraphShape.rectangle:
          final w = width > 0 ? width : radius * 2;
          final h = height > 0 ? height : radius;
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: w, height: h),
            flashPaint,
          );
        case TelegraphShape.arc:
        case TelegraphShape.cone:
          // 호/콘 형태는 깜빡임 생략
          break;
      }
    }
  }

  void _renderCircle(Canvas canvas, Paint fill, Paint border) {
    // 원형 텔레그래프 - 안에서 바깥으로 확장
    final currentRadius = radius * progress;
    canvas.drawCircle(Offset.zero, currentRadius, fill);
    canvas.drawCircle(Offset.zero, radius, border);
  }

  void _renderRectangle(Canvas canvas, Paint fill, Paint border) {
    final w = width > 0 ? width : radius * 2;
    final h = height > 0 ? height : radius;

    // 방향에 따라 회전
    canvas.save();
    canvas.rotate(direction);

    // 현재 진행 영역
    final rect = Rect.fromLTWH(0, -h / 2, w * progress, h);
    canvas.drawRect(rect, fill);

    // 최종 영역 외곽선
    final fullRect = Rect.fromLTWH(0, -h / 2, w, h);
    canvas.drawRect(fullRect, border);

    canvas.restore();
  }

  void _renderArc(Canvas canvas, Paint fill, Paint border) {
    final angleRad = angle * pi / 180;
    final startAngle = direction - angleRad / 2;

    // 호 영역
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // 채워진 호
    final sweepAngle = angleRad * progress;
    canvas.drawArc(
      rect,
      startAngle + (angleRad - sweepAngle) / 2,
      sweepAngle,
      true,
      fill,
    );

    // 외곽선
    canvas.drawArc(rect, startAngle, angleRad, true, border);
  }

  void _renderCone(Canvas canvas, Paint fill, Paint border) {
    final angleRad = angle * pi / 180;
    final halfAngle = angleRad / 2;

    // 콘 경로
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(
        cos(direction - halfAngle) * radius * progress,
        sin(direction - halfAngle) * radius * progress,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius * progress),
        direction - halfAngle,
        angleRad,
        false,
      )
      ..close();

    canvas.drawPath(path, fill);

    // 외곽선
    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(
        cos(direction - halfAngle) * radius,
        sin(direction - halfAngle) * radius,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        direction - halfAngle,
        angleRad,
        false,
      )
      ..close();

    canvas.drawPath(borderPath, border);
  }
}

/// 텔레그래프 팩토리
class TelegraphFactory {
  /// 원형 텔레그래프 생성
  static TelegraphComponent circle({
    required double radius,
    required double duration,
    Color color = Colors.red,
    void Function()? onComplete,
  }) {
    return TelegraphComponent(
      shape: TelegraphShape.circle,
      radius: radius,
      duration: duration,
      color: color,
      onComplete: onComplete,
    );
  }

  /// 사각형 텔레그래프 생성
  static TelegraphComponent rectangle({
    required double width,
    required double height,
    required double duration,
    required double direction,
    Color color = Colors.red,
    void Function()? onComplete,
  }) {
    return TelegraphComponent(
      shape: TelegraphShape.rectangle,
      width: width,
      height: height,
      duration: duration,
      direction: direction,
      color: color,
      onComplete: onComplete,
    );
  }

  /// 호 텔레그래프 생성
  static TelegraphComponent arc({
    required double radius,
    required double angle,
    required double duration,
    required double direction,
    Color color = Colors.red,
    void Function()? onComplete,
  }) {
    return TelegraphComponent(
      shape: TelegraphShape.arc,
      radius: radius,
      angle: angle,
      duration: duration,
      direction: direction,
      color: color,
      onComplete: onComplete,
    );
  }

  /// 콘 텔레그래프 생성
  static TelegraphComponent cone({
    required double radius,
    required double angle,
    required double duration,
    required double direction,
    Color color = Colors.red,
    void Function()? onComplete,
  }) {
    return TelegraphComponent(
      shape: TelegraphShape.cone,
      radius: radius,
      angle: angle,
      duration: duration,
      direction: direction,
      color: color,
      onComplete: onComplete,
    );
  }
}
