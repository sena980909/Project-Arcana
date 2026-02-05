/// Arcana: The Three Hearts - 플레이어 스킬 Provider
/// 마나 및 스킬 슬롯 관리
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/skill_data.dart';

/// 플레이어 스킬 상태
class PlayerSkillState {
  const PlayerSkillState({
    this.currentMana = 100,
    this.maxMana = 100,
    this.equippedSkills = const ['', '', '', ''],
    this.skillCooldowns = const {},
    this.config = ResourceSystemConfig.defaultConfig,
  });

  /// 현재 마나
  final double currentMana;

  /// 최대 마나
  final double maxMana;

  /// 장착된 스킬 ID 목록 (4슬롯)
  final List<String> equippedSkills;

  /// 스킬별 남은 쿨다운 (초)
  final Map<String, double> skillCooldowns;

  /// 리소스 설정
  final ResourceSystemConfig config;

  /// 마나 비율
  double get manaRatio => currentMana / maxMana;

  /// 특정 슬롯의 스킬 ID
  String? getSkillAt(int slot) {
    if (slot < 0 || slot >= equippedSkills.length) return null;
    final skillId = equippedSkills[slot];
    return skillId.isEmpty ? null : skillId;
  }

  /// 스킬 쿨다운 확인
  double getCooldown(String skillId) => skillCooldowns[skillId] ?? 0;

  /// 스킬 사용 가능 여부 (쿨다운만)
  bool isSkillReady(String skillId) => getCooldown(skillId) <= 0;

  /// 마나 충분한지 확인
  bool hasEnoughMana(double cost) => currentMana >= cost;

  PlayerSkillState copyWith({
    double? currentMana,
    double? maxMana,
    List<String>? equippedSkills,
    Map<String, double>? skillCooldowns,
    ResourceSystemConfig? config,
  }) {
    return PlayerSkillState(
      currentMana: currentMana ?? this.currentMana,
      maxMana: maxMana ?? this.maxMana,
      equippedSkills: equippedSkills ?? this.equippedSkills,
      skillCooldowns: skillCooldowns ?? this.skillCooldowns,
      config: config ?? this.config,
    );
  }
}

/// 플레이어 스킬 Notifier
class PlayerSkillNotifier extends StateNotifier<PlayerSkillState> {
  PlayerSkillNotifier() : super(const PlayerSkillState());

  /// 설정 초기화
  void initialize(ResourceSystemConfig config) {
    state = PlayerSkillState(
      currentMana: config.maxMana,
      maxMana: config.maxMana,
      config: config,
    );
  }

  /// 마나 소모
  bool consumeMana(double amount) {
    if (state.currentMana < amount) return false;
    state = state.copyWith(currentMana: state.currentMana - amount);
    return true;
  }

  /// 마나 회복
  void restoreMana(double amount) {
    final newMana = (state.currentMana + amount).clamp(0.0, state.maxMana);
    state = state.copyWith(currentMana: newMana);
  }

  /// 마나 자연 회복 (매 프레임 호출)
  void regenMana(double dt) {
    restoreMana(state.config.manaRegenPerSecond * dt);
  }

  /// 공격 적중 시 마나 회복
  void onHit() {
    restoreMana(state.config.manaRegenOnHit);
  }

  /// 적 처치 시 마나 회복
  void onKill() {
    restoreMana(state.config.manaRegenOnKill);
  }

  /// 스킬 장착
  void equipSkill(int slot, String skillId) {
    if (slot < 0 || slot >= state.equippedSkills.length) return;

    final newSkills = List<String>.from(state.equippedSkills);
    newSkills[slot] = skillId;
    state = state.copyWith(equippedSkills: newSkills);
  }

  /// 스킬 해제
  void unequipSkill(int slot) {
    equipSkill(slot, '');
  }

  /// 스킬 쿨다운 시작
  void startCooldown(String skillId, double cooldown) {
    final newCooldowns = Map<String, double>.from(state.skillCooldowns);
    newCooldowns[skillId] = cooldown;
    state = state.copyWith(skillCooldowns: newCooldowns);
  }

  /// 쿨다운 업데이트 (매 프레임 호출)
  void updateCooldowns(double dt) {
    var changed = false;
    final newCooldowns = Map<String, double>.from(state.skillCooldowns);

    for (final entry in newCooldowns.entries.toList()) {
      if (entry.value > 0) {
        newCooldowns[entry.key] = (entry.value - dt).clamp(0.0, double.infinity);
        changed = true;
      }
    }

    if (changed) {
      state = state.copyWith(skillCooldowns: newCooldowns);
    }
  }

  /// 스킬 사용 가능 여부 (쿨다운 + 마나)
  bool canUseSkill(SkillData skill) {
    if (!state.isSkillReady(skill.id)) return false;
    if (!state.hasEnoughMana(skill.manaCost)) return false;
    return true;
  }

  /// 리셋
  void reset() {
    state = PlayerSkillState(
      currentMana: state.maxMana,
      maxMana: state.maxMana,
      equippedSkills: const ['', '', '', ''],
      skillCooldowns: const {},
      config: state.config,
    );
  }

  /// 마나 최대 충전
  void fillMana() {
    state = state.copyWith(currentMana: state.maxMana);
  }
}

/// 플레이어 스킬 Provider
final playerSkillProvider =
    StateNotifierProvider<PlayerSkillNotifier, PlayerSkillState>((ref) {
  return PlayerSkillNotifier();
});
