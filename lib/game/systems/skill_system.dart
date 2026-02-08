/// Arcana: The Three Hearts - 스킬 시스템
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models/skill_data.dart';
import '../../data/repositories/config_repository.dart';
import '../player.dart';
import '../enemy.dart';
import '../components/projectiles/skill_projectile.dart';
import 'map_loader.dart';

/// 스킬 사용 결과
class SkillResult {
  const SkillResult({
    required this.success,
    this.message,
    this.damage = 0,
    this.hitCount = 0,
  });

  final bool success;
  final String? message;
  final double damage;
  final int hitCount;
}

/// 스킬 시스템
/// 스킬 사용, 쿨다운 관리, 효과 적용을 담당합니다.
class SkillSystem {
  SkillSystem({
    required this.player,
    required this.world,
    required this.getEnemies,
    this.onManaUsed,
    this.onCooldownStarted,
  });

  final Player player;
  final World world;
  final List<Enemy> Function() getEnemies;
  final void Function(double amount)? onManaUsed;
  final void Function(String skillId, double cooldown)? onCooldownStarted;

  // 스킬 쿨다운 맵
  final Map<String, double> _cooldowns = {};

  // 버프 상태
  final Map<String, BuffState> _activeBuffs = {};

  /// 스킬 사용
  SkillResult useSkill(String skillId, double currentMana) {
    final skillData = ConfigRepository.instance.getSkill(skillId);

    if (skillData == null) {
      return const SkillResult(success: false, message: '스킬을 찾을 수 없습니다.');
    }

    // 쿨다운 체크
    if (isOnCooldown(skillId)) {
      final remaining = _cooldowns[skillId]!;
      return SkillResult(
        success: false,
        message: '쿨다운 중 (${remaining.toStringAsFixed(1)}초)',
      );
    }

    // 마나 체크
    if (currentMana < skillData.manaCost) {
      return SkillResult(
        success: false,
        message: '마나 부족 (${skillData.manaCost} 필요)',
      );
    }

    // 마나 소모
    onManaUsed?.call(skillData.manaCost.toDouble());

    // 쿨다운 시작
    _cooldowns[skillId] = skillData.cooldown;
    onCooldownStarted?.call(skillId, skillData.cooldown);

    // 스킬 타입에 따라 실행
    switch (skillData.type) {
      case SkillType.projectile:
        return _executeProjectileSkill(skillData);
      case SkillType.area:
        return _executeAreaSkill(skillData);
      case SkillType.buff:
        return _executeBuffSkill(skillData);
      case SkillType.dash:
        return _executeDashSkill(skillData);
      case SkillType.summon:
        return _executeSummonSkill(skillData);
    }
  }

  /// 투사체 스킬 실행
  SkillResult _executeProjectileSkill(SkillData skill) {
    // 플레이어가 바라보는 방향 (aimDirection 사용)
    final direction = player.aimDirection;

    // 투사체 생성
    for (int i = 0; i < skill.projectileCount; i++) {
      // 여러 발일 경우 부채꼴로 발사
      double angle = atan2(direction.y, direction.x);
      if (skill.projectileCount > 1) {
        final spread = pi / 6; // 30도 범위
        final offset = spread * (i - (skill.projectileCount - 1) / 2) /
            max(1, skill.projectileCount - 1);
        angle += offset;
      }

      final projectile = SkillProjectile(
        position: player.position.clone(),
        direction: Vector2(cos(angle), sin(angle)),
        speed: skill.projectileSpeed,
        damage: skill.damage,
        range: skill.range,
        skillId: skill.id,
        onHit: (enemy) {
          enemy.takeDamage(skill.damage);
        },
      );

      world.add(projectile);
    }

    return SkillResult(
      success: true,
      message: '${skill.name} 발동!',
      damage: skill.damage,
    );
  }

  /// 범위 스킬 실행
  SkillResult _executeAreaSkill(SkillData skill) {
    final enemies = getEnemies();
    int hitCount = 0;
    double totalDamage = 0;

    // 플레이어 주변 범위 내 적에게 데미지
    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      final distance = (enemy.position - player.position).length;
      if (distance <= skill.radius) {
        enemy.takeDamage(skill.damage);
        hitCount++;
        totalDamage += skill.damage;

        // 슬로우 효과 적용
        if (skill.buffEffect.containsKey('slowEnemy')) {
          // TODO: 적 슬로우 시스템 구현
        }
      }
    }

    // 범위 이펙트 생성
    final areaEffect = AreaEffectComponent(
      position: player.position.clone(),
      radius: skill.radius,
      duration: 0.3,
      color: _getSkillColor(skill.id),
    );
    world.add(areaEffect);

    return SkillResult(
      success: true,
      message: '${skill.name} 발동! ($hitCount 적중)',
      damage: totalDamage,
      hitCount: hitCount,
    );
  }

  /// 버프 스킬 실행
  SkillResult _executeBuffSkill(SkillData skill) {
    // 버프 적용
    for (final entry in skill.buffEffect.entries) {
      _activeBuffs[entry.key] = BuffState(
        value: entry.value,
        duration: skill.duration,
        remainingDuration: skill.duration,
      );
    }

    // 버프 효과를 플레이어에 즉시 적용
    _applyBuffsToPlayer();

    // 버프 이펙트 생성
    final buffEffect = BuffEffectComponent(
      target: player,
      duration: skill.duration,
      color: _getSkillColor(skill.id),
    );
    world.add(buffEffect);

    return SkillResult(
      success: true,
      message: '${skill.name} 발동! (${skill.duration}초)',
    );
  }

  /// 대시 스킬 실행
  SkillResult _executeDashSkill(SkillData skill) {
    // 플레이어가 바라보는 방향으로 대시 (aimDirection 사용)
    final direction = player.aimDirection;

    // 대시 거리만큼 이동하며 적에게 데미지
    final enemies = getEnemies();
    int hitCount = 0;
    double totalDamage = 0;

    final startPos = player.position.clone();
    final endPos = startPos + direction * skill.range;

    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      // 대시 경로와 적의 거리 체크
      final toEnemy = enemy.position - startPos;
      final projection = toEnemy.dot(direction);

      if (projection >= 0 && projection <= skill.range) {
        final closestPoint = startPos + direction * projection;
        final distance = (enemy.position - closestPoint).length;

        if (distance <= 30) {
          enemy.takeDamage(skill.damage);
          hitCount++;
          totalDamage += skill.damage;
        }
      }
    }

    // 플레이어 이동 (단계적 이동으로 벽 관통 방지)
    // arcana_game.dart의 벽 충돌 체크가 최종 위치를 검증함
    // 여기서는 단계적으로 이동하여 벽 뒤로 텔레포트되는 것을 방지
    const stepSize = 16.0;
    final totalDistance = skill.range;
    final steps = (totalDistance / stepSize).ceil();
    var currentPos = startPos.clone();

    for (int s = 1; s <= steps; s++) {
      final nextPos = startPos + direction * (stepSize * s).clamp(0, totalDistance);
      // MapComponent 검색하여 벽 체크
      final mapComponent = world.children.whereType<MapComponent>().firstOrNull;
      if (mapComponent != null && mapComponent.isColliding(nextPos, player.size)) {
        break; // 벽에 막히면 그 전 위치에서 정지
      }
      currentPos = nextPos;
    }
    player.position = currentPos;

    return SkillResult(
      success: true,
      message: '${skill.name} 발동! ($hitCount 적중)',
      damage: totalDamage,
      hitCount: hitCount,
    );
  }

  /// 소환 스킬 실행
  SkillResult _executeSummonSkill(SkillData skill) {
    // TODO: 소환 시스템 구현
    return SkillResult(
      success: true,
      message: '${skill.name} 발동!',
    );
  }

  /// 버프 효과를 플레이어에 적용
  void _applyBuffsToPlayer() {
    // 기본값
    double damageMultiplier = 1.0;
    double defenseMultiplier = 1.0;
    double speedMultiplier = 1.0;

    for (final entry in _activeBuffs.entries) {
      switch (entry.key) {
        case 'damage':
          damageMultiplier = entry.value.value; // 1.5x
        case 'defense':
          defenseMultiplier = entry.value.value; // 0.5 (50% 데미지 감소)
        case 'speed':
          speedMultiplier = entry.value.value; // 1.5x
      }
    }

    player.buffDamageMultiplier = damageMultiplier;
    player.buffDefenseMultiplier = defenseMultiplier;
    player.buffSpeedMultiplier = speedMultiplier;
  }

  /// 쿨다운 업데이트
  void update(double dt) {
    // 쿨다운 감소
    final keysToRemove = <String>[];
    for (final entry in _cooldowns.entries) {
      final newValue = entry.value - dt;
      if (newValue <= 0) {
        keysToRemove.add(entry.key);
      } else {
        _cooldowns[entry.key] = newValue;
      }
    }
    for (final key in keysToRemove) {
      _cooldowns.remove(key);
    }

    // 버프 지속시간 감소
    final buffsToRemove = <String>[];
    for (final entry in _activeBuffs.entries) {
      entry.value.remainingDuration -= dt;
      if (entry.value.remainingDuration <= 0) {
        buffsToRemove.add(entry.key);
      }
    }
    if (buffsToRemove.isNotEmpty) {
      for (final key in buffsToRemove) {
        _activeBuffs.remove(key);
      }
      // 버프 만료 시 효과 재계산
      _applyBuffsToPlayer();
    }
  }

  /// 쿨다운 중인지 확인
  bool isOnCooldown(String skillId) {
    return _cooldowns.containsKey(skillId) && _cooldowns[skillId]! > 0;
  }

  /// 남은 쿨다운 시간
  double getCooldown(String skillId) {
    return _cooldowns[skillId] ?? 0;
  }

  /// 현재 버프 값 가져오기
  double getBuffValue(String buffType) {
    return _activeBuffs[buffType]?.value ?? 0;
  }

  /// 버프 활성화 여부
  bool isBuffActive(String buffType) {
    return _activeBuffs.containsKey(buffType) &&
        _activeBuffs[buffType]!.remainingDuration > 0;
  }

  /// 스킬별 색상
  Color _getSkillColor(String skillId) {
    switch (skillId) {
      case 'fireball':
      case 'flame_wave':
        return Colors.orange;
      case 'ice_shard':
      case 'frost_nova':
        return Colors.cyan;
      case 'lightning_bolt':
        return Colors.yellow;
      case 'battle_cry':
        return Colors.red;
      case 'iron_skin':
        return Colors.grey;
      case 'quick_step':
        return Colors.green;
      case 'shadow_dash':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}

/// 버프 상태
class BuffState {
  BuffState({
    required this.value,
    required this.duration,
    required this.remainingDuration,
  });

  final double value;
  final double duration;
  double remainingDuration;
}

/// 범위 이펙트 컴포넌트
class AreaEffectComponent extends PositionComponent {
  AreaEffectComponent({
    required Vector2 position,
    required this.radius,
    required this.duration,
    this.color = Colors.blue,
  }) : super(position: position, anchor: Anchor.center);

  final double radius;
  final double duration;
  final Color color;

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = ((1 - progress) * 150).toInt();
    final currentRadius = radius * (0.5 + progress * 0.5);

    // 원형 이펙트
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, currentRadius, paint);

    // 외곽선
    final borderPaint = Paint()
      ..color = color.withAlpha((alpha * 1.5).toInt().clamp(0, 255))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset.zero, currentRadius, borderPaint);
  }
}

/// 버프 이펙트 컴포넌트
class BuffEffectComponent extends PositionComponent {
  BuffEffectComponent({
    required this.target,
    required this.duration,
    this.color = Colors.blue,
  }) : super(anchor: Anchor.center);

  final PositionComponent target;
  final double duration;
  final Color color;

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position = target.position;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse = (sin(_elapsed * 4) + 1) / 2; // 0~1 펄스
    final alpha = ((0.3 + pulse * 0.4) * 255 * (1 - _elapsed / duration)).toInt().clamp(0, 255);
    final radius = 20.0 + pulse * 5;

    // 버프 아우라 원
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, radius, paint);

    // 내부 글로우
    final glowPaint = Paint()
      ..color = color.withAlpha((alpha * 0.3).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.8, glowPaint);
  }
}
