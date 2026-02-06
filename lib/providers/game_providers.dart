/// Arcana: The Three Hearts - 게임 상태 Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/player_state.dart';
import '../data/models/game_state.dart';
import '../data/services/database_service.dart';

/// DatabaseService Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// 플레이어 상태 Notifier
class PlayerStateNotifier extends StateNotifier<PlayerState> {
  PlayerStateNotifier() : super(PlayerState());

  void updateHp(double hp) {
    state = state.copyWith(hp: hp.clamp(0, state.maxHp));
  }

  void updateMana(double mana) {
    state = state.copyWith(mana: mana.clamp(0, state.maxMana));
  }

  void addMana(double amount) {
    updateMana(state.mana + amount);
  }

  void useMana(double amount) {
    updateMana(state.mana - amount);
  }

  void addGold(int amount) {
    state = state.copyWith(gold: state.gold + amount);
  }

  void spendGold(int amount) {
    if (state.gold >= amount) {
      state = state.copyWith(gold: state.gold - amount);
    }
  }

  void updateHeartGauge(int gauge) {
    state = state.copyWith(heartGauge: gauge.clamp(0, 100));
  }

  void addHeartGauge(int amount) {
    updateHeartGauge(state.heartGauge + amount);
  }

  void resetHeartGauge() {
    state = state.copyWith(heartGauge: 0);
  }

  void addExp(int amount) {
    var newExp = state.exp + amount;
    var newLevel = state.level;
    var newMaxHp = state.maxHp;
    var newMaxMana = state.maxMana;

    // 레벨업 체크
    while (newExp >= newLevel * 100) {
      newExp -= newLevel * 100;
      newLevel++;
      newMaxHp += 10;
      newMaxMana += 5;
    }

    state = state.copyWith(
      exp: newExp,
      level: newLevel,
      maxHp: newMaxHp,
      maxMana: newMaxMana,
      hp: newLevel > state.level ? newMaxHp : state.hp, // 레벨업 시 풀 회복
      mana: newLevel > state.level ? newMaxMana : state.mana,
    );
  }

  void setSkill(int slotIndex, String? skillId) {
    final newSlots = SkillSlots(
      q: state.skillSlots.q,
      w: state.skillSlots.w,
      e: state.skillSlots.e,
      r: state.skillSlots.r,
    );
    newSlots.setSkillAt(slotIndex, skillId);
    state = state.copyWith(skillSlots: newSlots);
  }

  void startSkillCooldown(String skillId, double cooldown) {
    final newCooldowns = Map<String, double>.from(state.skillCooldowns);
    newCooldowns[skillId] = cooldown;
    state = state.copyWith(skillCooldowns: newCooldowns);
  }

  void updateSkillCooldowns(double dt) {
    final newCooldowns = <String, double>{};
    for (final entry in state.skillCooldowns.entries) {
      final remaining = entry.value - dt;
      if (remaining > 0) {
        newCooldowns[entry.key] = remaining;
      }
    }
    state = state.copyWith(skillCooldowns: newCooldowns);
  }

  bool isSkillOnCooldown(String skillId) {
    return state.skillCooldowns.containsKey(skillId) &&
        state.skillCooldowns[skillId]! > 0;
  }

  double getSkillCooldown(String skillId) {
    return state.skillCooldowns[skillId] ?? 0;
  }

  void collectHeart(String heartType) {
    final newHearts = HeartCollection(
      courage: state.hearts.courage,
      wisdom: state.hearts.wisdom,
      love: state.hearts.love,
    );

    switch (heartType) {
      case 'courage':
        newHearts.courage = true;
      case 'wisdom':
        newHearts.wisdom = true;
      case 'love':
        newHearts.love = true;
    }

    state = state.copyWith(hearts: newHearts);
  }

  void loadState(PlayerState newState) {
    state = newState;
  }

  void reset() {
    state = PlayerState();
  }
}

/// 게임 상태 Notifier
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState());

  void setChapter(int chapter) {
    state = state.copyWith(currentChapter: chapter);
  }

  void setFloor(int floor) {
    state = state.copyWith(currentFloor: floor);
  }

  void setRoom(int room) {
    state = state.copyWith(currentRoom: room);
  }

  void nextFloor() {
    state = state.copyWith(currentFloor: state.currentFloor + 1);
  }

  void addPlayTime(int seconds) {
    state = state.copyWith(playTimeSeconds: state.playTimeSeconds + seconds);
  }

  void addDeath() {
    state = state.copyWith(totalDeaths: state.totalDeaths + 1);
  }

  void addKill() {
    state = state.copyWith(totalKills: state.totalKills + 1);
  }

  void setFlag(String flag, bool value) {
    final newFlags = Map<String, bool>.from(state.flags);
    newFlags[flag] = value;
    state = state.copyWith(flags: newFlags);
  }

  bool getFlag(String flag) {
    return state.flags[flag] ?? false;
  }

  void completeChapter(int chapter) {
    final newChapters = List<ChapterInfo>.from(state.chapters);
    if (chapter - 1 < newChapters.length) {
      newChapters[chapter - 1].isCompleted = true;
      newChapters[chapter - 1].bossDefeated = true;
    }
    // 다음 챕터 잠금 해제
    if (chapter < newChapters.length) {
      newChapters[chapter].isUnlocked = true;
    }
    state = state.copyWith(chapters: newChapters);
  }

  void discoverItem(String itemId) {
    final newItems = Map<String, bool>.from(state.discoveredItems);
    newItems[itemId] = true;
    state = state.copyWith(discoveredItems: newItems);
  }

  void discoverMonster(String monsterId) {
    final newMonsters = Map<String, bool>.from(state.discoveredMonsters);
    newMonsters[monsterId] = true;
    state = state.copyWith(discoveredMonsters: newMonsters);
  }

  void loadState(GameState newState) {
    state = newState;
  }

  void reset() {
    state = GameState();
  }
}

/// 플레이어 상태 Provider
final playerStateProvider =
    StateNotifierProvider<PlayerStateNotifier, PlayerState>((ref) {
  return PlayerStateNotifier();
});

/// 게임 상태 Provider
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

/// 저장 슬롯 목록 Provider
final saveSlotListProvider = FutureProvider<List<SaveSlot?>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllSaveSlots();
});

/// 현재 저장 슬롯 Provider
final currentSaveSlotProvider = StateProvider<int?>((ref) => null);

/// 자동 저장 타이머 (초)
final autoSaveTimerProvider = StateProvider<int>((ref) => 0);
