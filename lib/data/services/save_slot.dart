/// Arcana: The Three Hearts - 저장 슬롯 데이터
library;

import '../models/player_state.dart';
import '../models/game_state.dart';

/// 저장 슬롯 데이터
class SaveSlot {
  const SaveSlot({
    required this.slot,
    required this.playerState,
    required this.gameState,
    required this.createdAt,
    required this.updatedAt,
  });

  final int slot;
  final PlayerState playerState;
  final GameState gameState;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 간략한 정보 (슬롯 선택 화면용)
  String get summary {
    final chapter = gameState.currentChapter;
    final floor = gameState.currentFloor;
    final level = playerState.level;
    final playTime = gameState.formattedPlayTime;
    return 'Ch$chapter-$floor | Lv.$level | $playTime';
  }
}
