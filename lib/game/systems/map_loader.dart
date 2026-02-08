/// Arcana: The Three Hearts - 맵 로더 시스템
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models/game_state.dart';
import '../../data/repositories/config_repository.dart';

/// 타일 타입
enum TileType {
  floor,
  wall,
  water,
  lava,
  spike,
  exit,
}

/// 타일 데이터
class TileData {
  const TileData({
    required this.type,
    required this.x,
    required this.y,
    this.solid = false,
    this.damaging = false,
    this.damage = 0,
  });

  final TileType type;
  final int x;
  final int y;
  final bool solid;
  final bool damaging;
  final double damage;
}

/// 맵 로드 결과
class LoadedMap {
  const LoadedMap({
    required this.tiles,
    required this.width,
    required this.height,
    required this.playerSpawn,
    required this.exitPoint,
    required this.spawnPoints,
    required this.mapData,
  });

  final List<List<TileData>> tiles;
  final int width;
  final int height;
  final Vector2 playerSpawn;
  final Vector2 exitPoint;
  final List<SpawnPoint> spawnPoints;
  final MapData mapData;
}

/// 맵 로더 시스템
class MapLoader {
  static const double tileSize = 32;

  /// 맵 데이터 로드
  static LoadedMap? loadMap(String mapId) {
    final mapData = ConfigRepository.instance.getMap(mapId);
    if (mapData == null) return null;

    return _parseMap(mapData);
  }

  /// 챕터/층으로 맵 로드
  static LoadedMap? loadMapByChapterFloor(int chapter, int floor) {
    final mapData = ConfigRepository.instance.getMapByChapterFloor(chapter, floor);
    if (mapData == null) return null;

    return _parseMap(mapData);
  }

  /// 맵 데이터 파싱
  static LoadedMap _parseMap(MapData mapData) {
    final lines = mapData.layout;
    final height = lines.length;
    final width = lines.isNotEmpty ? lines[0].length : 0;

    final tiles = <List<TileData>>[];
    var playerSpawn = Vector2(mapData.playerSpawn[0] * tileSize, mapData.playerSpawn[1] * tileSize);
    var exitPoint = Vector2(mapData.exitPoint[0] * tileSize, mapData.exitPoint[1] * tileSize);

    for (int y = 0; y < height; y++) {
      final row = <TileData>[];
      final line = lines[y];

      for (int x = 0; x < line.length; x++) {
        final char = line[x];
        final tile = _parseTile(char, x, y);
        row.add(tile);

        // 특수 타일 처리
        if (char == 'P') {
          playerSpawn = Vector2(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2);
        } else if (char == 'E') {
          exitPoint = Vector2(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2);
        }
      }

      tiles.add(row);
    }

    return LoadedMap(
      tiles: tiles,
      width: width,
      height: height,
      playerSpawn: playerSpawn,
      exitPoint: exitPoint,
      spawnPoints: mapData.spawnPoints,
      mapData: mapData,
    );
  }

  /// 문자를 타일로 변환
  static TileData _parseTile(String char, int x, int y) {
    switch (char) {
      case '#':
        return TileData(type: TileType.wall, x: x, y: y, solid: true);
      case '~':
        return TileData(type: TileType.water, x: x, y: y, damaging: true, damage: 5);
      case '!':
        return TileData(type: TileType.lava, x: x, y: y, damaging: true, damage: 20);
      case '^':
        return TileData(type: TileType.spike, x: x, y: y, damaging: true, damage: 10);
      case 'E':
        return TileData(type: TileType.exit, x: x, y: y);
      case '.':
      case 'P':
      case 'M':
      case 'T':
      case 'N':
      case 'B':
      default:
        return TileData(type: TileType.floor, x: x, y: y);
    }
  }
}

/// 맵 렌더링 컴포넌트
class MapComponent extends PositionComponent {
  MapComponent({
    required this.loadedMap,
  }) : super(
          size: Vector2(
            loadedMap.width * MapLoader.tileSize,
            loadedMap.height * MapLoader.tileSize,
          ),
          priority: -10, // 항상 배경으로 렌더링 (다른 컴포넌트보다 먼저)
        );

  final LoadedMap loadedMap;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final tileSize = MapLoader.tileSize;

    for (int y = 0; y < loadedMap.tiles.length; y++) {
      for (int x = 0; x < loadedMap.tiles[y].length; x++) {
        final tile = loadedMap.tiles[y][x];
        final rect = Rect.fromLTWH(
          x * tileSize,
          y * tileSize,
          tileSize,
          tileSize,
        );

        _renderTile(canvas, tile, rect);
      }
    }
  }

  void _renderTile(Canvas canvas, TileData tile, Rect rect) {
    Color color;
    switch (tile.type) {
      case TileType.floor:
        color = const Color(0xFF3a3a5a);
      case TileType.wall:
        color = const Color(0xFF1a1a2e);
      case TileType.water:
        color = const Color(0xFF2a4a8a);
      case TileType.lava:
        color = const Color(0xFFaa3a1a);
      case TileType.spike:
        color = const Color(0xFF5a5a5a);
      case TileType.exit:
        color = const Color(0xFF4a8a4a);
    }

    final paint = Paint()..color = color;
    canvas.drawRect(rect, paint);

    // 벽 테두리
    if (tile.type == TileType.wall) {
      final borderPaint = Paint()
        ..color = const Color(0xFF0a0a1e)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(rect, borderPaint);
    }

    // 출구 표시
    if (tile.type == TileType.exit) {
      final arrowPaint = Paint()
        ..color = Colors.white.withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final center = rect.center;
      canvas.drawLine(
        Offset(center.dx - 8, center.dy),
        Offset(center.dx + 8, center.dy),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 4, center.dy - 4),
        Offset(center.dx + 8, center.dy),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 4, center.dy + 4),
        Offset(center.dx + 8, center.dy),
        arrowPaint,
      );
    }

    // 스파이크 표시
    if (tile.type == TileType.spike) {
      final spikePaint = Paint()
        ..color = const Color(0xFF8a8a8a)
        ..style = PaintingStyle.fill;

      final cx = rect.center.dx;
      final cy = rect.center.dy;
      final path = Path()
        ..moveTo(cx - 6, cy + 6)
        ..lineTo(cx, cy - 6)
        ..lineTo(cx + 6, cy + 6)
        ..close();
      canvas.drawPath(path, spikePaint);
    }
  }

  /// 특정 위치의 타일 가져오기
  TileData? getTileAt(Vector2 position) {
    final x = (position.x / MapLoader.tileSize).floor();
    final y = (position.y / MapLoader.tileSize).floor();

    if (y >= 0 && y < loadedMap.tiles.length) {
      if (x >= 0 && x < loadedMap.tiles[y].length) {
        return loadedMap.tiles[y][x];
      }
    }
    return null;
  }

  /// 충돌 체크
  bool isColliding(Vector2 position, Vector2 size) {
    // 충돌 히트박스를 스프라이트보다 작게 (1타일 통로 통과 가능하도록)
    // 가로 12px, 세로 12px 히트박스 (중심 기준 ±6)
    const double halfW = 6;
    const double halfH = 6;

    final corners = [
      Vector2(position.x - halfW, position.y - halfH),
      Vector2(position.x + halfW, position.y - halfH),
      Vector2(position.x - halfW, position.y + halfH),
      Vector2(position.x + halfW, position.y + halfH),
    ];

    for (final corner in corners) {
      final tile = getTileAt(corner);
      if (tile != null && tile.solid) {
        return true;
      }
    }
    return false;
  }

  /// 위치의 데미지 타일 체크
  double getDamageAt(Vector2 position) {
    final tile = getTileAt(position);
    if (tile != null && tile.damaging) {
      return tile.damage;
    }
    return 0;
  }
}
