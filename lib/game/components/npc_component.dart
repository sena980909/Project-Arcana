/// Arcana: The Three Hearts - NPC 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player.dart';

/// NPC 컴포넌트
class NpcComponent extends PositionComponent {
  NpcComponent({
    required Vector2 position,
    required this.assetPath,
    required this.player,
    this.npcType = 'merchant',
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        );

  final String assetPath;
  final Player player;
  final String npcType;

  /// 상호작용 가능 범위
  static const double interactionRange = 50.0;

  // 애니메이션
  SpriteAnimationComponent? _animationComponent;

  // idle 흔들림
  double _bobTimer = 0;

  /// 플레이어가 상호작용 범위 안에 있는지
  bool get isPlayerNearby {
    final distance = (player.position - position).length;
    return distance <= interactionRange;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // elf_m_idle 스프라이트 로드 시도
    SpriteAnimation? animation;
    try {
      final sprites = <Sprite>[];
      for (int i = 0; i < 4; i++) {
        final sprite = await Sprite.load('${assetPath}elf_m_idle_anim_f$i.png');
        sprites.add(sprite);
      }
      animation = SpriteAnimation.spriteList(sprites, stepTime: 0.18);
    } catch (e) {
      // 폴백: knight 스프라이트
      try {
        final sprites = <Sprite>[];
        for (int i = 0; i < 4; i++) {
          final sprite =
              await Sprite.load('${assetPath}knight_m_idle_anim_f$i.png');
          sprites.add(sprite);
        }
        animation = SpriteAnimation.spriteList(sprites, stepTime: 0.18);
      } catch (e2) {
        // 무시 - 스프라이트 없으면 원으로 렌더
      }
    }

    if (animation != null) {
      _animationComponent = SpriteAnimationComponent(
        animation: animation,
        size: Vector2(32, 32),
        anchor: Anchor.center,
      );
      add(_animationComponent!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt;

    // 좌우 미세 흔들림
    if (_animationComponent != null) {
      _animationComponent!.position.x = sin(_bobTimer * 2) * 1.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 스프라이트가 없는 경우 폴백 렌더링
    if (_animationComponent == null) {
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()..color = Colors.green.shade400,
      );
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()
          ..color = Colors.green.shade200
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // 상호작용 힌트 (플레이어가 근접 시)
    if (isPlayerNearby) {
      _renderInteractionHint(canvas);
    }

    // NPC 이름 표시
    _renderName(canvas);
  }

  /// 상호작용 힌트 아이콘 (말풍선)
  void _renderInteractionHint(Canvas canvas) {
    // 말풍선 배경
    final bubbleRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-12, -38, 24, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      bubbleRect,
      Paint()..color = Colors.white.withAlpha(220),
    );

    // 말풍선 꼬리
    final tailPath = Path()
      ..moveTo(-4, -22)
      ..lineTo(0, -17)
      ..lineTo(4, -22)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = Colors.white.withAlpha(220));

    // "F" 키 텍스트
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'F',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -36));
  }

  /// NPC 이름 표시
  void _renderName(Canvas canvas) {
    final name = npcType == 'merchant' ? '상인' : 'NPC';
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Colors.yellow.shade200,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 16));
  }
}
