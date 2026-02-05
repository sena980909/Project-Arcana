/// Arcana: The Three Hearts - 에셋 경로 상수
/// PRD 3.2 프로젝트 구조에 따른 에셋 경로 중앙 관리
library;

/// 이미지 에셋 경로
class ImageAssets {
  ImageAssets._();

  // 기본 경로
  static const String _basePath = 'assets/images';

  // 캐릭터
  static const String characters = '$_basePath/characters';
  static const String player = '$characters/player.png';

  // 적
  static const String enemies = '$_basePath/enemies';

  // 타일맵
  static const String tiles = '$_basePath/tiles';

  // UI
  static const String ui = '$_basePath/ui';
  static const String heartFull = '$ui/heart_full.png';
  static const String heartEmpty = '$ui/heart_empty.png';
}

/// 오디오 에셋 경로
class AudioAssets {
  AudioAssets._();

  // 기본 경로
  static const String _basePath = 'assets/audio';

  // BGM (.ogg 권장)
  static const String bgm = '$_basePath/bgm';
  static const String bgmForest = '$bgm/forest.ogg';
  static const String bgmCave = '$bgm/cave.ogg';
  static const String bgmFortress = '$bgm/fortress.ogg';

  // SFX (.wav 권장)
  static const String sfx = '$_basePath/sfx';
  static const String sfxHit = '$sfx/hit.wav';
  static const String sfxDeath = '$sfx/death.wav';
  static const String sfxPickup = '$sfx/pickup.wav';
}

/// 폰트 에셋
class FontAssets {
  FontAssets._();

  static const String dungGeunMo = 'DungGeunMo';
}
