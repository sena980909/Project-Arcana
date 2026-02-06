/// Arcana: The Three Hearts - 설정 Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/monster_data.dart';
import '../data/models/skill_data.dart';
import '../data/models/item_data.dart';
import '../data/models/game_state.dart';
import '../data/repositories/config_repository.dart';

/// ConfigRepository Provider
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepository.instance;
});

/// 몬스터 데이터 Provider
final monstersProvider = Provider<Map<String, MonsterData>>((ref) {
  return ref.watch(configRepositoryProvider).monsters;
});

/// 특정 몬스터 데이터 Provider
final monsterProvider = Provider.family<MonsterData?, String>((ref, id) {
  return ref.watch(configRepositoryProvider).getMonster(id);
});

/// 스킬 데이터 Provider
final skillsProvider = Provider<Map<String, SkillData>>((ref) {
  return ref.watch(configRepositoryProvider).skills;
});

/// 특정 스킬 데이터 Provider
final skillProvider = Provider.family<SkillData?, String>((ref, id) {
  return ref.watch(configRepositoryProvider).getSkill(id);
});

/// 궁극기 데이터 Provider
final ultimatesProvider = Provider<Map<String, UltimateData>>((ref) {
  return ref.watch(configRepositoryProvider).ultimates;
});

/// 아이템 데이터 Provider
final itemsProvider = Provider<Map<String, ItemData>>((ref) {
  return ref.watch(configRepositoryProvider).items;
});

/// 특정 아이템 데이터 Provider
final itemProvider = Provider.family<ItemData?, String>((ref, id) {
  return ref.watch(configRepositoryProvider).getItem(id);
});

/// 맵 데이터 Provider
final mapsProvider = Provider<Map<String, MapData>>((ref) {
  return ref.watch(configRepositoryProvider).maps;
});

/// 특정 맵 데이터 Provider
final mapProvider = Provider.family<MapData?, String>((ref, id) {
  return ref.watch(configRepositoryProvider).getMap(id);
});
