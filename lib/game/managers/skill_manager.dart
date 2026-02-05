/// Arcana: The Three Hearts - 스킬 관리자
/// 스킬 실행, 효과 발동, 쿨다운 관리
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../data/models/skill_data.dart';
import '../characters/player.dart' show PlayerDirection;
import '../effects/effects.dart';
import 'audio_manager.dart';

/// 스킬 사용 결과
enum SkillUseResult {
  success,      // 성공
  onCooldown,   // 쿨다운 중
  noMana,       // 마나 부족
  noHeartGauge, // 심장 게이지 부족
  notUnlocked,  // 해금되지 않음
  invalid,      // 유효하지 않은 스킬
}

/// 스킬 관리자
class SkillManager extends Component with HasGameRef {
  SkillManager({
    this.onSkillUsed,
    this.onCooldownStarted,
    this.onManaConsumed,
    this.onHeartGaugeConsumed,
  });

  /// 스킬 사용 콜백
  final void Function(SkillData skill)? onSkillUsed;

  /// 쿨다운 시작 콜백
  final void Function(String skillId, double cooldown)? onCooldownStarted;

  /// 마나 소모 콜백
  final void Function(double amount)? onManaConsumed;

  /// 심장 게이지 소모 콜백
  final void Function(double amount)? onHeartGaugeConsumed;

  /// 로드된 스킬 설정
  SkillsConfig? _skillsConfig;

  /// 스킬 쿨다운 맵
  final Map<String, double> _cooldowns = {};

  /// 현재 마나
  double _currentMana = 100;

  /// 최대 마나
  double _maxMana = 100;

  /// 현재 심장 게이지
  double _heartGauge = 0;

  /// 최대 심장 게이지
  double _maxHeartGauge = 100;

  /// 게터
  double get currentMana => _currentMana;
  double get maxMana => _maxMana;
  double get heartGauge => _heartGauge;
  double get maxHeartGauge => _maxHeartGauge;
  double get manaRatio => _currentMana / _maxMana;
  double get heartGaugeRatio => _heartGauge / _maxHeartGauge;

  /// 스킬 설정 초기화
  void initialize(SkillsConfig config) {
    _skillsConfig = config;
    _maxMana = config.resourceSystem.maxMana;
    _currentMana = _maxMana;
    _maxHeartGauge = config.resourceSystem.maxHeartGauge;
    _heartGauge = 0;
  }

  /// 스킬 ID로 찾기
  SkillData? getSkillById(String id) {
    return _skillsConfig?.findById(id);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 쿨다운 감소
    for (final entry in _cooldowns.entries.toList()) {
      if (entry.value > 0) {
        _cooldowns[entry.key] = (entry.value - dt).clamp(0.0, double.infinity);
      }
    }

    // 마나 자연 회복
    if (_skillsConfig != null) {
      _currentMana = (_currentMana +
              _skillsConfig!.resourceSystem.manaRegenPerSecond * dt)
          .clamp(0.0, _maxMana);
    }
  }

  /// 스킬 사용 가능 여부 확인
  SkillUseResult canUseSkill(SkillData skill, {bool hasHeartUnlocked = true}) {
    // 쿨다운 체크
    if (_cooldowns[skill.id] != null && _cooldowns[skill.id]! > 0) {
      return SkillUseResult.onCooldown;
    }

    // 궁극기인 경우 심장 게이지 체크
    if (skill.type == SkillType.ultimate) {
      if (!hasHeartUnlocked) {
        return SkillUseResult.notUnlocked;
      }
      if (_heartGauge < skill.heartGaugeCost) {
        return SkillUseResult.noHeartGauge;
      }
    } else {
      // 일반 스킬은 마나 체크
      if (_currentMana < skill.manaCost) {
        return SkillUseResult.noMana;
      }
    }

    return SkillUseResult.success;
  }

  /// 스킬 사용
  SkillUseResult useSkill(
    SkillData skill,
    Vector2 position,
    Vector2 direction, {
    bool hasHeartUnlocked = true,
  }) {
    final result = canUseSkill(skill, hasHeartUnlocked: hasHeartUnlocked);
    if (result != SkillUseResult.success) {
      return result;
    }

    // 비용 소모
    if (skill.type == SkillType.ultimate) {
      _heartGauge -= skill.heartGaugeCost;
      onHeartGaugeConsumed?.call(skill.heartGaugeCost);
    } else {
      _currentMana -= skill.manaCost;
      onManaConsumed?.call(skill.manaCost);
    }

    // 쿨다운 시작
    if (skill.cooldown > 0) {
      _cooldowns[skill.id] = skill.cooldown;
      onCooldownStarted?.call(skill.id, skill.cooldown);
    }

    // 스킬 효과 발동
    _executeSkillEffect(skill, position, direction);

    onSkillUsed?.call(skill);
    return SkillUseResult.success;
  }

  /// 스킬 효과 실행
  void _executeSkillEffect(
    SkillData skill,
    Vector2 position,
    Vector2 direction,
  ) {
    // 피드백 (사운드, 화면 흔들림 등)
    if (skill.feedback != null) {
      _applyFeedback(skill.feedback!);
    }

    // 스킬 타입별 처리
    switch (skill.type) {
      case SkillType.basic:
        _executeBasicAttack(skill, position, direction);
      case SkillType.active:
        _executeActiveSkill(skill, position, direction);
      case SkillType.dash:
        _executeDash(skill, position, direction);
      case SkillType.ultimate:
        _executeUltimate(skill, position, direction);
      case SkillType.passive:
        // 패시브는 별도 처리
        break;
    }
  }

  /// 기본 공격 실행
  void _executeBasicAttack(
    SkillData skill,
    Vector2 position,
    Vector2 direction,
  ) {
    debugPrint('Execute basic attack: ${skill.name}');

    // 슬래시 이펙트 (이미 player.dart에서 처리)
    // 여기서는 콤보 시스템 등 추가 로직 처리 가능
  }

  /// 액티브 스킬 실행
  void _executeActiveSkill(
    SkillData skill,
    Vector2 position,
    Vector2 direction,
  ) {
    debugPrint('Execute active skill: ${skill.name}');

    // 카테고리별 이펙트
    switch (skill.category) {
      case SkillCategory.ranged:
        // 투사체 생성 (추후 구현)
        break;
      case SkillCategory.aoeAttack:
        // 광역 이펙트
        gameRef.world.add(
          SlashEffect(
            position: position,
            direction: PlayerDirection.down,
            color: const Color(0xFF9C27B0), // 보라색
            effectSize: 80,
          ),
        );
        break;
      case SkillCategory.defense:
        // 방어 이펙트 (추후 구현)
        break;
      default:
        // 기본 이펙트
        gameRef.world.add(
          SlashEffect(
            position: position + direction * 30,
            direction: _vectorToDirection(direction),
            color: const Color(0xFF2196F3), // 파란색
            effectSize: 60,
          ),
        );
    }
  }

  /// 대시 실행
  void _executeDash(
    SkillData skill,
    Vector2 position,
    Vector2 direction,
  ) {
    debugPrint('Execute dash: ${skill.name}');
    // 대시 로직은 player.dart에서 직접 처리
  }

  /// 궁극기 실행
  void _executeUltimate(
    SkillData skill,
    Vector2 position,
    Vector2 direction,
  ) {
    debugPrint('Execute ultimate: ${skill.name}');

    // 강력한 이펙트
    ScreenShakeManager.heavyShake();

    // 전체 화면 이펙트 (예: 심장 모양 펄스)
    gameRef.world.add(
      SlashEffect(
        position: position,
        direction: PlayerDirection.down,
        color: const Color(0xFFFFD700), // 금색
        effectSize: 150,
      ),
    );
  }

  /// 피드백 적용
  void _applyFeedback(SkillFeedback feedback) {
    // 화면 흔들림
    if (feedback.screenShakeIntensity > 0) {
      if (feedback.screenShakeIntensity > 5) {
        ScreenShakeManager.heavyShake();
      } else if (feedback.screenShakeIntensity > 2) {
        ScreenShakeManager.mediumShake();
      } else {
        ScreenShakeManager.lightShake();
      }
    }

    // 사운드
    if (feedback.castSound != null) {
      // 사운드 재생 (추후 구현)
    }
  }

  /// 방향 벡터를 PlayerDirection으로 변환
  PlayerDirection _vectorToDirection(Vector2 direction) {
    if (direction.x.abs() > direction.y.abs()) {
      return direction.x > 0 ? PlayerDirection.right : PlayerDirection.left;
    } else {
      return direction.y > 0 ? PlayerDirection.down : PlayerDirection.up;
    }
  }

  /// 심장 게이지 충전
  void addHeartGauge(double amount) {
    _heartGauge = (_heartGauge + amount).clamp(0.0, _maxHeartGauge);
  }

  /// 데미지 가함 시 심장 게이지 충전
  void onDamageDealt(double damage) {
    if (_skillsConfig == null) return;
    final gain =
        damage * _skillsConfig!.resourceSystem.heartGainOnDamageDealt / 10;
    addHeartGauge(gain);
  }

  /// 데미지 받음 시 심장 게이지 충전
  void onDamageTaken(double damage) {
    if (_skillsConfig == null) return;
    final gain =
        damage * _skillsConfig!.resourceSystem.heartGainOnDamageTaken / 5;
    addHeartGauge(gain);
  }

  /// 완벽 회피 시 심장 게이지 충전
  void onPerfectDodge() {
    if (_skillsConfig == null) return;
    addHeartGauge(_skillsConfig!.resourceSystem.heartGainOnPerfectDodge);
  }

  /// 적 처치 시 마나/게이지 회복
  void onKill() {
    if (_skillsConfig == null) return;
    _currentMana =
        (_currentMana + _skillsConfig!.resourceSystem.manaRegenOnKill)
            .clamp(0.0, _maxMana);
    addHeartGauge(5);
  }

  /// 공격 적중 시 마나 회복
  void onHit() {
    if (_skillsConfig == null) return;
    _currentMana =
        (_currentMana + _skillsConfig!.resourceSystem.manaRegenOnHit)
            .clamp(0.0, _maxMana);
  }

  /// 스킬 쿨다운 확인
  double getCooldown(String skillId) => _cooldowns[skillId] ?? 0;

  /// 스킬 준비 여부
  bool isSkillReady(String skillId) => getCooldown(skillId) <= 0;

  /// 리셋
  void reset() {
    _cooldowns.clear();
    _currentMana = _maxMana;
    _heartGauge = 0;
  }
}
