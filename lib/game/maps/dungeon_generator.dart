/// Arcana: The Three Hearts - 던전 생성기
/// 절차적 던전 생성 시스템
library;

import 'dart:math';

import 'package:flame/components.dart';

import '../../data/model/room.dart';

/// 던전 생성기
class DungeonGenerator {
  DungeonGenerator({
    this.seed,
    this.minRooms = 5,
    this.maxRooms = 10,
    this.roomMinSize = 8,
    this.roomMaxSize = 14,
  });

  /// 랜덤 시드 (재현성)
  final int? seed;

  /// 최소 방 개수
  final int minRooms;

  /// 최대 방 개수
  final int maxRooms;

  /// 방 최소 크기
  final int roomMinSize;

  /// 방 최대 크기
  final int roomMaxSize;

  late Random _random;

  /// 던전 생성
  Dungeon generate(int floor) {
    _random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

    final rooms = <Room>[];
    final roomCount = _random.nextInt(maxRooms - minRooms + 1) + minRooms;

    // 시작 방 생성
    final startRoom = _createRoom(
      id: 0,
      type: RoomType.start,
      gridX: 0,
      gridY: 0,
    );
    rooms.add(startRoom);

    // 추가 방 생성
    for (int i = 1; i < roomCount - 1; i++) {
      final room = _createConnectedRoom(
        id: i,
        existingRooms: rooms,
        type: _getRandomRoomType(),
      );
      if (room != null) {
        rooms.add(room);
      }
    }

    // 보스 방 생성 (마지막)
    final bossRoom = _createConnectedRoom(
      id: roomCount - 1,
      existingRooms: rooms,
      type: RoomType.boss,
    );
    if (bossRoom != null) {
      rooms.add(bossRoom);
    }

    // 방 연결
    _connectRooms(rooms);

    return Dungeon(
      rooms: rooms,
      startRoomId: startRoom.id,
      bossRoomId: bossRoom?.id ?? rooms.last.id,
    );
  }

  /// 방 생성
  Room _createRoom({
    required int id,
    required RoomType type,
    required int gridX,
    required int gridY,
  }) {
    final width = _random.nextInt(roomMaxSize - roomMinSize + 1) + roomMinSize;
    final height = _random.nextInt(roomMaxSize - roomMinSize + 1) + roomMinSize;

    return Room(
      id: id,
      type: type,
      width: width,
      height: height,
      gridPosition: Vector2(gridX.toDouble(), gridY.toDouble()),
    );
  }

  /// 기존 방과 연결된 새 방 생성
  Room? _createConnectedRoom({
    required int id,
    required List<Room> existingRooms,
    required RoomType type,
  }) {
    // 연결할 방 선택
    final sourceRoom = existingRooms[_random.nextInt(existingRooms.length)];

    // 방향 선택 (상하좌우)
    final directions = [
      (0, -1, DoorDirection.north, DoorDirection.south),
      (0, 1, DoorDirection.south, DoorDirection.north),
      (-1, 0, DoorDirection.west, DoorDirection.east),
      (1, 0, DoorDirection.east, DoorDirection.west),
    ];

    directions.shuffle(_random);

    for (final dir in directions) {
      final newX = sourceRoom.gridPosition.x.toInt() + dir.$1;
      final newY = sourceRoom.gridPosition.y.toInt() + dir.$2;

      // 이미 방이 있는지 확인
      final occupied = existingRooms.any(
        (r) =>
            r.gridPosition.x.toInt() == newX &&
            r.gridPosition.y.toInt() == newY,
      );

      if (!occupied) {
        return _createRoom(
          id: id,
          type: type,
          gridX: newX,
          gridY: newY,
        );
      }
    }

    return null;
  }

  /// 인접한 방들 연결
  void _connectRooms(List<Room> rooms) {
    for (int i = 0; i < rooms.length; i++) {
      for (int j = i + 1; j < rooms.length; j++) {
        final room1 = rooms[i];
        final room2 = rooms[j];

        // 인접한 방인지 확인
        final dx =
            room2.gridPosition.x.toInt() - room1.gridPosition.x.toInt();
        final dy =
            room2.gridPosition.y.toInt() - room1.gridPosition.y.toInt();

        if (dx.abs() + dy.abs() == 1) {
          // 인접함
          DoorDirection dir1;
          DoorDirection dir2;

          if (dx == 1) {
            dir1 = DoorDirection.east;
            dir2 = DoorDirection.west;
          } else if (dx == -1) {
            dir1 = DoorDirection.west;
            dir2 = DoorDirection.east;
          } else if (dy == 1) {
            dir1 = DoorDirection.south;
            dir2 = DoorDirection.north;
          } else {
            dir1 = DoorDirection.north;
            dir2 = DoorDirection.south;
          }

          // 문 추가
          rooms[i] = room1.copyWith(
            doors: {...room1.doors, dir1: room2.id},
          );
          rooms[j] = room2.copyWith(
            doors: {...room2.doors, dir2: room1.id},
          );
        }
      }
    }
  }

  /// 랜덤 방 타입
  RoomType _getRandomRoomType() {
    final roll = _random.nextDouble();

    if (roll < 0.5) {
      return RoomType.combat;
    } else if (roll < 0.7) {
      return RoomType.treasure;
    } else if (roll < 0.85) {
      return RoomType.shop;
    } else {
      return RoomType.rest;
    }
  }
}

/// 방을 실제 게임 컴포넌트로 변환하는 빌더
class RoomBuilder {
  /// 타일 크기
  static const double tileSize = 32;

  /// 방을 타일 데이터로 변환
  static List<List<int>> buildRoomTiles(Room room) {
    final tiles = List.generate(
      room.height,
      (y) => List.generate(room.width, (x) {
        // 테두리는 벽
        if (x == 0 || x == room.width - 1 || y == 0 || y == room.height - 1) {
          return 1; // 벽
        }
        return 0; // 바닥
      }),
    );

    // 문 위치에 바닥 타일
    for (final entry in room.doors.entries) {
      final midX = room.width ~/ 2;
      final midY = room.height ~/ 2;

      switch (entry.key) {
        case DoorDirection.north:
          tiles[0][midX] = 0;
          if (midX > 0) tiles[0][midX - 1] = 0;
          if (midX < room.width - 1) tiles[0][midX + 1] = 0;
        case DoorDirection.south:
          tiles[room.height - 1][midX] = 0;
          if (midX > 0) tiles[room.height - 1][midX - 1] = 0;
          if (midX < room.width - 1) tiles[room.height - 1][midX + 1] = 0;
        case DoorDirection.west:
          tiles[midY][0] = 0;
          if (midY > 0) tiles[midY - 1][0] = 0;
          if (midY < room.height - 1) tiles[midY + 1][0] = 0;
        case DoorDirection.east:
          tiles[midY][room.width - 1] = 0;
          if (midY > 0) tiles[midY - 1][room.width - 1] = 0;
          if (midY < room.height - 1) tiles[midY + 1][room.width - 1] = 0;
      }
    }

    return tiles;
  }

  /// 방의 중앙 위치 (월드 좌표)
  static Vector2 getRoomCenter(Room room) {
    return Vector2(
      room.width * tileSize / 2,
      room.height * tileSize / 2,
    );
  }

  /// 적 스폰 위치 목록
  static List<Vector2> getEnemySpawnPositions(Room room, int count) {
    final positions = <Vector2>[];
    final centerX = room.width * tileSize / 2;
    final centerY = room.height * tileSize / 2;
    final random = Random();

    for (int i = 0; i < count; i++) {
      final angle = (2 * 3.14159 / count) * i + random.nextDouble() * 0.5;
      final radius = 60 + random.nextDouble() * 40;

      positions.add(Vector2(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      ));
    }

    return positions;
  }

  /// 아이템 스폰 위치 (방 중앙 근처)
  static Vector2 getItemSpawnPosition(Room room) {
    final random = Random();
    return Vector2(
      room.width * tileSize / 2 + random.nextDouble() * 40 - 20,
      room.height * tileSize / 2 + random.nextDouble() * 40 - 20,
    );
  }
}
