/// Arcana: The Three Hearts - 스토리 오브젝트
/// 환경 스토리텔링용 상호작용 가능한 오브젝트 (벽화, 비문, 제단 등)
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../characters/player.dart';
import '../arcana_game.dart';

/// 스토리 오브젝트 타입
enum StoryObjectType {
  mural,      // 벽화
  inscription, // 비문
  altar,      // 제단
  statue,     // 석상
  memorial,   // 기념비
}

/// 환경 스토리텔링 오브젝트
class StoryObject extends PositionComponent with CollisionCallbacks, HasGameRef<ArcanaGame> {
  StoryObject({
    required Vector2 position,
    required this.type,
    required this.dialogueId,
    this.flagToSet,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
          priority: 60,
        );

  /// 오브젝트 타입
  final StoryObjectType type;

  /// 상호작용 시 시작할 대화 ID
  final String dialogueId;

  /// 상호작용 후 설정할 플래그 (선택)
  final String? flagToSet;

  /// 플레이어가 범위 내에 있는지
  bool _playerNearby = false;

  /// 이미 상호작용 했는지
  bool _interacted = false;

  /// 빛나는 효과 타이머
  double _glowTimer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 상호작용 범위 히트박스
    add(
      CircleHitbox(
        radius: 40,
        position: Vector2(-8, -8),
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _glowTimer += dt * 2;

    // 플레이어 근처 체크
    _checkPlayerProximity();
  }

  /// 플레이어 근접 체크
  void _checkPlayerProximity() {
    try {
      final player = gameRef.world.children.whereType<ArcanaPlayer>().first;
      final distance = position.distanceTo(player.position);

      final wasNearby = _playerNearby;
      _playerNearby = distance < 48;

      // 플레이어가 가까이 왔고 아직 상호작용 안 했으면 대화 시작
      if (_playerNearby && !wasNearby && !_interacted) {
        _interact();
      }
    } catch (_) {
      // 플레이어 없음
    }
  }

  /// 상호작용
  void _interact() {
    if (_interacted) return;

    // 대화 시작
    final started = gameRef.startDialogue(dialogueId);

    if (started) {
      _interacted = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 타입별 렌더링
    switch (type) {
      case StoryObjectType.mural:
        _renderMural(canvas);
      case StoryObjectType.inscription:
        _renderInscription(canvas);
      case StoryObjectType.altar:
        _renderAltar(canvas);
      case StoryObjectType.statue:
        _renderStatue(canvas);
      case StoryObjectType.memorial:
        _renderMemorial(canvas);
    }

    // 상호작용 가능 표시 (아직 안 했으면)
    if (!_interacted) {
      _renderGlow(canvas);
    }
  }

  /// 빛나는 효과 (향상된)
  void _renderGlow(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    final glowIntensity = (sin(_glowTimer) + 1) / 2;

    // 외곽 글로우
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: glowIntensity * 0.4),
          Colors.amber.withValues(alpha: glowIntensity * 0.2),
          Colors.amber.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: 25 + sin(_glowTimer) * 4,
      ));
    canvas.drawCircle(
      Offset(centerX, centerY),
      24 + sin(_glowTimer) * 3,
      outerGlowPaint,
    );

    // 내부 밝은 글로우
    final innerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: glowIntensity * 0.3),
          Colors.amber.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: 15));
    canvas.drawCircle(Offset(centerX, centerY), 12, innerGlowPaint);

    // 반짝이는 파티클
    for (int i = 0; i < 4; i++) {
      final angle = (_glowTimer * 0.3 + i * pi / 2) % (pi * 2);
      final radius = 18.0 + sin(_glowTimer + i) * 3;
      final x = centerX + cos(angle) * radius;
      final y = centerY + sin(angle) * radius;

      final particleOpacity = (sin(_glowTimer * 2 + i) + 1) / 2 * 0.6;
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.amber.withValues(alpha: particleOpacity),
      );
    }
  }

  /// 벽화 렌더링 (향상된)
  void _renderMural(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 액자 외곽 (골드 테두리)
    final framePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFD4AF37),
          const Color(0xFF8B6914),
          const Color(0xFFD4AF37),
        ],
      ).createShader(Rect.fromCenter(center: Offset(centerX, centerY), width: 30, height: 26));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY), width: 30, height: 26),
        const Radius.circular(2),
      ),
      framePaint,
    );

    // 액자 내부 (어두운 배경)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY), width: 24, height: 20),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // 그림 (심장 아이콘 - 게임 테마)
    final heartPath = Path();
    heartPath.moveTo(centerX, centerY + 4);
    heartPath.cubicTo(centerX - 8, centerY - 2, centerX - 8, centerY - 8, centerX, centerY - 4);
    heartPath.cubicTo(centerX + 8, centerY - 8, centerX + 8, centerY - 2, centerX, centerY + 4);

    canvas.drawPath(heartPath, Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFF6B6B), const Color(0xFF991B1B)],
      ).createShader(heartPath.getBounds()));

    // 그림 하이라이트
    canvas.drawCircle(
      Offset(centerX - 3, centerY - 4),
      2,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  /// 비문 렌더링 (향상된)
  void _renderInscription(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 석판 (그라디언트)
    final stoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: 26, height: 30),
      const Radius.circular(3),
    );
    final stonePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF9CA3AF),
          const Color(0xFF6B7280),
          const Color(0xFF4B5563),
        ],
      ).createShader(stoneRect.outerRect);
    canvas.drawRRect(stoneRect, stonePaint);

    // 석판 외곽선
    canvas.drawRRect(stoneRect, Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // 룬 문자 스타일 텍스트
    final runePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 첫 번째 줄 - 룬 심볼
    canvas.drawLine(
      Offset(centerX - 8, centerY - 10),
      Offset(centerX - 4, centerY - 6),
      runePaint,
    );
    canvas.drawLine(
      Offset(centerX - 4, centerY - 6),
      Offset(centerX, centerY - 10),
      runePaint,
    );
    canvas.drawLine(
      Offset(centerX + 2, centerY - 8),
      Offset(centerX + 8, centerY - 8),
      runePaint,
    );

    // 두 번째 줄
    canvas.drawLine(Offset(centerX - 6, centerY - 2), Offset(centerX + 6, centerY - 2), runePaint);

    // 세 번째 줄 - 패턴
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(centerX - 6 + i * 6.0, centerY + 4),
        2,
        Paint()..color = const Color(0xFF374151),
      );
    }

    // 네 번째 줄
    canvas.drawLine(Offset(centerX - 8, centerY + 10), Offset(centerX + 8, centerY + 10), runePaint);
  }

  /// 제단 렌더링 (향상된)
  void _renderAltar(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 제단 베이스 (그라디언트)
    final baseRect = Rect.fromLTWH(centerX - 14, centerY + 2, 28, 12);
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF6B7280), const Color(0xFF374151)],
      ).createShader(baseRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(2)),
      basePaint,
    );

    // 제단 상판
    final topRect = Rect.fromLTWH(centerX - 12, centerY - 2, 24, 6);
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
      ).createShader(topRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(1)),
      topPaint,
    );

    // 장식 패턴
    canvas.drawRect(
      Rect.fromLTWH(centerX - 10, centerY + 5, 20, 2),
      Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.6),
    );

    // 촛불 (애니메이션)
    final flameFlicker = sin(_glowTimer * 3) * 2;

    // 촛대
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 1.5, centerY - 8, 3, 6),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFFF5F5DC),
    );

    // 불꽃 (그라디언트)
    final flamePath = Path()
      ..moveTo(centerX, centerY - 16 + flameFlicker)
      ..quadraticBezierTo(centerX + 3, centerY - 12, centerX, centerY - 8)
      ..quadraticBezierTo(centerX - 3, centerY - 12, centerX, centerY - 16 + flameFlicker);

    final flamePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.5),
        colors: [
          Colors.yellow,
          Colors.orange,
          Colors.red.shade700,
        ],
      ).createShader(flamePath.getBounds());
    canvas.drawPath(flamePath, flamePaint);

    // 불꽃 글로우
    canvas.drawCircle(
      Offset(centerX, centerY - 12),
      5,
      Paint()..color = Colors.orange.withValues(alpha: 0.3),
    );
  }

  /// 석상 렌더링 (향상된)
  void _renderStatue(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 받침대 (그라디언트)
    final pedestalRect = Rect.fromLTWH(centerX - 10, centerY + 6, 20, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pedestalRect, const Radius.circular(1)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
        ).createShader(pedestalRect),
    );

    // 석상 몸체 (그라디언트)
    final bodyRect = Rect.fromLTWH(centerX - 6, centerY - 6, 12, 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [const Color(0xFF6B7280), const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
        ).createShader(bodyRect),
    );

    // 머리
    final headCenter = Offset(centerX, centerY - 10);
    canvas.drawCircle(
      headCenter,
      6,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [const Color(0xFFA3A3A3), const Color(0xFF6B7280)],
        ).createShader(Rect.fromCircle(center: headCenter, radius: 7)),
    );

    // 팔 (단순화된 형태)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 10, centerY - 2, 4, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 6, centerY - 2, 4, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF9CA3AF),
    );

    // 눈 (빈 눈)
    for (final offsetX in [-2.0, 2.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX + offsetX, centerY - 10), width: 2.5, height: 3),
        Paint()..color = const Color(0xFF374151),
      );
    }
  }

  /// 기념비 렌더링 (향상된)
  void _renderMemorial(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 기념비 본체 (오벨리스크 형태)
    final monumentPath = Path()
      ..moveTo(centerX, centerY - 14)
      ..lineTo(centerX + 8, centerY - 8)
      ..lineTo(centerX + 8, centerY + 10)
      ..lineTo(centerX - 8, centerY + 10)
      ..lineTo(centerX - 8, centerY - 8)
      ..close();

    // 그라디언트
    final monumentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF4B5563),
          const Color(0xFF6B7280),
          const Color(0xFF4B5563),
        ],
      ).createShader(monumentPath.getBounds());
    canvas.drawPath(monumentPath, monumentPaint);

    // 외곽선
    canvas.drawPath(monumentPath, Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // 장식 문양 (심장)
    final miniHeartPath = Path();
    miniHeartPath.moveTo(centerX, centerY);
    miniHeartPath.cubicTo(centerX - 4, centerY - 3, centerX - 4, centerY - 6, centerX, centerY - 3);
    miniHeartPath.cubicTo(centerX + 4, centerY - 6, centerX + 4, centerY - 3, centerX, centerY);
    canvas.drawPath(miniHeartPath, Paint()..color = const Color(0xFFDC2626).withValues(alpha: 0.7));

    // 꽃 장식
    _drawFlower(canvas, centerX - 5, centerY + 7, const Color(0xFFA855F7));
    _drawFlower(canvas, centerX + 5, centerY + 7, const Color(0xFFF472B6));
  }

  /// 꽃 그리기 헬퍼
  void _drawFlower(Canvas canvas, double x, double y, Color color) {
    // 꽃잎
    for (int i = 0; i < 5; i++) {
      final angle = i * pi * 2 / 5;
      final petalX = x + cos(angle) * 3;
      final petalY = y + sin(angle) * 3;
      canvas.drawCircle(Offset(petalX, petalY), 2, Paint()..color = color);
    }
    // 중심
    canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = const Color(0xFFFDE047));
  }
}
