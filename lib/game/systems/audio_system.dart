/// Arcana: The Three Hearts - 오디오 시스템
library;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// BGM 타입
enum BgmType {
  mainTitle,
  safeHaven,
  gameOver,
  forgottenForest,
  abyssalCave,
  crimsonFortress,
  combat,
  bossBattle,
  victory,
}

/// 오디오 시스템
/// BGM과 SFX를 관리합니다.
class AudioSystem {
  AudioSystem._();
  static final AudioSystem instance = AudioSystem._();

  bool _isInitialized = false;
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.5;
  double _sfxVolume = 0.7;

  String? _currentBgm;

  /// BGM 파일 매핑 (assets/bgm 폴더 기준)
  static const Map<BgmType, String> _bgmFiles = {
    BgmType.mainTitle: 'bgm/Main Title.mp3',
    BgmType.safeHaven: 'bgm/Safe Haven _ Shop.mp3',
    BgmType.gameOver: 'bgm/Game Over.mp3',
    BgmType.forgottenForest: 'bgm/The Forgotten Forest.mp3',
    BgmType.abyssalCave: 'bgm/Abyssal Cave.mp3',
    BgmType.crimsonFortress: 'bgm/Crimson Fortress.mp3',
    BgmType.combat: 'bgm/General Combat _ Horde.mp3',
    BgmType.bossBattle: 'bgm/Boss Battle - High Stakes.mp3',
    BgmType.victory: 'bgm/Victory Fanfare.mp3',
  };

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Flame Audio 초기화 - BGM 프리로드
      FlameAudio.bgm.initialize();
      _isInitialized = true;
      debugPrint('AudioSystem 초기화 완료');
    } catch (e) {
      debugPrint('AudioSystem 초기화 실패: $e');
    }
  }

  /// BGM 재생 (타입으로)
  Future<void> playBgmType(BgmType type) async {
    final filename = _bgmFiles[type];
    if (filename != null) {
      await playBgm(filename);
    }
  }

  /// BGM 재생 (파일명으로)
  Future<void> playBgm(String filename) async {
    if (!_bgmEnabled || !_isInitialized) return;
    if (_currentBgm == filename) return;

    try {
      await stopBgm();
      await FlameAudio.bgm.play(filename, volume: _bgmVolume);
      _currentBgm = filename;
      debugPrint('BGM 재생: $filename');
    } catch (e) {
      debugPrint('BGM 재생 실패: $e');
    }
  }

  /// 챕터별 BGM 재생
  Future<void> playChapterBgm(int chapter) async {
    final bgmTypes = {
      1: BgmType.forgottenForest, // 잊혀진 숲
      2: BgmType.abyssalCave,     // 심연의 동굴
      3: BgmType.crimsonFortress, // 진홍의 요새
      4: BgmType.forgottenForest, // TODO: 얼어붙은 왕국 BGM 추가
      5: BgmType.crimsonFortress, // TODO: 불타는 심장 BGM 추가
      6: BgmType.bossBattle,      // 최종 보스
    };

    final type = bgmTypes[chapter] ?? BgmType.forgottenForest;
    await playBgmType(type);
  }

  /// 보스 BGM 재생
  Future<void> playBossBgm() async {
    await playBgmType(BgmType.bossBattle);
  }

  /// 메인 타이틀 BGM
  Future<void> playMainTitleBgm() async {
    await playBgmType(BgmType.mainTitle);
  }

  /// 상점/안전지대 BGM
  Future<void> playSafeHavenBgm() async {
    await playBgmType(BgmType.safeHaven);
  }

  /// 전투 BGM
  Future<void> playCombatBgm() async {
    await playBgmType(BgmType.combat);
  }

  /// 게임 오버 BGM
  Future<void> playGameOverBgm() async {
    await playBgmType(BgmType.gameOver);
  }

  /// 승리 BGM
  Future<void> playVictoryBgm() async {
    await playBgmType(BgmType.victory);
  }

  /// BGM 정지
  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
      _currentBgm = null;
    } catch (e) {
      debugPrint('BGM 정지 실패: $e');
    }
  }

  /// BGM 일시정지
  Future<void> pauseBgm() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      debugPrint('BGM 일시정지 실패: $e');
    }
  }

  /// BGM 재개
  Future<void> resumeBgm() async {
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      debugPrint('BGM 재개 실패: $e');
    }
  }

  /// SFX 재생
  Future<void> playSfx(String filename) async {
    if (!_sfxEnabled || !_isInitialized) return;

    try {
      await FlameAudio.play(filename, volume: _sfxVolume);
    } catch (e) {
      debugPrint('SFX 재생 실패: $e');
    }
  }

  /// 공격 SFX
  Future<void> playAttackSfx([int combo = 0]) async {
    final sfxFiles = ['sfx_attack1.mp3', 'sfx_attack2.mp3', 'sfx_attack3.mp3'];
    await playSfx(sfxFiles[combo % sfxFiles.length]);
  }

  /// 피격 SFX
  Future<void> playHitSfx() async {
    await playSfx('sfx_hit.mp3');
  }

  /// 대시 SFX
  Future<void> playDashSfx() async {
    await playSfx('sfx_dash.mp3');
  }

  /// 스킬 SFX
  Future<void> playSkillSfx(String skillId) async {
    final sfxFiles = {
      'fireball': 'sfx_fire.mp3',
      'ice_shard': 'sfx_ice.mp3',
      'lightning_bolt': 'sfx_lightning.mp3',
      'flame_wave': 'sfx_fire.mp3',
      'frost_nova': 'sfx_ice.mp3',
    };

    await playSfx(sfxFiles[skillId] ?? 'sfx_skill.mp3');
  }

  /// 궁극기 SFX
  Future<void> playUltimateSfx() async {
    await playSfx('sfx_ultimate.mp3');
  }

  /// UI SFX
  Future<void> playUiSfx(String type) async {
    final sfxFiles = {
      'click': 'sfx_ui_click.mp3',
      'open': 'sfx_ui_open.mp3',
      'close': 'sfx_ui_close.mp3',
      'buy': 'sfx_ui_buy.mp3',
      'error': 'sfx_ui_error.mp3',
    };

    await playSfx(sfxFiles[type] ?? 'sfx_ui_click.mp3');
  }

  /// 적 사망 SFX
  Future<void> playEnemyDeathSfx() async {
    await playSfx('sfx_enemy_death.mp3');
  }

  /// 레벨업 SFX
  Future<void> playLevelUpSfx() async {
    await playSfx('sfx_levelup.mp3');
  }

  /// 완벽 회피 SFX
  Future<void> playPerfectDodgeSfx() async {
    await playSfx('sfx_perfect_dodge.mp3');
  }

  /// BGM 볼륨 설정
  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    // 현재 재생 중인 BGM에 적용
    try {
      FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
    } catch (e) {
      // 무시
    }
  }

  /// SFX 볼륨 설정
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// BGM 활성화/비활성화
  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (!enabled) {
      stopBgm();
    }
  }

  /// SFX 활성화/비활성화
  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  /// 현재 설정
  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  /// 리소스 해제
  Future<void> dispose() async {
    await stopBgm();
    FlameAudio.audioCache.clearAll();
    _isInitialized = false;
  }
}
