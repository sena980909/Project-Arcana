/// Arcana: The Three Hearts - 스킬 투사체
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../enemy.dart';

/// 투사체 적중 콜백
typedef ProjectileHitCallback = void Function(Enemy enemy);

/// 스킬 투사체 컴포넌트
class SkillProjectile extends PositionComponent {
  SkillProjectile({
    required Vector2 position,
    required this.direction,
    required this.speed,
    required this.damage,
    required this.range,
    required this.skillId,
    this.onHit,
    this.piercing = false,
  }) : super(
          position: position,
          size: Vector2(16, 16),
          anchor: Anchor.center,
        );

  final Vector2 direction;
  final double speed;
  final double damage;
  final double range;
  final String skillId;
  final ProjectileHitCallback? onHit;
  final bool piercing;

  double _traveled = 0;
  final Set<Enemy> _hitEnemies = {};

  @override
  void update(double dt) {
    super.update(dt);

    // 이동
    final movement = direction * speed * dt;
    position += movement;
    _traveled += movement.length;

    // 사거리 체크
    if (_traveled >= range) {
      removeFromParent();
    }
  }

  /// 적과 충돌 체크 (외부에서 호출)
  bool checkCollision(Enemy enemy) {
    if (enemy.isDead) return false;
    if (_hitEnemies.contains(enemy)) return false;

    final distance = (enemy.position - position).length;
    if (distance <= 20) {
      _hitEnemies.add(enemy);
      onHit?.call(enemy);

      if (!piercing) {
        removeFromParent();
      }
      return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 투사체 렌더링
    final color = _getColor();

    // 외곽 발광
    final glowPaint = Paint()
      ..color = color.withAlpha(100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, 10, glowPaint);

    // 메인 원
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 6, paint);

    // 중심 밝은 부분
    final centerPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 3, centerPaint);

    // 꼬리 효과
    final tailPaint = Paint()
      ..color = color.withAlpha(150)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final tailLength = 15.0;
    final tailEnd = Offset(-direction.x * tailLength, -direction.y * tailLength);
    canvas.drawLine(Offset.zero, tailEnd, tailPaint);
  }

  Color _getColor() {
    switch (skillId) {
      case 'fireball':
        return Colors.orange;
      case 'ice_shard':
        return Colors.cyan;
      case 'lightning_bolt':
        return Colors.yellow;
      case 'arcane_missiles':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
