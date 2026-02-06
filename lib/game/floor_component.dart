/// Arcana: The Three Hearts - 바닥 컴포넌트
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 바닥 타일 컴포넌트
class FloorComponent extends PositionComponent with HasGameRef {
  FloorComponent()
      : super(
          position: Vector2.zero(),
          size: Vector2(1600, 1200),
          anchor: Anchor.topLeft,
        );

  static const String _assetPath =
      'itchio/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/';

  late List<Sprite> _floorSprites;
  late List<List<int>> _tileMap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 바닥 스프라이트 로드
    _floorSprites = [];
    for (int i = 1; i <= 8; i++) {
      try {
        final sprite = await Sprite.load('${_assetPath}floor_$i.png');
        _floorSprites.add(sprite);
      } catch (e) {
        // 스프라이트 로드 실패 시 무시
      }
    }

    // 타일맵 생성 (랜덤)
    final random = Random(42); // 고정 시드로 일관된 맵
    final tilesX = (size.x / 16).ceil();
    final tilesY = (size.y / 16).ceil();

    _tileMap = List.generate(
      tilesY,
      (y) => List.generate(
        tilesX,
        (x) => random.nextInt(_floorSprites.isEmpty ? 1 : _floorSprites.length),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (_floorSprites.isEmpty) {
      // 스프라이트가 없으면 단색 바닥
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFF3a3a5c),
      );
      return;
    }

    // 타일 그리기
    const tileSize = 16.0;

    for (int y = 0; y < _tileMap.length; y++) {
      for (int x = 0; x < _tileMap[y].length; x++) {
        final spriteIndex = _tileMap[y][x];
        if (spriteIndex < _floorSprites.length) {
          _floorSprites[spriteIndex].render(
            canvas,
            position: Vector2(x * tileSize, y * tileSize),
            size: Vector2(tileSize, tileSize),
          );
        }
      }
    }
  }
}
