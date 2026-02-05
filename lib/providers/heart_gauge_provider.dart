/// Arcana: The Three Hearts - 심장 게이지 Provider
/// GDD 7.4: 심장 게이지 충전 시스템
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/skill_data.dart';

/// 심장 게이지 상태
class HeartGaugeState {
  const HeartGaugeState({
    this.current = 0,
    this.max = 100,
    this.config = ResourceSystemConfig.defaultConfig,
  });

  /// 현재 게이지
  final double current;

  /// 최대 게이지
  final double max;

  /// 리소스 설정
  final ResourceSystemConfig config;

  /// 게이지 비율 (0.0 ~ 1.0)
  double get ratio => current / max;

  /// 궁극기 사용 가능 여부
  bool get canUseUltimate => current >= config.heartGaugeRequiredForUltimate;

  /// 특정 비용으로 스킬 사용 가능 여부
  bool canAfford(double cost) => current >= cost;

  HeartGaugeState copyWith({
    double? current,
    double? max,
    ResourceSystemConfig? config,
  }) {
    return HeartGaugeState(
      current: current ?? this.current,
      max: max ?? this.max,
      config: config ?? this.config,
    );
  }
}

/// 심장 게이지 Notifier
class HeartGaugeNotifier extends StateNotifier<HeartGaugeState> {
  HeartGaugeNotifier() : super(const HeartGaugeState());

  /// 설정 초기화
  void initialize(ResourceSystemConfig config) {
    state = HeartGaugeState(
      current: 0,
      max: config.maxHeartGauge,
      config: config,
    );
  }

  /// 게이지 충전
  void _addGauge(double amount) {
    final newValue = (state.current + amount).clamp(0.0, state.max);
    state = state.copyWith(current: newValue);
  }

  /// 게이지 소모
  bool consume(double amount) {
    if (state.current < amount) return false;
    state = state.copyWith(current: state.current - amount);
    return true;
  }

  /// 데미지 가함 시 충전
  /// GDD: 데미지 10당 1 충전
  void onDamageDealt(double damage) {
    final gain = damage * state.config.heartGainOnDamageDealt / 10;
    _addGauge(gain);
  }

  /// 데미지 받음 시 충전
  /// GDD: 데미지 5당 1 충전
  void onDamageTaken(double damage) {
    final gain = damage * state.config.heartGainOnDamageTaken / 5;
    _addGauge(gain);
  }

  /// 완벽 회피 시 충전
  /// GDD: 10 충전
  void onPerfectDodge() {
    _addGauge(state.config.heartGainOnPerfectDodge);
  }

  /// 적 처치 시 충전
  /// GDD: 5 충전
  void onKill() {
    _addGauge(5);
  }

  /// 게이지 리셋
  void reset() {
    state = state.copyWith(current: 0);
  }

  /// 게이지 설정 (디버그/치트용)
  void setGauge(double value) {
    state = state.copyWith(current: value.clamp(0, state.max));
  }

  /// 최대 충전
  void fillToMax() {
    state = state.copyWith(current: state.max);
  }
}

/// 심장 게이지 Provider
final heartGaugeProvider =
    StateNotifierProvider<HeartGaugeNotifier, HeartGaugeState>((ref) {
  return HeartGaugeNotifier();
});
