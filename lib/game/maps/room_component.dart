/// Arcana: The Three Hearts - 방 컴포넌트
/// Room 데이터를 Flame 컴포넌트로 변환
library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/room.dart';
import 'dungeon_generator.dart';

/// 방 컴포넌트
class RoomComponent extends PositionComponent with HasGameRef {
  RoomComponent({
    required this.room,
    this.onEnemyKilled,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(
            room.width * RoomBuilder.tileSize,
            room.height * RoomBuilder.tileSize,
          ),
          priority: 0, // 가장 낮은 우선순위 (바닥 레이어)
        );

  /// 방 데이터
  final Room room;

  /// 적 처치 콜백
  final VoidCallback? onEnemyKilled;

  /// 타일 데이터
  late List<List<int>> _tiles;

  /// 타일 크기
  static const double tileSize = 32;

  /// 바닥 색상
  Color get _floorColor {
    switch (room.type) {
      case RoomType.start:
        return const Color(0xFF2a2a3e);
      case RoomType.treasure:
        return const Color(0xFF3a3a2e);
      case RoomType.shop:
        return const Color(0xFF2e3a2a);
      case RoomType.rest:
        return const Color(0xFF2a3a3e);
      case RoomType.boss:
        return const Color(0xFF3e2a2a);
      default:
        return const Color(0xFF1a1a2e);
    }
  }

  /// 벽 색상
  Color get _wallColor {
    switch (room.type) {
      case RoomType.boss:
        return const Color(0xFF8B0000);
      default:
        return const Color(0xFF4a4a5e);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 타일 데이터 생성
    _tiles = RoomBuilder.buildRoomTiles(room);

    // 벽 충돌체 추가
    _addWallCollisions();

    // 문 트리거 추가
    _addDoorTriggers();
  }

  /// 벽 충돌체 추가
  void _addWallCollisions() {
    for (int y = 0; y < room.height; y++) {
      for (int x = 0; x < room.width; x++) {
        if (_tiles[y][x] == 1) {
          add(WallBlock(
            position: Vector2(x * tileSize, y * tileSize),
            size: Vector2(tileSize, tileSize),
          ));
        }
      }
    }
  }

  /// 문 트리거 추가
  void _addDoorTriggers() {
    for (final entry in room.doors.entries) {
      final direction = entry.key;
      Vector2 triggerPos;
      Vector2 triggerSize;

      switch (direction) {
        case DoorDirection.north:
          triggerPos = Vector2((room.width / 2 - 1) * tileSize, 0);
          triggerSize = Vector2(tileSize * 3, tileSize);
        case DoorDirection.south:
          triggerPos = Vector2(
            (room.width / 2 - 1) * tileSize,
            (room.height - 1) * tileSize,
          );
          triggerSize = Vector2(tileSize * 3, tileSize);
        case DoorDirection.west:
          triggerPos = Vector2(0, (room.height / 2 - 1) * tileSize);
          triggerSize = Vector2(tileSize, tileSize * 3);
        case DoorDirection.east:
          triggerPos = Vector2(
            (room.width - 1) * tileSize,
            (room.height / 2 - 1) * tileSize,
          );
          triggerSize = Vector2(tileSize, tileSize * 3);
      }

      add(DoorTrigger(
        position: triggerPos,
        size: triggerSize,
        direction: direction,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 바닥 렌더링
    final floorPaint = Paint()
      ..color = _floorColor
      ..style = PaintingStyle.fill;

    final wallPaint = Paint()
      ..color = _wallColor
      ..style = PaintingStyle.fill;

    for (int y = 0; y < room.height; y++) {
      for (int x = 0; x < room.width; x++) {
        final rect = Rect.fromLTWH(
          x * tileSize,
          y * tileSize,
          tileSize,
          tileSize,
        );

        if (_tiles[y][x] == 0) {
          canvas.drawRect(rect, floorPaint);
          _drawFloorDetail(canvas, x, y);
        } else {
          canvas.drawRect(rect, wallPaint);
          _drawWallDetail(canvas, x, y);
        }
      }
    }

    // 방 타입 표시 (디버그용)
    _drawRoomTypeIndicator(canvas);
  }

  /// 바닥 디테일 그리기
  void _drawFloorDetail(Canvas canvas, int x, int y) {
    // 격자 무늬
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromLTWH(x * tileSize, y * tileSize, tileSize, tileSize),
      gridPaint,
    );
  }

  /// 벽 디테일 그리기
  void _drawWallDetail(Canvas canvas, int x, int y) {
    // 벽 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(x * tileSize, y * tileSize, tileSize, 4),
      highlightPaint,
    );
  }

  /// 방 타입 인디케이터
  void _drawRoomTypeIndicator(Canvas canvas) {
    String text;
    Color color;

    switch (room.type) {
      case RoomType.start:
        text = 'START';
        color = Colors.green;
      case RoomType.treasure:
        text = 'TREASURE';
        color = Colors.amber;
      case RoomType.shop:
        text = 'SHOP';
        color = Colors.blue;
      case RoomType.rest:
        text = 'REST';
        color = Colors.cyan;
      case RoomType.boss:
        text = 'BOSS';
        color = Colors.red;
      case RoomType.combat:
        text = 'COMBAT';
        color = Colors.orange;
      default:
        return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: 0.5),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}

/// 벽 블록 (충돌용)
class WallBlock extends PositionComponent with CollisionCallbacks {
  WallBlock({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }
}

/// 문 트리거 (방 전환용)
class DoorTrigger extends PositionComponent with CollisionCallbacks {
  DoorTrigger({
    required Vector2 position,
    required Vector2 size,
    required this.direction,
  }) : super(position: position, size: size);

  /// 문 방향
  final DoorDirection direction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 문 시각화
    final paint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // 화살표 표시
    _drawArrow(canvas);
  }

  void _drawArrow(Canvas canvas) {
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.x / 2, size.y / 2);
    final path = Path();

    switch (direction) {
      case DoorDirection.north:
        path.moveTo(center.dx, center.dy + 8);
        path.lineTo(center.dx, center.dy - 8);
        path.moveTo(center.dx - 6, center.dy - 2);
        path.lineTo(center.dx, center.dy - 8);
        path.lineTo(center.dx + 6, center.dy - 2);
      case DoorDirection.south:
        path.moveTo(center.dx, center.dy - 8);
        path.lineTo(center.dx, center.dy + 8);
        path.moveTo(center.dx - 6, center.dy + 2);
        path.lineTo(center.dx, center.dy + 8);
        path.lineTo(center.dx + 6, center.dy + 2);
      case DoorDirection.west:
        path.moveTo(center.dx + 8, center.dy);
        path.lineTo(center.dx - 8, center.dy);
        path.moveTo(center.dx - 2, center.dy - 6);
        path.lineTo(center.dx - 8, center.dy);
        path.lineTo(center.dx - 2, center.dy + 6);
      case DoorDirection.east:
        path.moveTo(center.dx - 8, center.dy);
        path.lineTo(center.dx + 8, center.dy);
        path.moveTo(center.dx + 2, center.dy - 6);
        path.lineTo(center.dx + 8, center.dy);
        path.lineTo(center.dx + 2, center.dy + 6);
    }

    canvas.drawPath(path, arrowPaint);
  }
}
