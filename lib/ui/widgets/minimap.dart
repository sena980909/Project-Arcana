/// Arcana: The Three Hearts - 미니맵
/// 던전 구조를 보여주는 미니맵 위젯
library;

import 'package:flutter/material.dart';

import '../../data/model/room.dart';

/// 미니맵 위젯
class Minimap extends StatelessWidget {
  const Minimap({
    super.key,
    required this.dungeon,
    required this.currentRoomId,
    this.size = 120,
  });

  /// 던전 데이터
  final Dungeon dungeon;

  /// 현재 방 ID
  final int currentRoomId;

  /// 미니맵 크기
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          size: Size(size, size),
          painter: _MinimapPainter(
            dungeon: dungeon,
            currentRoomId: currentRoomId,
          ),
        ),
      ),
    );
  }
}

/// 미니맵 페인터
class _MinimapPainter extends CustomPainter {
  _MinimapPainter({
    required this.dungeon,
    required this.currentRoomId,
  });

  final Dungeon dungeon;
  final int currentRoomId;

  /// 방 하나의 크기
  static const double roomSize = 16;

  /// 방 간 간격
  static const double roomGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (dungeon.rooms.isEmpty) return;

    // 방들의 범위 계산
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final room in dungeon.rooms) {
      final x = room.gridPosition.x;
      final y = room.gridPosition.y;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    // 중앙 정렬을 위한 오프셋
    final totalWidth = (maxX - minX + 1) * (roomSize + roomGap);
    final totalHeight = (maxY - minY + 1) * (roomSize + roomGap);
    final offsetX = (size.width - totalWidth) / 2;
    final offsetY = (size.height - totalHeight) / 2;

    // 연결선 먼저 그리기
    for (final room in dungeon.rooms) {
      _drawConnections(canvas, room, minX, minY, offsetX, offsetY);
    }

    // 방 그리기
    for (final room in dungeon.rooms) {
      _drawRoom(canvas, room, minX, minY, offsetX, offsetY);
    }
  }

  void _drawConnections(
    Canvas canvas,
    Room room,
    double minX,
    double minY,
    double offsetX,
    double offsetY,
  ) {
    final x = (room.gridPosition.x - minX) * (roomSize + roomGap) + offsetX;
    final y = (room.gridPosition.y - minY) * (roomSize + roomGap) + offsetY;
    final centerX = x + roomSize / 2;
    final centerY = y + roomSize / 2;

    final linePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final entry in room.doors.entries) {
      double endX = centerX;
      double endY = centerY;

      switch (entry.key) {
        case DoorDirection.north:
          endY -= roomSize / 2 + roomGap / 2;
        case DoorDirection.south:
          endY += roomSize / 2 + roomGap / 2;
        case DoorDirection.west:
          endX -= roomSize / 2 + roomGap / 2;
        case DoorDirection.east:
          endX += roomSize / 2 + roomGap / 2;
      }

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(endX, endY),
        linePaint,
      );
    }
  }

  void _drawRoom(
    Canvas canvas,
    Room room,
    double minX,
    double minY,
    double offsetX,
    double offsetY,
  ) {
    final x = (room.gridPosition.x - minX) * (roomSize + roomGap) + offsetX;
    final y = (room.gridPosition.y - minY) * (roomSize + roomGap) + offsetY;

    final isCurrentRoom = room.id == currentRoomId;

    // 방 색상
    Color roomColor;
    switch (room.type) {
      case RoomType.start:
        roomColor = Colors.green;
      case RoomType.boss:
        roomColor = Colors.red;
      case RoomType.treasure:
        roomColor = Colors.amber;
      case RoomType.shop:
        roomColor = Colors.blue;
      case RoomType.rest:
        roomColor = Colors.cyan;
      default:
        roomColor = room.isCleared ? Colors.grey : Colors.grey.shade700;
    }

    // 방 배경
    final bgPaint = Paint()
      ..color = roomColor.withValues(alpha: isCurrentRoom ? 1.0 : 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, roomSize, roomSize),
        const Radius.circular(2),
      ),
      bgPaint,
    );

    // 현재 방 테두리
    if (isCurrentRoom) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, roomSize, roomSize),
          const Radius.circular(2),
        ),
        borderPaint,
      );

      // 플레이어 위치 표시 (작은 점)
      final playerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x + roomSize / 2, y + roomSize / 2),
        3,
        playerPaint,
      );
    }

    // 방 타입 아이콘
    _drawRoomIcon(canvas, room, x, y);
  }

  void _drawRoomIcon(Canvas canvas, Room room, double x, double y) {
    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final centerX = x + roomSize / 2;
    final centerY = y + roomSize / 2;

    switch (room.type) {
      case RoomType.boss:
        // 해골 모양
        canvas.drawCircle(Offset(centerX, centerY - 2), 4, iconPaint);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(centerX, centerY + 3), width: 4, height: 3),
          iconPaint,
        );
      case RoomType.treasure:
        // 상자 모양
        canvas.drawRect(
          Rect.fromCenter(center: Offset(centerX, centerY), width: 8, height: 6),
          iconPaint,
        );
      case RoomType.shop:
        // 코인 모양
        canvas.drawCircle(Offset(centerX, centerY), 4, iconPaint);
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) {
    return oldDelegate.currentRoomId != currentRoomId ||
        oldDelegate.dungeon != dungeon;
  }
}
