/// Arcana: The Three Hearts - 게임 맵
/// 코드 기반 타일맵 생성 + 환경 장식
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 타일 타입
enum TileType {
  grass,
  dirt,
  stone,
  water,
  wall,
}

/// 게임 맵 컴포넌트
class GameMap extends Component {
  static const double tileSize = 32.0;
  static const int mapWidth = 20;
  static const int mapHeight = 15;

  final Random _random = Random(42); // 시드 고정으로 일관된 맵 생성

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 타일 생성
    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        final isWall =
            x == 0 || y == 0 || x == mapWidth - 1 || y == mapHeight - 1;

        final tileType = isWall ? TileType.wall : _getTileType(x, y);

        add(
          MapTile(
            position: Vector2(x * tileSize, y * tileSize),
            tileType: tileType,
            variation: _random.nextInt(4),
          ),
        );

        // 바닥 타일에 장식 추가 (랜덤)
        if (!isWall && _random.nextDouble() < 0.15) {
          _addDecoration(x, y);
        }
      }
    }

    // 장애물 추가 (바위, 나무)
    _addObstacles();
  }

  /// 위치에 따른 타일 타입 결정
  TileType _getTileType(int x, int y) {
    // Perlin-like 노이즈 시뮬레이션
    final noise = _simpleNoise(x, y);

    if (noise < 0.3) {
      return TileType.grass;
    } else if (noise < 0.6) {
      return TileType.dirt;
    } else {
      return TileType.stone;
    }
  }

  /// 간단한 노이즈 함수
  double _simpleNoise(int x, int y) {
    // 여러 주파수의 sin/cos 조합
    final n1 = sin(x * 0.3) * cos(y * 0.3);
    final n2 = sin(x * 0.7 + 1.3) * cos(y * 0.5 + 0.7);
    final n3 = sin((x + y) * 0.2);

    return ((n1 + n2 + n3) / 3 + 1) / 2; // 0~1 범위로 정규화
  }

  /// 장식 오브젝트 추가
  void _addDecoration(int x, int y) {
    final decorationType = _random.nextInt(5);
    final offset = Vector2(
      _random.nextDouble() * 16 - 8,
      _random.nextDouble() * 16 - 8,
    );

    add(
      MapDecoration(
        position: Vector2(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2) + offset,
        decorationType: decorationType,
      ),
    );
  }

  /// 장애물 추가
  void _addObstacles() {
    // 몇 개의 바위 추가
    final rockPositions = [
      Vector2(5, 4),
      Vector2(14, 3),
      Vector2(8, 10),
      Vector2(16, 8),
      Vector2(3, 11),
    ];

    for (final pos in rockPositions) {
      add(
        RockObstacle(
          position: Vector2(pos.x * tileSize, pos.y * tileSize),
          rockSize: _random.nextDouble() < 0.5 ? 1 : 2,
        ),
      );
    }

    // 몇 개의 나무 추가
    final treePositions = [
      Vector2(4, 7),
      Vector2(12, 5),
      Vector2(17, 11),
      Vector2(6, 12),
    ];

    for (final pos in treePositions) {
      add(
        TreeObstacle(
          position: Vector2(pos.x * tileSize, pos.y * tileSize),
        ),
      );
    }
  }
}

/// 개별 타일 컴포넌트
class MapTile extends PositionComponent with CollisionCallbacks {
  MapTile({
    required Vector2 position,
    required this.tileType,
    this.variation = 0,
  }) : super(
          position: position,
          size: Vector2(GameMap.tileSize, GameMap.tileSize),
        );

  final TileType tileType;
  final int variation;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 벽에만 충돌 히트박스 추가
    if (tileType == TileType.wall) {
      add(
        RectangleHitbox(
          size: size,
          collisionType: CollisionType.passive,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 기본 타일 색상
    final baseColor = _getTileColor();

    final paint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // 타일 디테일 그리기
    _drawTileDetail(canvas, baseColor);

    // 타일 테두리 (미세한 그리드 효과)
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
  }

  Color _getTileColor() {
    switch (tileType) {
      case TileType.grass:
        return const Color(0xFF3d6b3d); // 짙은 초록
      case TileType.dirt:
        return const Color(0xFF8b6914); // 흙색
      case TileType.stone:
        return const Color(0xFF5a5a5a); // 회색
      case TileType.water:
        return const Color(0xFF3366aa); // 물색
      case TileType.wall:
        return const Color(0xFF4a4a4a); // 벽색
    }
  }

  void _drawTileDetail(Canvas canvas, Color baseColor) {
    switch (tileType) {
      case TileType.grass:
        _drawGrassDetail(canvas);
      case TileType.dirt:
        _drawDirtDetail(canvas);
      case TileType.stone:
        _drawStoneDetail(canvas);
      case TileType.wall:
        _drawWallDetail(canvas);
      case TileType.water:
        break;
    }
  }

  /// 풀 디테일 (작은 풀잎들)
  void _drawGrassDetail(Canvas canvas) {
    final grassPaint = Paint()
      ..color = const Color(0xFF4a8c4a)
      ..style = PaintingStyle.fill;

    final random = Random(position.x.toInt() * 100 + position.y.toInt());

    // 밝은 풀 패치
    for (int i = 0; i < 3; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      final w = 4 + random.nextDouble() * 6;
      final h = 4 + random.nextDouble() * 6;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: w, height: h),
        grassPaint,
      );
    }

    // 어두운 풀 패치
    final darkGrassPaint = Paint()
      ..color = const Color(0xFF2d5a2d)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 2; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      final r = 2 + random.nextDouble() * 3;

      canvas.drawCircle(Offset(x, y), r, darkGrassPaint);
    }
  }

  /// 흙 디테일 (작은 돌멩이들)
  void _drawDirtDetail(Canvas canvas) {
    final random = Random(position.x.toInt() * 100 + position.y.toInt());

    // 밝은 부분
    final lightPaint = Paint()
      ..color = const Color(0xFF9c7a1e)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      final r = 1 + random.nextDouble() * 2;

      canvas.drawCircle(Offset(x, y), r, lightPaint);
    }

    // 어두운 부분 (작은 돌)
    final stonePaint = Paint()
      ..color = const Color(0xFF6b5010)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 2; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      final r = 1.5 + random.nextDouble() * 2;

      canvas.drawCircle(Offset(x, y), r, stonePaint);
    }
  }

  /// 돌 디테일 (균열 패턴)
  void _drawStoneDetail(Canvas canvas) {
    final random = Random(position.x.toInt() * 100 + position.y.toInt());

    // 밝은 하이라이트
    final lightPaint = Paint()
      ..color = const Color(0xFF6a6a6a)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          2 + random.nextDouble() * 4,
          2 + random.nextDouble() * 4,
          size.x * 0.3,
          size.y * 0.3,
        ),
        const Radius.circular(2),
      ),
      lightPaint,
    );

    // 어두운 균열
    final crackPaint = Paint()
      ..color = const Color(0xFF3a3a3a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    path.moveTo(random.nextDouble() * size.x, 0);
    path.lineTo(
      random.nextDouble() * size.x,
      random.nextDouble() * size.y,
    );
    path.lineTo(size.x, random.nextDouble() * size.y);

    canvas.drawPath(path, crackPaint);
  }

  /// 벽 디테일 (벽돌 패턴)
  void _drawWallDetail(Canvas canvas) {
    final brickPaint = Paint()
      ..color = const Color(0xFF3a3a3a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 수평선
    canvas.drawLine(
      Offset(0, size.y / 2),
      Offset(size.x, size.y / 2),
      brickPaint,
    );

    // 수직선 (엇갈림)
    final offset = (position.y ~/ GameMap.tileSize) % 2 == 0 ? 0.0 : size.x / 2;
    canvas.drawLine(
      Offset(size.x / 2 + offset - size.x / 2, 0),
      Offset(size.x / 2 + offset - size.x / 2, size.y / 2),
      brickPaint,
    );
    canvas.drawLine(
      Offset(offset, size.y / 2),
      Offset(offset, size.y),
      brickPaint,
    );

    // 벽 상단 하이라이트
    final highlightPaint = Paint()
      ..color = const Color(0xFF5a5a5a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      const Offset(0, 1),
      Offset(size.x, 1),
      highlightPaint,
    );
  }
}

/// 맵 장식 오브젝트 (비충돌)
class MapDecoration extends PositionComponent {
  MapDecoration({
    required Vector2 position,
    required this.decorationType,
  }) : super(
          position: position,
          anchor: Anchor.center,
          priority: 5, // 타일 위에 그려짐
        );

  final int decorationType;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (decorationType) {
      case 0:
        _drawSmallGrass(canvas);
      case 1:
        _drawFlower(canvas);
      case 2:
        _drawMushroom(canvas);
      case 3:
        _drawPebbles(canvas);
      case 4:
        _drawTallGrass(canvas);
    }
  }

  /// 작은 풀
  void _drawSmallGrass(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF5ca05c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 풀잎 3개
    canvas.drawLine(const Offset(-3, 4), const Offset(-4, -4), paint);
    canvas.drawLine(const Offset(0, 4), const Offset(0, -6), paint);
    canvas.drawLine(const Offset(3, 4), const Offset(4, -4), paint);
  }

  /// 꽃
  void _drawFlower(Canvas canvas) {
    // 줄기
    final stemPaint = Paint()
      ..color = const Color(0xFF3d8b3d)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(const Offset(0, 6), const Offset(0, -2), stemPaint);

    // 꽃잎 (노란색 또는 빨간색)
    final petalPaint = Paint()
      ..color = decorationType % 2 == 0 ? Colors.yellow : Colors.red.shade300
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * pi * 2;
      final x = cos(angle) * 3;
      final y = -4 + sin(angle) * 3;
      canvas.drawCircle(Offset(x, y), 2, petalPaint);
    }

    // 중심
    final centerPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(0, -4), 1.5, centerPaint);
  }

  /// 버섯
  void _drawMushroom(Canvas canvas) {
    // 줄기
    final stemPaint = Paint()
      ..color = const Color(0xFFe8e0d0)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2, 0, 4, 5),
        const Radius.circular(1),
      ),
      stemPaint,
    );

    // 갓
    final capPaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, 0), width: 10, height: 8),
      pi,
      pi,
      true,
      capPaint,
    );

    // 점 무늬
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(-2, -2), 1.5, dotPaint);
    canvas.drawCircle(const Offset(2, -1), 1, dotPaint);
  }

  /// 작은 돌멩이들
  void _drawPebbles(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF7a7a7a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-3, 2), width: 4, height: 3),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(2, 1), width: 5, height: 3),
      paint,
    );
    canvas.drawCircle(const Offset(0, -2), 2, paint);
  }

  /// 긴 풀
  void _drawTallGrass(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF4a9a4a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // 휘어진 풀잎들
    final path1 = Path();
    path1.moveTo(-4, 6);
    path1.quadraticBezierTo(-6, 0, -3, -8);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, 6);
    path2.quadraticBezierTo(1, -2, -1, -10);
    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(4, 6);
    path3.quadraticBezierTo(6, 0, 3, -7);
    canvas.drawPath(path3, paint);
  }
}

/// 바위 장애물
class RockObstacle extends PositionComponent with CollisionCallbacks {
  RockObstacle({
    required Vector2 position,
    this.rockSize = 1,
  }) : super(
          position: position,
          anchor: Anchor.topLeft,
          priority: 10,
        );

  /// 크기 (1 = 작은 바위, 2 = 큰 바위)
  final int rockSize;

  late final Vector2 _actualSize;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _actualSize = rockSize == 1 ? Vector2(24, 20) : Vector2(40, 32);
    size = _actualSize;

    // 충돌 히트박스
    add(
      RectangleHitbox(
        size: _actualSize * 0.8,
        position: _actualSize * 0.1,
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (rockSize == 1) {
      _drawSmallRock(canvas);
    } else {
      _drawLargeRock(canvas);
    }
  }

  void _drawSmallRock(Canvas canvas) {
    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_actualSize.x / 2, _actualSize.y - 2),
        width: _actualSize.x * 0.8,
        height: 6,
      ),
      shadowPaint,
    );

    // 바위 본체
    final rockPaint = Paint()
      ..color = const Color(0xFF6a6a6a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(2, 4, _actualSize.x - 4, _actualSize.y - 8),
      rockPaint,
    );

    // 하이라이트
    final highlightPaint = Paint()
      ..color = const Color(0xFF8a8a8a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_actualSize.x / 2 - 4, _actualSize.y / 2 - 2),
        width: 8,
        height: 6,
      ),
      highlightPaint,
    );

    // 어두운 부분
    final darkPaint = Paint()
      ..color = const Color(0xFF4a4a4a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_actualSize.x / 2 + 4, _actualSize.y / 2 + 2),
        width: 6,
        height: 4,
      ),
      darkPaint,
    );
  }

  void _drawLargeRock(Canvas canvas) {
    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_actualSize.x / 2, _actualSize.y - 3),
        width: _actualSize.x * 0.9,
        height: 8,
      ),
      shadowPaint,
    );

    // 바위 본체 (여러 층)
    final rockPaint = Paint()
      ..color = const Color(0xFF5a5a5a)
      ..style = PaintingStyle.fill;

    // 아래 부분
    canvas.drawOval(
      Rect.fromLTWH(2, _actualSize.y * 0.4, _actualSize.x - 4, _actualSize.y * 0.5),
      rockPaint,
    );

    // 위 부분
    final topRockPaint = Paint()
      ..color = const Color(0xFF6a6a6a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(4, 4, _actualSize.x - 8, _actualSize.y * 0.5),
      topRockPaint,
    );

    // 하이라이트
    final highlightPaint = Paint()
      ..color = const Color(0xFF8a8a8a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_actualSize.x / 2 - 6, _actualSize.y / 3),
        width: 12,
        height: 8,
      ),
      highlightPaint,
    );

    // 균열
    final crackPaint = Paint()
      ..color = const Color(0xFF3a3a3a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    path.moveTo(_actualSize.x * 0.6, _actualSize.y * 0.3);
    path.lineTo(_actualSize.x * 0.5, _actualSize.y * 0.5);
    path.lineTo(_actualSize.x * 0.7, _actualSize.y * 0.7);
    canvas.drawPath(path, crackPaint);
  }
}

/// 나무 장애물
class TreeObstacle extends PositionComponent with CollisionCallbacks {
  TreeObstacle({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(32, 48),
          anchor: Anchor.topLeft,
          priority: 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 나무 기둥만 충돌 (아래쪽)
    add(
      RectangleHitbox(
        size: Vector2(12, 16),
        position: Vector2(10, 32),
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 2),
        width: 24,
        height: 8,
      ),
      shadowPaint,
    );

    // 나무 기둥
    final trunkPaint = Paint()
      ..color = const Color(0xFF5a3d2b)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x / 2 - 5, 24, 10, 24),
        const Radius.circular(2),
      ),
      trunkPaint,
    );

    // 기둥 디테일
    final trunkDetailPaint = Paint()
      ..color = const Color(0xFF4a2d1b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.x / 2 - 2, 28),
      Offset(size.x / 2 - 2, 44),
      trunkDetailPaint,
    );
    canvas.drawLine(
      Offset(size.x / 2 + 2, 30),
      Offset(size.x / 2 + 2, 42),
      trunkDetailPaint,
    );

    // 나뭇잎 (여러 층)
    final leafPaint1 = Paint()
      ..color = const Color(0xFF2d7a2d)
      ..style = PaintingStyle.fill;

    final leafPaint2 = Paint()
      ..color = const Color(0xFF3d9a3d)
      ..style = PaintingStyle.fill;

    final leafPaint3 = Paint()
      ..color = const Color(0xFF4aaa4a)
      ..style = PaintingStyle.fill;

    // 아래 잎
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, 22),
        width: 30,
        height: 16,
      ),
      leafPaint1,
    );

    // 중간 잎
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, 14),
        width: 26,
        height: 14,
      ),
      leafPaint2,
    );

    // 위 잎
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, 6),
        width: 20,
        height: 12,
      ),
      leafPaint3,
    );

    // 잎 하이라이트
    final highlightPaint = Paint()
      ..color = const Color(0xFF5aba5a)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2 - 4, 10),
        width: 8,
        height: 6,
      ),
      highlightPaint,
    );
  }
}
