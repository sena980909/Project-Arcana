/// Arcana: The Three Hearts - HUD 오버레이
library;

import 'package:flutter/material.dart';

import '../data/models/player_state.dart';

/// HUD 오버레이
class HudOverlay extends StatelessWidget {
  const HudOverlay({
    required this.hp,
    required this.maxHp,
    required this.mana,
    required this.maxMana,
    required this.gold,
    required this.heartGauge,
    required this.lastKey,
    this.skillSlots,
    this.skillCooldowns,
    super.key,
  });

  final double hp;
  final double maxHp;
  final double mana;
  final double maxMana;
  final int gold;
  final int heartGauge;
  final String lastKey;
  final SkillSlots? skillSlots;
  final Map<String, double>? skillCooldowns;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 바: HP, 마나, 심장 게이지
            _buildTopBar(),

            const Spacer(),

            // 하단: 스킬 슬롯 및 키 안내
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HP 바
          _buildStatBar(
            label: 'HP',
            value: hp,
            maxValue: maxHp,
            color: hp / maxHp > 0.3 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),

          // 마나 바
          _buildStatBar(
            label: 'MP',
            value: mana,
            maxValue: maxMana,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),

          // 심장 게이지
          _buildStatBar(
            label: 'Heart',
            value: heartGauge.toDouble(),
            maxValue: 100,
            color: _getHeartGaugeColor(),
            showUltimateReady: heartGauge >= 100,
          ),
          const SizedBox(height: 8),

          // 골드
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '$gold G',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHeartGaugeColor() {
    if (heartGauge >= 100) return Colors.yellow;
    if (heartGauge >= 75) return Colors.purple.shade300;
    if (heartGauge >= 50) return Colors.purple;
    return Colors.purple.shade700;
  }

  Widget _buildStatBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
    bool showUltimateReady = false,
  }) {
    final ratio = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Text(
              '${value.toInt()}/${maxValue.toInt()}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            if (showUltimateReady) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.withAlpha(200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'R READY!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Container(
          width: 150,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: showUltimateReady
                    ? [
                        BoxShadow(
                          color: Colors.yellow.withAlpha(150),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 스킬 슬롯
        if (skillSlots != null) _buildSkillSlots(),

        const SizedBox(height: 8),

        // 키 안내
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withAlpha(100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '마지막 키: $lastKey',
                style: const TextStyle(color: Colors.amber, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'WASD: 이동 | J/Space: 공격 | Shift: 대시',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const Text(
                'Q/W/E: 스킬 | R: 궁극기 | E/F4: 상점',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const Text(
                'F1: 디버그 | F3: 적 처치 | F5: 저장 | F9: 불러오기',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillSlots() {
    final slots = [
      ('Q', skillSlots?.q, Colors.red),
      ('W', skillSlots?.w, Colors.blue),
      ('E', skillSlots?.e, Colors.green),
      ('R', skillSlots?.r, Colors.purple),
    ];

    return Row(
      children: slots.map((slot) {
        final key = slot.$1;
        final skillId = slot.$2;
        final color = slot.$3;
        final cooldown = skillId != null ? (skillCooldowns?[skillId] ?? 0.0) : 0.0;
        final isOnCooldown = cooldown > 0;
        final isUltimate = key == 'R';
        final isUltimateReady = isUltimate && heartGauge >= 100;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildSkillSlot(
            key: key,
            skillId: skillId,
            color: color,
            cooldown: cooldown,
            isOnCooldown: isOnCooldown,
            isUltimateReady: isUltimateReady,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillSlot({
    required String key,
    String? skillId,
    required Color color,
    required double cooldown,
    required bool isOnCooldown,
    bool isUltimateReady = false,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isOnCooldown
            ? Colors.grey.shade800
            : (isUltimateReady ? color.withAlpha(200) : color.withAlpha(100)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUltimateReady
              ? Colors.yellow
              : (isOnCooldown ? Colors.grey : color),
          width: isUltimateReady ? 2 : 1,
        ),
        boxShadow: isUltimateReady
            ? [
                BoxShadow(
                  color: Colors.yellow.withAlpha(150),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // 키 표시
          Positioned(
            top: 4,
            left: 4,
            child: Text(
              key,
              style: TextStyle(
                color: isOnCooldown ? Colors.grey : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 스킬 아이콘 또는 빈 슬롯
          Center(
            child: skillId != null
                ? Icon(
                    _getSkillIcon(skillId),
                    color: isOnCooldown ? Colors.grey : Colors.white,
                    size: 20,
                  )
                : const Icon(
                    Icons.add,
                    color: Colors.grey,
                    size: 16,
                  ),
          ),

          // 쿨다운 표시
          if (isOnCooldown)
            Center(
              child: Text(
                cooldown.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(String skillId) {
    switch (skillId) {
      case 'fireball':
        return Icons.local_fire_department;
      case 'ice_shard':
        return Icons.ac_unit;
      case 'lightning_bolt':
        return Icons.bolt;
      case 'flame_wave':
        return Icons.waves;
      case 'frost_nova':
        return Icons.brightness_7;
      case 'battle_cry':
        return Icons.volume_up;
      case 'iron_skin':
        return Icons.shield;
      case 'quick_step':
        return Icons.directions_run;
      case 'shadow_dash':
        return Icons.flash_on;
      case 'arcane_missiles':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }
}
