/// Arcana: The Three Hearts - 스킬 슬롯 UI
/// 스킬 사용 및 쿨다운 표시
library;

import 'package:flutter/material.dart';

import '../../data/models/skill_data.dart';

/// 스킬 슬롯 콜백
typedef OnSkillTap = void Function(int slotIndex, String? skillId);

/// 스킬 슬롯 UI 위젯
class SkillSlotsWidget extends StatelessWidget {
  const SkillSlotsWidget({
    super.key,
    required this.equippedSkills,
    required this.skillCooldowns,
    required this.currentMana,
    required this.maxMana,
    this.skillsConfig,
    this.onSkillTap,
    this.slotSize = 56,
    this.spacing = 8,
  });

  /// 장착된 스킬 ID 목록 (4슬롯)
  final List<String> equippedSkills;

  /// 스킬별 남은 쿨다운
  final Map<String, double> skillCooldowns;

  /// 현재 마나
  final double currentMana;

  /// 최대 마나
  final double maxMana;

  /// 스킬 설정 (스킬 데이터 조회용)
  final SkillsConfig? skillsConfig;

  /// 스킬 탭 콜백
  final OnSkillTap? onSkillTap;

  /// 슬롯 크기
  final double slotSize;

  /// 슬롯 간격
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 마나 바
        _ManaBar(
          current: currentMana,
          max: maxMana,
          height: slotSize,
        ),

        SizedBox(width: spacing * 2),

        // 스킬 슬롯 4개
        ...List.generate(4, (index) {
          final skillId = index < equippedSkills.length
              ? equippedSkills[index]
              : '';

          final skill = skillId.isNotEmpty
              ? skillsConfig?.findById(skillId)
              : null;

          final cooldown = skillId.isNotEmpty
              ? (skillCooldowns[skillId] ?? 0)
              : 0.0;

          final hasEnoughMana = skill == null || currentMana >= skill.manaCost;

          return Padding(
            padding: EdgeInsets.only(right: index < 3 ? spacing : 0),
            child: _SkillSlot(
              slotIndex: index,
              skill: skill,
              cooldown: cooldown,
              hasEnoughMana: hasEnoughMana,
              size: slotSize,
              onTap: onSkillTap != null
                  ? () => onSkillTap!(index, skill?.id)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

/// 개별 스킬 슬롯
class _SkillSlot extends StatelessWidget {
  const _SkillSlot({
    required this.slotIndex,
    required this.skill,
    required this.cooldown,
    required this.hasEnoughMana,
    required this.size,
    this.onTap,
  });

  final int slotIndex;
  final SkillData? skill;
  final double cooldown;
  final bool hasEnoughMana;
  final double size;
  final VoidCallback? onTap;

  bool get isOnCooldown => cooldown > 0;
  bool get isUsable => skill != null && !isOnCooldown && hasEnoughMana;

  /// 스킬 타입별 색상
  Color get skillColor {
    if (skill == null) return Colors.grey.shade800;

    switch (skill!.type) {
      case SkillType.basic:
        return Colors.white;
      case SkillType.active:
        return Colors.blue.shade400;
      case SkillType.dash:
        return Colors.green.shade400;
      case SkillType.ultimate:
        return Colors.amber.shade400;
      case SkillType.passive:
        return Colors.purple.shade400;
    }
  }

  /// 스킬 카테고리별 아이콘
  IconData get skillIcon {
    if (skill == null || skill!.category == null) return Icons.add;

    switch (skill!.category!) {
      case SkillCategory.melee:
        return Icons.sports_martial_arts;
      case SkillCategory.ranged:
        return Icons.gps_fixed;
      case SkillCategory.aoeAttack:
        return Icons.blur_circular;
      case SkillCategory.dashAttack:
        return Icons.flash_on;
      case SkillCategory.defense:
        return Icons.shield;
      case SkillCategory.heavyAttack:
        return Icons.fitness_center;
      case SkillCategory.utility:
        return Icons.build;
      case SkillCategory.movement:
        return Icons.directions_run;
      case SkillCategory.buffUltimate:
        return Icons.auto_fix_high;
      case SkillCategory.defenseUltimate:
        return Icons.security;
      case SkillCategory.attackUltimate:
        return Icons.local_fire_department;
      case SkillCategory.fusionUltimate:
        return Icons.stars;
      case SkillCategory.survival:
        return Icons.favorite;
      case SkillCategory.offense:
        return Icons.bolt;
      case SkillCategory.sustain:
        return Icons.healing;
      case SkillCategory.heart:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUsable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUsable
                ? skillColor
                : Colors.grey.shade700,
            width: 2,
          ),
          boxShadow: isUsable
              ? [
                  BoxShadow(
                    color: skillColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // 스킬 아이콘
            Center(
              child: Icon(
                skillIcon,
                color: isUsable
                    ? skillColor
                    : Colors.grey.shade600,
                size: size * 0.5,
              ),
            ),

            // 슬롯 번호
            Positioned(
              top: 2,
              left: 4,
              child: Text(
                '${slotIndex + 1}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 마나 코스트
            if (skill != null && skill!.manaCost > 0)
              Positioned(
                bottom: 2,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: hasEnoughMana
                        ? Colors.blue.shade900.withValues(alpha: 0.8)
                        : Colors.red.shade900.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${skill!.manaCost.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // 쿨다운 오버레이
            if (isOnCooldown)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      cooldown.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // 마나 부족 표시
            if (!isOnCooldown && !hasEnoughMana && skill != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.block,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 마나 바 (스킬 슬롯 옆)
class _ManaBar extends StatelessWidget {
  const _ManaBar({
    required this.current,
    required this.max,
    required this.height,
  });

  final double current;
  final double max;
  final double height;

  double get ratio => max > 0 ? (current / max).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 마나 아이콘
        Icon(
          Icons.water_drop,
          color: Colors.blue.shade300,
          size: 14,
        ),
        const SizedBox(height: 2),

        // 세로 마나 바
        Container(
          width: 12,
          height: height - 20,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.blue.shade700,
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 마나 채움
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: (height - 24) * ratio,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade400,
                      Colors.cyan.shade300,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // 마나 수치
        Text(
          '${current.toInt()}',
          style: TextStyle(
            color: Colors.blue.shade300,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 스킬 슬롯 컴팩트 버전 (모바일용)
class SkillSlotsCompact extends StatelessWidget {
  const SkillSlotsCompact({
    super.key,
    required this.equippedSkills,
    required this.skillCooldowns,
    this.skillsConfig,
    this.onSkillTap,
  });

  final List<String> equippedSkills;
  final Map<String, double> skillCooldowns;
  final SkillsConfig? skillsConfig;
  final OnSkillTap? onSkillTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final skillId = index < equippedSkills.length
            ? equippedSkills[index]
            : '';
        final cooldown = skillId.isNotEmpty
            ? (skillCooldowns[skillId] ?? 0)
            : 0.0;

        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? 4 : 0),
          child: _CompactSlot(
            index: index,
            isOnCooldown: cooldown > 0,
            cooldown: cooldown,
            isEmpty: skillId.isEmpty,
            onTap: onSkillTap != null && skillId.isNotEmpty
                ? () => onSkillTap!(index, skillId)
                : null,
          ),
        );
      }),
    );
  }
}

class _CompactSlot extends StatelessWidget {
  const _CompactSlot({
    required this.index,
    required this.isOnCooldown,
    required this.cooldown,
    required this.isEmpty,
    this.onTap,
  });

  final int index;
  final bool isOnCooldown;
  final double cooldown;
  final bool isEmpty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEmpty || isOnCooldown ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEmpty
                ? Colors.grey.shade700
                : isOnCooldown
                    ? Colors.grey.shade600
                    : Colors.amber.shade400,
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(
                color: isEmpty || isOnCooldown
                    ? Colors.grey.shade600
                    : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isOnCooldown)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Text(
                    cooldown.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
