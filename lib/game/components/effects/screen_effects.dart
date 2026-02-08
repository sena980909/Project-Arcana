/// Arcana: The Three Hearts - 화면 효과
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 화면 효과 관리자
class ScreenEffects {
  ScreenEffects._();
  static final ScreenEffects instance = ScreenEffects._();

  // 화면 흔들림
  Vector2 _shakeOffset = Vector2.zero();
  double _shakeIntensity = 0;
  double _shakeDuration = 0;
  double _shakeTimer = 0;

  // 히트스톱
  double _hitStopDuration = 0;
  double _hitStopTimer = 0;
  bool _isHitStopped = false;

  // 플래시
  Color? _flashColor;
  double _flashDuration = 0;
  double _flashTimer = 0;

  /// 업데이트
  void update(double dt) {
    // 화면 흔들림 업데이트
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final progress = _shakeTimer / _shakeDuration;
      final currentIntensity = _shakeIntensity * progress;
      _shakeOffset = Vector2(
        (Random().nextDouble() - 0.5) * 2 * currentIntensity,
        (Random().nextDouble() - 0.5) * 2 * currentIntensity,
      );
      if (_shakeTimer <= 0) {
        _shakeOffset = Vector2.zero();
      }
    }

    // 히트스톱 업데이트
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
      if (_hitStopTimer <= 0) {
        _isHitStopped = false;
      }
    }

    // 플래시 업데이트
    if (_flashTimer > 0) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _flashColor = null;
      }
    }
  }

  /// 화면 흔들림 시작
  void shake({double intensity = 5, double duration = 0.2}) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
    _shakeTimer = duration;
  }

  /// 히트스톱 시작
  void hitStop({double duration = 0.05}) {
    _hitStopDuration = duration;
    _hitStopTimer = duration;
    _isHitStopped = true;
  }

  /// 플래시 효과 시작
  void flash({Color color = Colors.white, double duration = 0.1}) {
    _flashColor = color;
    _flashDuration = duration;
    _flashTimer = duration;
  }

  /// 피격 효과 (흔들림 + 플래시)
  void onPlayerHit() {
    shake(intensity: 8, duration: 0.15);
    flash(color: Colors.red.withAlpha(100), duration: 0.1);
  }

  /// 강공격 효과 (히트스톱 + 흔들림)
  void onHeavyAttack() {
    hitStop(duration: 0.05);
    shake(intensity: 3, duration: 0.1);
  }

  /// 완벽 회피 효과
  void onPerfectDodge() {
    flash(color: Colors.cyan.withAlpha(150), duration: 0.2);
  }

  /// 궁극기 효과
  void onUltimate() {
    shake(intensity: 10, duration: 0.3);
    flash(color: Colors.yellow.withAlpha(100), duration: 0.3);
    hitStop(duration: 0.1);
  }

  /// 현재 오프셋
  Vector2 get shakeOffset => _shakeOffset;

  /// 히트스톱 중인지
  bool get isHitStopped => _isHitStopped;

  /// 플래시 색상 (null이면 플래시 없음)
  Color? get flashColor => _flashColor;

  /// 플래시 알파값
  double get flashAlpha {
    if (_flashColor == null || _flashDuration == 0) return 0;
    return (_flashTimer / _flashDuration).clamp(0.0, 1.0);
  }

  /// 시간 스케일 (히트스톱 중이면 0)
  double get timeScale => _isHitStopped ? 0 : 1;
}

/// 데미지 숫자 컴포넌트
class DamageNumberComponent extends PositionComponent {
  DamageNumberComponent({
    required Vector2 position,
    required this.damage,
    this.isCritical = false,
    this.color,
  }) : super(position: position, anchor: Anchor.center);

  final double damage;
  final bool isCritical;
  final Color? color;

  double _elapsed = 0;
  static const double _duration = 1.0;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= _duration) {
      removeFromParent();
      return;
    }

    // 위로 떠오르기
    position.y -= 50 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    final alpha = ((1 - progress) * 255).toInt();
    final scale = 1.0 + (isCritical ? 0.3 : 0) - progress * 0.3;

    final textColor = color ?? (isCritical ? Colors.yellow : Colors.white);

    final textPainter = TextPainter(
      text: TextSpan(
        text: damage.toInt().toString(),
        style: TextStyle(
          color: textColor.withAlpha(alpha),
          fontSize: (isCritical ? 20 : 16) * scale,
          fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(alpha),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}

/// 이펙트 생성 헬퍼
class EffectFactory {
  /// 데미지 숫자 생성
  static DamageNumberComponent createDamageNumber({
    required Vector2 position,
    required double damage,
    bool isCritical = false,
    Color? color,
  }) {
    // 약간의 랜덤 오프셋
    final offset = Vector2(
      (Random().nextDouble() - 0.5) * 20,
      (Random().nextDouble() - 0.5) * 10,
    );

    return DamageNumberComponent(
      position: position + offset,
      damage: damage,
      isCritical: isCritical,
      color: color,
    );
  }

  /// 회복 숫자 생성 (초록색)
  static DamageNumberComponent createHealNumber({
    required Vector2 position,
    required double amount,
  }) {
    return DamageNumberComponent(
      position: position,
      damage: amount,
      color: Colors.green,
    );
  }

  /// 마나 회복 숫자 생성 (파란색)
  static DamageNumberComponent createManaNumber({
    required Vector2 position,
    required double amount,
  }) {
    return DamageNumberComponent(
      position: position,
      damage: amount,
      color: Colors.blue,
    );
  }
}

/// 스테이지 클리어 알림 컴포넌트
class StageClearComponent extends PositionComponent {
  StageClearComponent({required this.followTarget});

  final PositionComponent followTarget;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position = followTarget.position + Vector2(0, -50);
  }

  @override
  void render(Canvas canvas) {
    final fadeIn = (_elapsed / 0.3).clamp(0.0, 1.0);
    final alpha = (fadeIn * 255).toInt();
    final bounce = 1.0 + (1 - fadeIn) * 0.4;

    canvas.save();
    canvas.scale(bounce, bounce);

    // "STAGE CLEAR!" 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'STAGE CLEAR!',
        style: TextStyle(
          color: Colors.yellow.withAlpha(alpha),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(alpha),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
            Shadow(
              color: Colors.orange.withAlpha((alpha * 0.5).toInt()),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}

/// 게임 오버 컴포넌트
class GameOverComponent extends PositionComponent {
  GameOverComponent({required this.followTarget});

  final PositionComponent followTarget;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position = followTarget.position;
  }

  @override
  void render(Canvas canvas) {
    final fadeIn = (_elapsed / 0.5).clamp(0.0, 1.0);
    final alpha = (fadeIn * 255).toInt();

    // 어두운 배경
    final bgPaint = Paint()
      ..color = Colors.black.withAlpha((alpha * 0.6).toInt());
    canvas.drawRect(
      const Rect.fromLTWH(-200, -150, 400, 300),
      bgPaint,
    );

    // "GAME OVER" 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'GAME OVER',
        style: TextStyle(
          color: Colors.red.withAlpha(alpha),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(alpha),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 - 10),
    );

    // 안내 텍스트
    if (_elapsed > 1.5) {
      final subAlpha = ((_elapsed - 1.5) / 0.5).clamp(0.0, 1.0);
      final subPainter = TextPainter(
        text: TextSpan(
          text: 'Press R to restart',
          style: TextStyle(
            color: Colors.white.withAlpha((subAlpha * 200).toInt()),
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      subPainter.layout();
      subPainter.paint(
        canvas,
        Offset(-subPainter.width / 2, 10),
      );
    }
  }
}

/// 화면 플래시 오버레이 위젯
class ScreenFlashOverlay extends StatelessWidget {
  const ScreenFlashOverlay({
    required this.color,
    required this.alpha,
    super.key,
  });

  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    if (alpha <= 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: Container(
        color: color.withAlpha((alpha * color.alpha).toInt()),
      ),
    );
  }
}
