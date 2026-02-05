/// Arcana: The Three Hearts - 화면 이펙트
/// 화면 흔들림, 플래시, 슬로우모션 등
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 화면 흔들림 컴포넌트
class ScreenShake extends Component {
  ScreenShake({
    required this.intensity,
    required this.duration,
    this.frequency = 30.0,
  });

  /// 흔들림 강도 (픽셀)
  final double intensity;

  /// 지속 시간
  final double duration;

  /// 흔들림 빈도
  final double frequency;

  /// 경과 시간
  double _elapsed = 0;

  /// 현재 오프셋
  Vector2 _offset = Vector2.zero();

  /// 현재 오프셋 가져오기
  Vector2 get offset => _offset;

  /// 흔들림 진행도 (0~1)
  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  /// 완료 여부
  bool get isComplete => _elapsed >= duration;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    if (isComplete) {
      _offset = Vector2.zero();
      removeFromParent();
      return;
    }

    // 감쇠 효과 (시간이 지날수록 약해짐)
    final damping = 1.0 - progress;
    final currentIntensity = intensity * damping;

    // Perlin-like 노이즈 효과
    final random = Random();
    final time = _elapsed * frequency;

    _offset = Vector2(
      sin(time) * currentIntensity * (random.nextDouble() * 0.5 + 0.5),
      cos(time * 1.3) * currentIntensity * (random.nextDouble() * 0.5 + 0.5),
    );
  }
}

/// 화면 흔들림 관리자
class ScreenShakeManager {
  ScreenShakeManager._();

  static final List<ScreenShake> _shakes = [];

  /// 흔들림 추가
  static void addShake({
    required double intensity,
    required double duration,
    double frequency = 30.0,
  }) {
    _shakes.add(
      ScreenShake(
        intensity: intensity,
        duration: duration,
        frequency: frequency,
      ),
    );
  }

  /// 약한 흔들림 (기본 공격)
  static void lightShake() {
    addShake(intensity: 3.0, duration: 0.1);
  }

  /// 중간 흔들림 (강한 공격)
  static void mediumShake() {
    addShake(intensity: 6.0, duration: 0.15);
  }

  /// 강한 흔들림 (크리티컬/사망)
  static void heavyShake() {
    addShake(intensity: 10.0, duration: 0.25, frequency: 40.0);
  }

  /// 현재 총 오프셋 계산
  static Vector2 getTotalOffset() {
    // 완료된 흔들림 제거
    _shakes.removeWhere((shake) => shake.isComplete);

    if (_shakes.isEmpty) return Vector2.zero();

    // 모든 흔들림 합산
    var totalOffset = Vector2.zero();
    for (final shake in _shakes) {
      totalOffset += shake.offset;
    }

    return totalOffset;
  }

  /// 모든 흔들림 업데이트
  static void updateAll(double dt) {
    for (final shake in _shakes) {
      shake.update(dt);
    }
    _shakes.removeWhere((shake) => shake.isComplete);
  }

  /// 모든 흔들림 중지
  static void clear() {
    _shakes.clear();
  }
}

/// 화면 플래시 이펙트 컴포넌트
class ScreenFlash extends PositionComponent {
  ScreenFlash({
    required this.screenSize,
    this.color = Colors.white,
    this.duration = 0.1,
    this.maxAlpha = 0.5,
  }) : super(size: screenSize);

  final Vector2 screenSize;
  final Color color;
  final double duration;
  final double maxAlpha;
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

    // 빠르게 나타났다 사라지는 플래시
    final alpha = progress < 0.3
        ? (progress / 0.3) * maxAlpha
        : (1 - (progress - 0.3) / 0.7) * maxAlpha;

    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenSize.x, screenSize.y),
      paint,
    );
  }
}

/// 적 피격 시 흰색 플래시 효과 (컴포넌트에 적용)
class HitFlashEffect {
  HitFlashEffect({
    this.duration = 0.1,
    this.intensity = 0.8,
  });

  final double duration;
  final double intensity;
  double _timer = 0;

  bool get isActive => _timer > 0;

  /// 플래시 시작
  void trigger() {
    _timer = duration;
  }

  /// 업데이트
  void update(double dt) {
    if (_timer > 0) {
      _timer -= dt;
    }
  }

  /// 현재 플래시 알파값
  double get currentAlpha {
    if (!isActive) return 0;
    return (_timer / duration) * intensity;
  }

  /// 플래시 오버레이 그리기
  void render(Canvas canvas, Rect bounds) {
    if (!isActive) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: currentAlpha)
      ..style = PaintingStyle.fill;

    canvas.drawRect(bounds, paint);
  }
}

/// 슬로우모션 이펙트 (히트스톱 대체용)
class SlowMotionEffect {
  SlowMotionEffect._();

  static double _timeScale = 1.0;
  static double _targetScale = 1.0;
  static double _transitionSpeed = 10.0;

  /// 현재 시간 스케일
  static double get timeScale => _timeScale;

  /// 슬로우모션 시작
  static void startSlowMotion({
    double scale = 0.2,
    double duration = 0.1,
  }) {
    _targetScale = scale;
    // 일정 시간 후 복구
    Future.delayed(Duration(milliseconds: (duration * 1000).toInt()), () {
      _targetScale = 1.0;
    });
  }

  /// 업데이트
  static void update(double dt) {
    if (_timeScale != _targetScale) {
      final diff = _targetScale - _timeScale;
      _timeScale += diff * _transitionSpeed * dt;

      // 근접하면 맞춤
      if ((diff).abs() < 0.01) {
        _timeScale = _targetScale;
      }
    }
  }

  /// 리셋
  static void reset() {
    _timeScale = 1.0;
    _targetScale = 1.0;
  }
}
