/// Arcana: The Three Hearts - 오디오 관리자
/// BGM 및 효과음 관리
library;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// 효과음 타입
enum SoundEffect {
  playerAttack,
  playerHit,
  playerDeath,
  enemyHit,
  enemyDeath,
  itemPickup,
  doorOpen,
  buttonClick,
  levelUp,
  bossAppear,
  victory,
}

/// BGM 타입
enum BgmTrack {
  mainMenu,
  dungeon,
  combat,
  boss,
  victory,
  gameOver,
  // 챕터별 던전 BGM
  chapter1Dungeon,
  chapter2Dungeon,
  chapter3Dungeon,
  chapter4Dungeon,
  chapter5Dungeon,
  chapter6Dungeon,
  // 챕터별 보스 BGM
  chapter1Boss,
  chapter2Boss,
  chapter3Boss,
  chapter3BossSilence, // 챕터 3 Phase 3: 무음
  chapter4Boss,
  chapter5Boss,
  chapter6Boss,
  chapter6BossFinal, // 최종 보스 Phase 4
  // 안전 지대 BGM
  safe,
}

/// 오디오 관리자
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  /// BGM 볼륨 (0.0 ~ 1.0)
  double _bgmVolume = 0.7;

  /// 효과음 볼륨 (0.0 ~ 1.0)
  double _sfxVolume = 1.0;

  /// BGM 활성화 여부
  bool _bgmEnabled = true;

  /// 효과음 활성화 여부
  bool _sfxEnabled = true;

  /// 현재 재생 중인 BGM
  BgmTrack? _currentBgm;

  /// 초기화 여부
  bool _initialized = false;

  /// BGM 볼륨 게터
  double get bgmVolume => _bgmVolume;

  /// 효과음 볼륨 게터
  double get sfxVolume => _sfxVolume;

  /// BGM 활성화 여부 게터
  bool get bgmEnabled => _bgmEnabled;

  /// 효과음 활성화 여부 게터
  bool get sfxEnabled => _sfxEnabled;

  /// 현재 BGM 게터
  BgmTrack? get currentBgm => _currentBgm;

  /// 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 오디오 캐시 프리로드
      await FlameAudio.audioCache.loadAll([
        'sfx/attack.wav',
        'sfx/player_hit.wav',
        'sfx/player_death.wav',
        'sfx/enemy_hit.wav',
        'sfx/enemy_death.wav',
        'sfx/pickup.wav',
        'sfx/click.wav',
        'sfx/level_up.wav',
        'sfx/boss_appear.wav',
        'sfx/victory.wav',
      ]);

      _sfxEnabled = true;
      _bgmEnabled = true;
      _initialized = true;
      debugPrint('AudioManager initialized successfully');
    } catch (e) {
      // 오디오 초기화 실패 시 graceful 처리
      _sfxEnabled = false;
      _bgmEnabled = false;
      _initialized = true;
      debugPrint('AudioManager initialized with audio disabled: $e');
    }
  }

  /// 효과음 재생
  Future<void> playSfx(SoundEffect effect) async {
    if (!_sfxEnabled || !_initialized) return;

    final fileName = _getSfxFileName(effect);
    if (fileName == null) return;

    try {
      await FlameAudio.play(fileName, volume: _sfxVolume);
    } catch (e) {
      debugPrint('Failed to play SFX: $e');
    }
  }

  /// BGM 재생
  Future<void> playBgm(BgmTrack track) async {
    if (!_bgmEnabled || !_initialized) return;
    if (_currentBgm == track) return;

    final fileName = _getBgmFileName(track);
    if (fileName == null) return;

    try {
      await stopBgm();
      await FlameAudio.bgm.play(fileName, volume: _bgmVolume);
      _currentBgm = track;
    } catch (e) {
      debugPrint('Failed to play BGM: $e');
    }
  }

  /// BGM 정지
  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
      _currentBgm = null;
    } catch (e) {
      debugPrint('Failed to stop BGM: $e');
    }
  }

  /// BGM 일시정지
  Future<void> pauseBgm() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      debugPrint('Failed to pause BGM: $e');
    }
  }

  /// BGM 재개
  Future<void> resumeBgm() async {
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      debugPrint('Failed to resume BGM: $e');
    }
  }

  /// BGM 볼륨 설정
  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
  }

  /// 효과음 볼륨 설정
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// BGM 활성화 토글
  void toggleBgm() {
    _bgmEnabled = !_bgmEnabled;
    if (!_bgmEnabled) {
      stopBgm();
    }
  }

  /// 효과음 활성화 토글
  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  /// 모든 오디오 정지
  Future<void> stopAll() async {
    await stopBgm();
  }

  /// 리소스 해제
  Future<void> dispose() async {
    await stopAll();
    FlameAudio.audioCache.clearAll();
    _initialized = false;
  }

  /// 효과음 파일명 매핑
  String? _getSfxFileName(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.playerAttack:
        return 'sfx/attack.wav';
      case SoundEffect.playerHit:
        return 'sfx/player_hit.wav';
      case SoundEffect.playerDeath:
        return 'sfx/player_death.wav';
      case SoundEffect.enemyHit:
        return 'sfx/enemy_hit.wav';
      case SoundEffect.enemyDeath:
        return 'sfx/enemy_death.wav';
      case SoundEffect.itemPickup:
        return 'sfx/pickup.wav';
      case SoundEffect.doorOpen:
        return 'sfx/click.wav';
      case SoundEffect.buttonClick:
        return 'sfx/click.wav';
      case SoundEffect.levelUp:
        return 'sfx/level_up.wav';
      case SoundEffect.bossAppear:
        return 'sfx/boss_appear.wav';
      case SoundEffect.victory:
        return 'sfx/victory.wav';
    }
  }

  /// BGM 파일명 매핑
  String? _getBgmFileName(BgmTrack track) {
    switch (track) {
      case BgmTrack.mainMenu:
        return 'bgm/main_menu.mp3';
      case BgmTrack.dungeon:
        return 'bgm/dungeon.mp3';
      case BgmTrack.combat:
        return 'bgm/combat.mp3';
      case BgmTrack.boss:
        return 'bgm/boss.mp3';
      case BgmTrack.victory:
        return 'bgm/victory.mp3';
      case BgmTrack.gameOver:
        return 'bgm/game_over.mp3';
      // 챕터별 던전 BGM (기본 dungeon.mp3 사용, 추후 개별 파일 추가 가능)
      case BgmTrack.chapter1Dungeon:
        return 'bgm/dungeon.mp3'; // 잊혀진 숲
      case BgmTrack.chapter2Dungeon:
        return 'bgm/dungeon.mp3'; // 무너진 성채
      case BgmTrack.chapter3Dungeon:
        return 'bgm/dungeon.mp3'; // 침묵의 성당
      case BgmTrack.chapter4Dungeon:
        return 'bgm/dungeon.mp3'; // 피의 정원
      case BgmTrack.chapter5Dungeon:
        return 'bgm/dungeon.mp3'; // 기억의 심연
      case BgmTrack.chapter6Dungeon:
        return 'bgm/dungeon.mp3'; // 망각의 옥좌
      // 챕터별 보스 BGM
      case BgmTrack.chapter1Boss:
        return 'bgm/boss.mp3'; // 이그드라
      case BgmTrack.chapter2Boss:
        return 'bgm/boss.mp3'; // 발두르
      case BgmTrack.chapter3Boss:
        return 'bgm/boss.mp3'; // 실렌시아
      case BgmTrack.chapter3BossSilence:
        return null; // 챕터 3 Phase 3: 무음 (BGM 정지)
      case BgmTrack.chapter4Boss:
        return 'bgm/boss.mp3'; // 리리아나
      case BgmTrack.chapter5Boss:
        return 'bgm/boss.mp3'; // 그림자 자아
      case BgmTrack.chapter6Boss:
        return 'bgm/boss.mp3'; // 망각의 화신
      case BgmTrack.chapter6BossFinal:
        return 'bgm/boss.mp3'; // 최종 Phase
      // 안전 지대
      case BgmTrack.safe:
        return 'bgm/safe.mp3';
    }
  }

  /// 챕터에 맞는 던전 BGM 트랙 반환
  BgmTrack getDungeonTrackForChapter(int chapter) {
    switch (chapter) {
      case 1:
        return BgmTrack.chapter1Dungeon;
      case 2:
        return BgmTrack.chapter2Dungeon;
      case 3:
        return BgmTrack.chapter3Dungeon;
      case 4:
        return BgmTrack.chapter4Dungeon;
      case 5:
        return BgmTrack.chapter5Dungeon;
      case 6:
        return BgmTrack.chapter6Dungeon;
      default:
        return BgmTrack.dungeon;
    }
  }

  /// 챕터에 맞는 보스 BGM 트랙 반환
  BgmTrack getBossTrackForChapter(int chapter) {
    switch (chapter) {
      case 1:
        return BgmTrack.chapter1Boss;
      case 2:
        return BgmTrack.chapter2Boss;
      case 3:
        return BgmTrack.chapter3Boss;
      case 4:
        return BgmTrack.chapter4Boss;
      case 5:
        return BgmTrack.chapter5Boss;
      case 6:
        return BgmTrack.chapter6Boss;
      default:
        return BgmTrack.boss;
    }
  }

  /// 챕터별 던전 BGM 재생
  Future<void> playChapterDungeonBgm(int chapter) async {
    final track = getDungeonTrackForChapter(chapter);
    await playBgm(track);
  }

  /// 챕터별 보스 BGM 재생
  Future<void> playChapterBossBgm(int chapter) async {
    final track = getBossTrackForChapter(chapter);
    await playBgm(track);
  }

  /// 챕터 3 보스 Phase 3 무음 처리
  Future<void> playChapter3SilencePhase() async {
    await stopBgm();
    _currentBgm = BgmTrack.chapter3BossSilence;
  }

  /// 챕터 6 최종 페이즈 BGM 재생
  Future<void> playFinalBossBgm() async {
    await playBgm(BgmTrack.chapter6BossFinal);
  }
}
