/// Arcana: The Three Hearts - 게임 상태 관리
/// Riverpod 기반 게임 상태 Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 게임 상태
enum GameStatus {
  mainMenu,  // 메인 메뉴
  playing,   // 플레이 중
  paused,    // 일시정지
  gameOver,  // 게임 오버
  victory,   // 승리
}

/// 게임 상태 데이터
class GameState {
  const GameState({
    this.status = GameStatus.mainMenu,
    this.currentFloor = 1,
    this.currentChapter = 1,
    this.score = 0,
    this.playTime = Duration.zero,
    this.enemiesKilled = 0,
    this.itemsCollected = 0,
    this.heartsAcquired = const [false, false, false],
    this.flags = const {},
  });

  /// 현재 상태
  final GameStatus status;

  /// 현재 층
  final int currentFloor;

  /// 현재 챕터 (1-6)
  final int currentChapter;

  /// 점수
  final int score;

  /// 플레이 시간
  final Duration playTime;

  /// 처치한 적 수
  final int enemiesKilled;

  /// 획득한 아이템 수
  final int itemsCollected;

  /// 획득한 심장 [첫번째, 두번째, 세번째]
  final List<bool> heartsAcquired;

  /// 스토리 플래그
  final Map<String, bool> flags;

  /// 획득한 심장 개수
  int get heartCount => heartsAcquired.where((h) => h).length;

  /// 특정 심장 보유 여부
  bool hasHeart(int heartIndex) {
    if (heartIndex < 1 || heartIndex > 3) return false;
    return heartsAcquired[heartIndex - 1];
  }

  /// 플래그 확인
  bool getFlag(String flagName) => flags[flagName] ?? false;

  /// 복사본 생성
  GameState copyWith({
    GameStatus? status,
    int? currentFloor,
    int? currentChapter,
    int? score,
    Duration? playTime,
    int? enemiesKilled,
    int? itemsCollected,
    List<bool>? heartsAcquired,
    Map<String, bool>? flags,
  }) {
    return GameState(
      status: status ?? this.status,
      currentFloor: currentFloor ?? this.currentFloor,
      currentChapter: currentChapter ?? this.currentChapter,
      score: score ?? this.score,
      playTime: playTime ?? this.playTime,
      enemiesKilled: enemiesKilled ?? this.enemiesKilled,
      itemsCollected: itemsCollected ?? this.itemsCollected,
      heartsAcquired: heartsAcquired ?? this.heartsAcquired,
      flags: flags ?? this.flags,
    );
  }
}

/// 게임 상태 Notifier
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  /// 게임 시작
  void startGame() {
    state = const GameState(status: GameStatus.playing);
  }

  /// 게임 일시정지
  void pauseGame() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  /// 게임 재개
  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  /// 게임 오버
  void gameOver() {
    state = state.copyWith(status: GameStatus.gameOver);
  }

  /// 승리
  void victory() {
    state = state.copyWith(status: GameStatus.victory);
  }

  /// 메인 메뉴로
  void goToMainMenu() {
    state = const GameState(status: GameStatus.mainMenu);
  }

  /// 다음 층으로
  void nextFloor() {
    state = state.copyWith(currentFloor: state.currentFloor + 1);
  }

  /// 점수 추가
  void addScore(int points) {
    state = state.copyWith(score: state.score + points);
  }

  /// 적 처치 카운트 증가
  void incrementEnemiesKilled() {
    state = state.copyWith(enemiesKilled: state.enemiesKilled + 1);
  }

  /// 아이템 획득 카운트 증가
  void incrementItemsCollected() {
    state = state.copyWith(itemsCollected: state.itemsCollected + 1);
  }

  /// 플레이 시간 업데이트
  void updatePlayTime(Duration time) {
    state = state.copyWith(playTime: time);
  }

  /// 게임 재시작
  void restartGame() {
    state = const GameState(status: GameStatus.playing);
  }

  /// 다음 챕터로
  void nextChapter() {
    state = state.copyWith(currentChapter: state.currentChapter + 1);
  }

  /// 챕터 설정
  void setChapter(int chapter) {
    state = state.copyWith(currentChapter: chapter.clamp(1, 6));
  }

  /// 심장 획득
  void acquireHeart(int heartIndex) {
    if (heartIndex < 1 || heartIndex > 3) return;
    final newHearts = List<bool>.from(state.heartsAcquired);
    newHearts[heartIndex - 1] = true;
    state = state.copyWith(heartsAcquired: newHearts);
  }

  /// 플래그 설정
  void setFlag(String flagName, {bool value = true}) {
    final newFlags = Map<String, bool>.from(state.flags);
    newFlags[flagName] = value;
    state = state.copyWith(flags: newFlags);
  }

  /// 플래그 토글
  void toggleFlag(String flagName) {
    final currentValue = state.flags[flagName] ?? false;
    setFlag(flagName, value: !currentValue);
  }

  /// 세이브 데이터에서 로드
  void loadFromSave({
    required int floor,
    required int hearts,
    required int score,
    required int enemiesKilled,
    required int itemsCollected,
    required Duration playTime,
  }) {
    // 심장 상태 복원
    final heartsAcquired = [
      hearts >= 1,
      hearts >= 2,
      hearts >= 3,
    ];

    state = GameState(
      status: GameStatus.playing,
      currentFloor: floor,
      currentChapter: floor.clamp(1, 6),
      score: score,
      playTime: playTime,
      enemiesKilled: enemiesKilled,
      itemsCollected: itemsCollected,
      heartsAcquired: heartsAcquired,
      flags: const {},
    );
  }
}

/// 게임 상태 Provider
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
