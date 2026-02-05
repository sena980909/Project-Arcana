/// Arcana: The Three Hearts - 방 데이터 모델
/// 던전 생성용 방 정의
library;

import 'package:flame/components.dart';

/// 방 타입
enum RoomType {
  start,    // 시작 방 (플레이어 스폰)
  normal,   // 일반 방 (적 + 아이템)
  combat,   // 전투 방 (적 다수)
  treasure, // 보물 방 (아이템만)
  shop,     // 상점 방
  rest,     // 휴식 방
  boss,     // 보스 방
}

/// 문 방향
enum DoorDirection {
  north,
  south,
  east,
  west,
}

/// 방 데이터 클래스
class Room {
  Room({
    required this.id,
    required this.type,
    required this.width,
    required this.height,
    required this.gridPosition,
    this.doors = const {},
    this.enemySpawnPoints = const [],
    this.itemSpawnPoints = const [],
    this.isCleared = false,
  });

  /// 고유 식별자
  final int id;

  /// 방 타입
  final RoomType type;

  /// 방 너비 (타일 수)
  final int width;

  /// 방 높이 (타일 수)
  final int height;

  /// 던전 그리드 상 위치
  final Vector2 gridPosition;

  /// 문 위치 (방향 -> 연결된 방 ID)
  final Map<DoorDirection, int> doors;

  /// 적 스폰 포인트 (방 내 상대 좌표)
  final List<Vector2> enemySpawnPoints;

  /// 아이템 스폰 포인트
  final List<Vector2> itemSpawnPoints;

  /// 방 클리어 여부
  bool isCleared;

  /// 월드 좌표 계산 (타일 크기 32 기준)
  Vector2 get worldPosition => Vector2(
        gridPosition.x * width * 32,
        gridPosition.y * height * 32,
      );

  /// 방 중심 월드 좌표
  Vector2 get centerWorldPosition => Vector2(
        worldPosition.x + (width * 32) / 2,
        worldPosition.y + (height * 32) / 2,
      );

  /// 복사본 생성
  Room copyWith({
    int? id,
    RoomType? type,
    int? width,
    int? height,
    Vector2? gridPosition,
    Map<DoorDirection, int>? doors,
    List<Vector2>? enemySpawnPoints,
    List<Vector2>? itemSpawnPoints,
    bool? isCleared,
  }) {
    return Room(
      id: id ?? this.id,
      type: type ?? this.type,
      width: width ?? this.width,
      height: height ?? this.height,
      gridPosition: gridPosition ?? this.gridPosition,
      doors: doors ?? this.doors,
      enemySpawnPoints: enemySpawnPoints ?? this.enemySpawnPoints,
      itemSpawnPoints: itemSpawnPoints ?? this.itemSpawnPoints,
      isCleared: isCleared ?? this.isCleared,
    );
  }
}

/// 던전 데이터
class Dungeon {
  Dungeon({
    required this.rooms,
    required this.startRoomId,
    required this.bossRoomId,
  });

  /// 모든 방 목록
  final List<Room> rooms;

  /// 시작 방 ID
  final int startRoomId;

  /// 보스 방 ID
  final int bossRoomId;

  /// ID로 방 찾기
  Room? getRoomById(int id) {
    try {
      return rooms.firstWhere((room) => room.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 시작 방 가져오기
  Room get startRoom => getRoomById(startRoomId)!;

  /// 보스 방 가져오기
  Room get bossRoom => getRoomById(bossRoomId)!;
}
