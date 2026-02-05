/// Arcana: The Three Hearts - 파티클 시스템
/// 폭발, 피격, 사망 등 다양한 이펙트 구현
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 개별 파티클 클래스
class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
    this.gravity = 0,
    this.fadeOut = true,
    this.shrink = true,
  }) : maxLifetime = lifetime;

  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double lifetime;
  double maxLifetime;
  double gravity;
  bool fadeOut;
  bool shrink;

  double get progress => 1 - (lifetime / maxLifetime);
  bool get isDead => lifetime <= 0;

  void update(double dt) {
    // 위치 업데이트
    position += velocity * dt;

    // 중력 적용
    velocity.y += gravity * dt;

    // 수명 감소
    lifetime -= dt;
  }

  double get currentAlpha => fadeOut ? (lifetime / maxLifetime) : 1.0;
  double get currentSize => shrink ? size * (lifetime / maxLifetime) : size;
}

/// 파티클 이펙트 컴포넌트
class ParticleEffect extends PositionComponent {
  ParticleEffect({
    required Vector2 position,
    required this.particles,
    this.removeWhenEmpty = true,
  }) : super(position: position);

  final List<Particle> particles;
  final bool removeWhenEmpty;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 파티클 업데이트
    for (final particle in particles) {
      particle.update(dt);
    }

    // 죽은 파티클 제거
    particles.removeWhere((p) => p.isDead);

    // 모든 파티클 사라지면 컴포넌트 제거
    if (removeWhenEmpty && particles.isEmpty) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.currentAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.currentSize,
        paint,
      );
    }
  }
}

/// 파티클 이펙트 생성 팩토리
class ParticleFactory {
  static final Random _random = Random();

  /// 폭발 이펙트 (적 사망 시)
  static ParticleEffect createExplosion({
    required Vector2 position,
    required Color color,
    int particleCount = 20,
    double speed = 100,
    double lifetime = 0.5,
  }) {
    final particles = <Particle>[];

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speedVariation = speed * (0.5 + _random.nextDouble() * 0.5);

      particles.add(
        Particle(
          position: Vector2.zero(),
          velocity: Vector2(
            cos(angle) * speedVariation,
            sin(angle) * speedVariation,
          ),
          color: _varyColor(color),
          size: 3 + _random.nextDouble() * 4,
          lifetime: lifetime * (0.5 + _random.nextDouble() * 0.5),
          gravity: 200,
          fadeOut: true,
          shrink: true,
        ),
      );
    }

    return ParticleEffect(
      position: position,
      particles: particles,
    );
  }

  /// 피격 이펙트 (데미지 받을 때)
  static ParticleEffect createHitSparks({
    required Vector2 position,
    required Vector2 direction,
    Color color = Colors.white,
    int particleCount = 8,
  }) {
    final particles = <Particle>[];
    final baseAngle = atan2(direction.y, direction.x);

    for (int i = 0; i < particleCount; i++) {
      // 타격 방향 반대로 튀어나감
      final angleSpread = (pi / 3) * (_random.nextDouble() - 0.5);
      final angle = baseAngle + pi + angleSpread;
      final speed = 50 + _random.nextDouble() * 100;

      particles.add(
        Particle(
          position: Vector2.zero(),
          velocity: Vector2(
            cos(angle) * speed,
            sin(angle) * speed,
          ),
          color: color,
          size: 2 + _random.nextDouble() * 2,
          lifetime: 0.2 + _random.nextDouble() * 0.1,
          gravity: 100,
          fadeOut: true,
          shrink: false,
        ),
      );
    }

    return ParticleEffect(
      position: position,
      particles: particles,
    );
  }

  /// 슬라임 사망 이펙트 (액체 튀김)
  static ParticleEffect createSlimeSplash({
    required Vector2 position,
    Color color = Colors.green,
    int particleCount = 15,
  }) {
    final particles = <Particle>[];

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 30 + _random.nextDouble() * 80;

      particles.add(
        Particle(
          position: Vector2.zero(),
          velocity: Vector2(
            cos(angle) * speed,
            sin(angle) * speed - 50, // 위로 튀어오름
          ),
          color: _varyColor(color),
          size: 4 + _random.nextDouble() * 6,
          lifetime: 0.4 + _random.nextDouble() * 0.3,
          gravity: 300,
          fadeOut: true,
          shrink: false,
        ),
      );
    }

    return ParticleEffect(
      position: position,
      particles: particles,
    );
  }

  /// 고블린 사망 이펙트 (연기/먼지)
  static ParticleEffect createSmokeEffect({
    required Vector2 position,
    Color color = Colors.grey,
    int particleCount = 12,
  }) {
    final particles = <Particle>[];

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 20 + _random.nextDouble() * 40;

      particles.add(
        Particle(
          position: Vector2(
            (_random.nextDouble() - 0.5) * 16,
            (_random.nextDouble() - 0.5) * 16,
          ),
          velocity: Vector2(
            cos(angle) * speed,
            -30 - _random.nextDouble() * 30, // 위로 떠오름
          ),
          color: color.withValues(alpha: 0.6),
          size: 6 + _random.nextDouble() * 8,
          lifetime: 0.5 + _random.nextDouble() * 0.3,
          gravity: -50, // 위로 떠오름
          fadeOut: true,
          shrink: false,
        ),
      );
    }

    return ParticleEffect(
      position: position,
      particles: particles,
    );
  }

  /// 색상 변형 (약간의 랜덤 variation)
  static Color _varyColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final newHue = (hsl.hue + (_random.nextDouble() - 0.5) * 20) % 360;
    final newLightness =
        (hsl.lightness + (_random.nextDouble() - 0.5) * 0.2).clamp(0.0, 1.0);

    return hsl
        .withHue(newHue < 0 ? newHue + 360 : newHue)
        .withLightness(newLightness)
        .toColor();
  }
}
