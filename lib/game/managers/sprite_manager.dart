/// Arcana: The Three Hearts - 스프라이트 매니저
/// Gemini 생성 32x32 스프라이트 사용
library;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'dart:ui' as ui;

/// 스프라이트 매니저 - 싱글톤
class SpriteManager {
  SpriteManager._();
  static final SpriteManager instance = SpriteManager._();

  /// 초기화 여부
  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// 타일 크기 (32x32)
  static const int tileSize = 32;

  /// 로드된 스프라이트들
  final Map<String, Sprite> _sprites = {};

  /// 초기화 - Gemini 스프라이트 로드
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 플레이어 캐릭터 (방향별)
      await _loadSprite('knight_down', 'sprites/gemini_split/knight_down_1.png');
      await _loadSprite('knight_left', 'sprites/gemini_split/knight_left_1.png');
      await _loadSprite('knight_right', 'sprites/gemini_split/knight_left_2.png'); // 좌우 반전 대용
      await _loadSprite('knight_up', 'sprites/gemini_split/knight_up_1.png');

      // 적 캐릭터
      await _loadSprite('slime', 'sprites/gemini_split/slime.png');
      await _loadSprite('goblin', 'sprites/split/creatures/creature_0_2.png');

      // 타일
      await _loadSprite('grass', 'sprites/gemini_split/tile_grass1.png');
      await _loadSprite('grass2', 'sprites/gemini_split/tile_grass2.png');
      await _loadSprite('dirt', 'sprites/gemini_split/tile_dirt.png');
      await _loadSprite('stone', 'sprites/gemini_split/tile_stone.png');
      await _loadSprite('water', 'sprites/gemini_split/tile_water.png');
      await _loadSprite('tree', 'sprites/gemini_split/tile_tree.png');
      await _loadSprite('rock', 'sprites/gemini_split/tile_rock.png');

      _initialized = true;
      // ignore: avoid_print
      print('SpriteManager: ${_sprites.length}개 Gemini 스프라이트 로드 완료');
    } catch (e) {
      // ignore: avoid_print
      print('SpriteManager 로딩 실패: $e');
      _initialized = false;
    }
  }

  /// 개별 스프라이트 파일 로드
  Future<void> _loadSprite(String name, String path) async {
    try {
      final image = await Flame.images.load(path);
      _sprites[name] = Sprite(image);
    } catch (e) {
      // ignore: avoid_print
      print('스프라이트 로드 실패 ($name): $e');
    }
  }

  /// 스프라이트 가져오기
  Sprite? getSprite(String name) => _sprites[name];

  // ========== 플레이어 스프라이트 (방향별) ==========
  Sprite? get playerKnight => _sprites['knight_down'];
  Sprite? get playerKnightDown => _sprites['knight_down'];
  Sprite? get playerKnightLeft => _sprites['knight_left'];
  Sprite? get playerKnightRight => _sprites['knight_right'];
  Sprite? get playerKnightUp => _sprites['knight_up'];

  // ========== 적 스프라이트 ==========
  Sprite? get slimeGreen => _sprites['slime'];
  Sprite? get goblin => _sprites['goblin'];

  // ========== 타일 스프라이트 ==========
  Sprite? get grassTile => _sprites['grass'];
  Sprite? get grassTile2 => _sprites['grass2'];
  Sprite? get dirtTile => _sprites['dirt'];
  Sprite? get stoneTile => _sprites['stone'];
  Sprite? get waterTile => _sprites['water'];
  Sprite? get tree => _sprites['tree'];
  Sprite? get rock => _sprites['rock'];

  // ========== 하위 호환성 ==========
  Sprite? get enemyWarriorDown => _sprites['goblin'];
  Sprite? get enemyRogueDown => _sprites['goblin'];
}
