/// Arcana: The Three Hearts - NPC 컴포넌트
/// 게임 월드 내 NPC 표현 및 상호작용
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/npc.dart';

/// NPC와 상호작용 콜백
typedef OnNpcInteract = void Function(NpcData npc);

/// NPC 컴포넌트
class NpcComponent extends PositionComponent with HasGameRef, CollisionCallbacks {
  NpcComponent({
    required this.npcData,
    required Vector2 position,
    this.onInteract,
  }) : super(
          position: position,
          size: Vector2(32, 48),
          // Y-소팅: 초기값, update에서 동적 갱신
          priority: 1000,
        );

  /// NPC 데이터
  final NpcData npcData;

  /// 상호작용 콜백
  final OnNpcInteract? onInteract;

  /// 플레이어가 범위 안에 있는지
  bool _playerInRange = false;
  bool get playerInRange => _playerInRange;

  /// 상호작용 프롬프트 표시 여부
  bool _showPrompt = false;
  bool get showPrompt => _showPrompt;

  /// 상호작용 쿨다운
  double _interactCooldown = 0;

  /// 현재 프레임 색상 (임시 비주얼)
  late final Paint _bodyPaint;
  late final Paint _headPaint;
  late final Paint _promptPaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 임시 비주얼 색상 설정 (NPC 타입별)
    _bodyPaint = Paint()..color = _getNpcColor();
    _headPaint = Paint()..color = _getNpcColor().withValues(alpha: 0.8);
    _promptPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 상호작용 범위 히트박스
    add(
      CircleHitbox(
        radius: npcData.interactionRange,
        position: Vector2(size.x / 2, size.y / 2),
        isSolid: false,
        collisionType: CollisionType.passive,
      )..debugMode = false,
    );
  }

  /// NPC 타입별 색상
  Color _getNpcColor() {
    switch (npcData.type) {
      case NpcType.story:
        return Colors.purple;
      case NpcType.merchant:
        return Colors.orange;
      case NpcType.blacksmith:
        return Colors.brown;
      case NpcType.healer:
        return Colors.green;
      case NpcType.quest:
        return Colors.blue;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 쿨다운 감소
    if (_interactCooldown > 0) {
      _interactCooldown -= dt;
    }

    // 프롬프트 표시 조건
    _showPrompt = _playerInRange && _interactCooldown <= 0;

    // Y-소팅: Y좌표 기반 렌더링 순서 (높은 Y = 앞에 렌더링)
    priority = 1000 + position.y.toInt();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // NPC 타입별 향상된 렌더링
    _drawEnhancedNpc(canvas);

    // 상호작용 프롬프트
    if (_showPrompt) {
      _drawInteractionPrompt(canvas);
    }
  }

  /// 향상된 NPC 렌더링
  void _drawEnhancedNpc(Canvas canvas) {
    final centerX = size.x / 2;
    final baseColor = _getNpcColor();
    final darkColor = _darkenColor(baseColor, 0.2);
    final lightColor = _lightenColor(baseColor, 0.15);

    // 그림자
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(centerX, size.y - 2),
        width: 28,
        height: 10,
      ));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, size.y - 2), width: 22, height: 7),
      shadowPaint,
    );

    // 다리
    final legPaint = Paint()
      ..shader = LinearGradient(
        colors: [darkColor, baseColor],
      ).createShader(const Rect.fromLTWH(0, 0, 6, 12));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 7, 36, 5, 10),
        const Radius.circular(1.5),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 2, 36, 5, 10),
        const Radius.circular(1.5),
      ),
      legPaint,
    );

    // 몸체 (그라디언트)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 10, 18, 20, 20),
      const Radius.circular(4),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightColor, baseColor, darkColor],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // 몸체 외곽선
    canvas.drawRRect(bodyRect, Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2);

    // 림 라이팅
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 8, 20, 4, 14),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    // 타입별 디테일
    _drawNpcTypeDetail(canvas, centerX);

    // 머리 (그라디언트 피부색)
    final headCenter = Offset(centerX, 12);
    const skinColor = Color(0xFFFFD5B8);
    const skinDark = Color(0xFFE5B89C);
    const skinLight = Color(0xFFFFF0E6);

    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.2,
        colors: [skinLight, skinColor, skinDark],
      ).createShader(Rect.fromCenter(center: headCenter, width: 22, height: 22));
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 18, height: 18),
      headPaint,
    );

    // 머리 외곽선
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 18, height: 18),
      Paint()
        ..color = const Color(0xFF2D2D2D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 머리카락
    _drawNpcHair(canvas, centerX);

    // 눈
    _drawNpcEyes(canvas, centerX);

    // 볼 홍조
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 5, 14), width: 4, height: 2.5),
      Paint()..color = const Color(0xFFFFB5B5).withValues(alpha: 0.3),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 5, 14), width: 4, height: 2.5),
      Paint()..color = const Color(0xFFFFB5B5).withValues(alpha: 0.3),
    );
  }

  /// NPC 타입별 디테일
  void _drawNpcTypeDetail(Canvas canvas, double centerX) {
    switch (npcData.type) {
      case NpcType.merchant:
        // 상인 - 앞치마
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX - 8, 24, 16, 12),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFFF5F5DC),
        );
        // 주머니
        canvas.drawCircle(
          Offset(centerX - 4, 30),
          3,
          Paint()..color = const Color(0xFFD4AF37),
        );
      case NpcType.blacksmith:
        // 대장장이 - 가죽 앞치마
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(centerX - 7, 22, 14, 14),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFF5C4033),
        );
        // 망치 아이콘
        canvas.drawRect(
          Rect.fromLTWH(centerX + 8, 24, 3, 10),
          Paint()..color = const Color(0xFF6B7280),
        );
      case NpcType.healer:
        // 힐러 - 십자가 마크
        canvas.drawRect(
          Rect.fromLTWH(centerX - 1.5, 24, 3, 10),
          Paint()..color = Colors.white,
        );
        canvas.drawRect(
          Rect.fromLTWH(centerX - 5, 27, 10, 3),
          Paint()..color = Colors.white,
        );
      case NpcType.story:
      case NpcType.quest:
        // 스토리/퀘스트 NPC - 목걸이
        final necklacePaint = Paint()
          ..color = const Color(0xFFD4AF37)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(centerX, 20), width: 12, height: 8),
          0,
          pi,
          false,
          necklacePaint,
        );
        // 펜던트
        canvas.drawCircle(
          Offset(centerX, 24),
          2.5,
          Paint()..color = const Color(0xFFD4AF37),
        );
    }
  }

  /// NPC 머리카락
  void _drawNpcHair(Canvas canvas, double centerX) {
    Color hairColor;
    switch (npcData.type) {
      case NpcType.merchant:
        hairColor = const Color(0xFF8B4513);  // 갈색
      case NpcType.blacksmith:
        hairColor = const Color(0xFF1A1A1A);  // 검은색
      case NpcType.healer:
        hairColor = const Color(0xFFFFFFE0);  // 금발
      case NpcType.story:
        hairColor = const Color(0xFF4A3728);  // 밤색
      case NpcType.quest:
        hairColor = const Color(0xFF8B0000);  // 적갈색
    }

    final hairDark = _darkenColor(hairColor, 0.3);

    // 윗머리
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX, 9), width: 20, height: 14),
      pi,
      pi,
      true,
      Paint()..color = hairColor,
    );

    // 머리카락 하이라이트
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX - 3, 6), width: 8, height: 6),
      pi * 1.2,
      pi * 0.6,
      true,
      Paint()..color = _lightenColor(hairColor, 0.2).withValues(alpha: 0.6),
    );

    // 옆머리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 10, 8, 4, 8),
        const Radius.circular(2),
      ),
      Paint()..color = hairDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 6, 8, 4, 8),
        const Radius.circular(2),
      ),
      Paint()..color = hairDark,
    );
  }

  /// NPC 눈
  void _drawNpcEyes(Canvas canvas, double centerX) {
    for (final offsetX in [-4.0, 4.0]) {
      final eyeCenter = Offset(centerX + offsetX, 11);

      // 눈 흰자
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 5, height: 4),
        Paint()..color = const Color(0xFFFFFAF0),
      );

      // 외곽선
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 5, height: 4),
        Paint()
          ..color = const Color(0xFF2D2D2D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );

      // 눈동자
      canvas.drawCircle(
        Offset(eyeCenter.dx, eyeCenter.dy + 0.3),
        1.5,
        Paint()..color = const Color(0xFF2D2D2D),
      );

      // 하이라이트
      canvas.drawCircle(
        Offset(eyeCenter.dx - 0.8, eyeCenter.dy - 0.5),
        0.8,
        Paint()..color = Colors.white,
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

  /// 상호작용 프롬프트 그리기 (향상된 버전)
  void _drawInteractionPrompt(Canvas canvas) {
    const promptY = -12.0;
    final centerX = size.x / 2;

    // 부동 애니메이션
    final floatOffset = sin(_interactCooldown * 10) * 2;

    // 배경 (그라디언트)
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xDD000000),
          const Color(0xAA000000),
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, promptY + floatOffset), radius: 14));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, promptY + floatOffset), width: 26, height: 22),
        const Radius.circular(6),
      ),
      bgPaint,
    );

    // 테두리 (골드)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, promptY + floatOffset), width: 26, height: 22),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 'E' 텍스트
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'E',
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Color(0x80000000),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, promptY + floatOffset - textPainter.height / 2),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // 플레이어가 범위에 들어옴
    if (_isPlayer(other)) {
      _playerInRange = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    // 플레이어가 범위에서 나감
    if (_isPlayer(other)) {
      _playerInRange = false;
    }
  }

  /// 플레이어인지 확인
  bool _isPlayer(PositionComponent other) {
    // 플레이어 컴포넌트 타입 확인
    return other.runtimeType.toString().contains('Player');
  }

  /// 상호작용 시도
  bool tryInteract() {
    if (!_playerInRange || _interactCooldown > 0) {
      return false;
    }

    _interactCooldown = 0.5; // 0.5초 쿨다운
    onInteract?.call(npcData);
    return true;
  }
}

/// NPC 상호작용 트리거 (플레이어 충돌 감지용)
class NpcInteractionTrigger extends PositionComponent with CollisionCallbacks {
  NpcInteractionTrigger({
    required this.npcComponent,
    required double radius,
  }) : super(
          position: Vector2.zero(),
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  final NpcComponent npcComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      CircleHitbox(
        radius: size.x / 2,
        isSolid: false,
      ),
    );
  }
}
