/// Arcana: The Three Hearts - 바닥 드롭 아이템
/// 적 사망 시 드롭되는 아이템 컴포넌트
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/item.dart';
import '../characters/player.dart';

/// 바닥 드롭 아이템 컴포넌트
class DroppedItem extends PositionComponent with CollisionCallbacks, HasGameRef {
  DroppedItem({
    required this.item,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 70, // 방 컴포넌트보다 높은 우선순위로 항상 위에 렌더링
        );

  /// 아이템 데이터
  final Item item;

  /// 반짝임 애니메이션 타이머
  double _shimmerTimer = 0;

  /// 통통 튀는 애니메이션 타이머
  double _bounceTimer = 0;

  /// 획득 가능 여부 (스폰 직후 잠시 획득 불가)
  bool _canPickup = false;
  double _spawnTimer = 0.3;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 플레이어와의 충돌 감지용 히트박스
    add(
      CircleHitbox(
        radius: 16,
        position: Vector2(-4, -4),
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 스폰 타이머
    if (!_canPickup) {
      _spawnTimer -= dt;
      if (_spawnTimer <= 0) {
        _canPickup = true;
      }
    }

    // 애니메이션 타이머
    _shimmerTimer += dt * 2;
    _bounceTimer += dt * 4;

    // 플레이어와의 충돌 체크 (수동)
    if (_canPickup) {
      _checkPlayerCollision();
    }
  }

  /// 플레이어와의 충돌 체크
  void _checkPlayerCollision() {
    try {
      final player = gameRef.world.children.whereType<ArcanaPlayer>().first;
      final distance = position.distanceTo(player.position);

      if (distance < 32) {
        _onPickup(player);
      }
    } catch (_) {
      // 플레이어 없음
    }
  }

  /// 아이템 획득
  void _onPickup(ArcanaPlayer player) {
    // 플레이어의 인벤토리에 추가
    player.pickupItem(item);

    // 획득 이펙트 (파티클 등)
    _spawnPickupEffect();

    // 제거
    removeFromParent();
  }

  /// 획득 이펙트 생성
  void _spawnPickupEffect() {
    // 간단한 파티클 이펙트
    for (int i = 0; i < 5; i++) {
      gameRef.world.add(
        PickupParticle(
          position: position.clone(),
          color: item.rarityColor,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 통통 튀는 효과
    final bounceOffset = sin(_bounceTimer) * 3.5;
    final rotationEffect = sin(_bounceTimer * 0.5) * 0.1;

    // === 그림자 (그라디언트) ===
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(centerX, size.y + 3),
        width: 20,
        height: 10,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, size.y + 2), width: 16, height: 6),
      shadowPaint,
    );

    // === 희귀도 글로우 효과 ===
    final glowIntensity = (sin(_shimmerTimer * 1.5) + 1) / 2 * 0.4 + 0.3;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          item.rarityColor.withValues(alpha: glowIntensity),
          item.rarityColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY - bounceOffset),
        radius: 18,
      ));
    canvas.drawCircle(
      Offset(centerX, centerY - bounceOffset),
      16,
      glowPaint,
    );

    // === 아이템 배경 (그라디언트) ===
    final bgCenter = Offset(centerX, centerY - bounceOffset);
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [
          _lightenColor(item.rarityColor, 0.2).withValues(alpha: 0.6),
          item.rarityColor.withValues(alpha: 0.4),
          _darkenColor(item.rarityColor, 0.2).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: bgCenter, radius: 14));
    canvas.drawCircle(bgCenter, 13, bgPaint);

    // === 테두리 (이중 테두리) ===
    // 외곽 테두리
    canvas.drawCircle(
      bgCenter,
      13,
      Paint()
        ..color = _darkenColor(item.rarityColor, 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // 내곽 하이라이트
    canvas.drawCircle(
      bgCenter,
      11,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // === 아이템 아이콘 (향상된 버전) ===
    canvas.save();
    canvas.translate(centerX, centerY - bounceOffset);
    canvas.rotate(rotationEffect);
    canvas.translate(-centerX, -(centerY - bounceOffset));
    _drawItemIcon(canvas, bounceOffset);
    canvas.restore();

    // === 반짝임 효과 (다중) ===
    final shimmerOpacity = (sin(_shimmerTimer * 2) + 1) / 3;
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: shimmerOpacity)
      ..style = PaintingStyle.fill;

    // 메인 반짝임
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 5, centerY - 6 - bounceOffset),
        width: 5,
        height: 3,
      ),
      shimmerPaint,
    );
    // 보조 반짝임
    canvas.drawCircle(
      Offset(centerX - 2, centerY - 8 - bounceOffset),
      1.5,
      shimmerPaint..color = Colors.white.withValues(alpha: shimmerOpacity * 0.7),
    );

    // === 파티클 효과 (희귀도가 높을 때) ===
    if (item.rarity.index >= 2) {  // rare 이상
      _drawRarityParticles(canvas, bounceOffset);
    }
  }

  /// 희귀도 파티클 효과
  void _drawRarityParticles(Canvas canvas, double bounceOffset) {
    final centerX = size.x / 2;
    final centerY = size.y / 2 - bounceOffset;

    for (int i = 0; i < 4; i++) {
      final angle = (_shimmerTimer * 0.5 + i * pi / 2) % (pi * 2);
      final radius = 16.0 + sin(_shimmerTimer + i) * 3;
      final x = centerX + cos(angle) * radius;
      final y = centerY + sin(angle) * radius * 0.6;

      final particleOpacity = (sin(_shimmerTimer * 2 + i) + 1) / 2 * 0.6;
      canvas.drawCircle(
        Offset(x, y),
        1.5,
        Paint()..color = item.rarityColor.withValues(alpha: particleOpacity),
      );
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

  /// 아이템 타입별 아이콘 그리기 (향상된 버전)
  void _drawItemIcon(Canvas canvas, double bounceOffset) {
    final center = Offset(size.x / 2, size.y / 2 - bounceOffset);
    final iconColor = Colors.white;
    final iconDark = Colors.white.withValues(alpha: 0.7);

    switch (item.type) {
      case ItemType.weapon:
        // 검 아이콘 (향상된)
        // 칼날
        final bladePath = Path()
          ..moveTo(center.dx, center.dy - 7)
          ..lineTo(center.dx + 3, center.dy + 1)
          ..lineTo(center.dx, center.dy - 1)
          ..lineTo(center.dx - 3, center.dy + 1)
          ..close();
        // 칼날 그라디언트
        final bladePaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [iconColor, iconDark],
          ).createShader(bladePath.getBounds());
        canvas.drawPath(bladePath, bladePaint);

        // 코등이 (가드)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 8, height: 2),
            const Radius.circular(1),
          ),
          Paint()..color = const Color(0xFFD4AF37),
        );

        // 손잡이
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(center.dx, center.dy + 5), width: 3, height: 5),
            const Radius.circular(1),
          ),
          Paint()..color = const Color(0xFF8B4513),
        );

      case ItemType.armor:
        // 방패 아이콘 (향상된)
        final shieldPath = Path()
          ..moveTo(center.dx - 6, center.dy - 5)
          ..lineTo(center.dx + 6, center.dy - 5)
          ..lineTo(center.dx + 6, center.dy + 2)
          ..quadraticBezierTo(center.dx, center.dy + 8, center.dx - 6, center.dy + 2)
          ..close();

        // 방패 그라디언트
        final shieldPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [iconColor, const Color(0xFFE0E0E0), iconDark],
          ).createShader(shieldPath.getBounds());
        canvas.drawPath(shieldPath, shieldPaint);

        // 방패 외곽선
        canvas.drawPath(shieldPath, Paint()
          ..color = const Color(0xFFD4AF37)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

        // 문양
        canvas.drawCircle(
          Offset(center.dx, center.dy),
          3,
          Paint()..color = const Color(0xFFD4AF37),
        );

      case ItemType.consumable:
        // 포션 아이콘 (향상된)
        // 병 몸체
        final bottleBodyPaint = Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, 0),
            colors: [
              const Color(0xFFFF6B6B),
              const Color(0xFFDC2626),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: 6));
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx, center.dy + 1), width: 10, height: 10),
          bottleBodyPaint,
        );

        // 병 목
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(center.dx - 2, center.dy - 6, 4, 4),
            const Radius.circular(1),
          ),
          Paint()..color = const Color(0xFFA3E635),
        );

        // 병 마개
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(center.dx - 2.5, center.dy - 8, 5, 2),
            const Radius.circular(1),
          ),
          Paint()..color = const Color(0xFF8B4513),
        );

        // 하이라이트
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx - 2, center.dy - 1), width: 3, height: 5),
          Paint()..color = Colors.white.withValues(alpha: 0.4),
        );

      case ItemType.key:
        // 열쇠 아이콘 (향상된)
        // 열쇠 고리
        canvas.drawCircle(
          Offset(center.dx, center.dy - 4),
          4,
          Paint()
            ..color = const Color(0xFFD4AF37)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );

        // 열쇠 몸체
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(center.dx - 1.5, center.dy, 3, 8),
            const Radius.circular(1),
          ),
          Paint()..color = const Color(0xFFD4AF37),
        );

        // 열쇠 이빨
        canvas.drawRect(
          Rect.fromLTWH(center.dx + 1.5, center.dy + 5, 2, 2),
          Paint()..color = const Color(0xFFD4AF37),
        );
        canvas.drawRect(
          Rect.fromLTWH(center.dx + 1.5, center.dy + 2, 1.5, 1.5),
          Paint()..color = const Color(0xFFD4AF37),
        );

        // 하이라이트
        canvas.drawCircle(
          Offset(center.dx - 1, center.dy - 5),
          1,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
    }
  }
}

/// 획득 파티클 이펙트
class PickupParticle extends PositionComponent {
  PickupParticle({
    required Vector2 position,
    required this.color,
  }) : super(position: position, size: Vector2(4, 4));

  final Color color;
  late Vector2 velocity;
  double _lifetime = 0.5;
  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 랜덤 방향으로 튀어나감
    final angle = _random.nextDouble() * 2 * pi;
    final speed = 50 + _random.nextDouble() * 50;
    velocity = Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
      return;
    }

    // 이동
    position += velocity * dt;

    // 중력
    velocity.y += 200 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = _lifetime / 0.5;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 2, paint);
  }
}
