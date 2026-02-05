/// Arcana: The Three Hearts - 게임 HUD
/// PRD 4.2 하트 시스템 UI 표시
library;

import 'package:flutter/material.dart';

import '../../config/constants.dart';

/// 인게임 HUD 위젯
/// 심장 표시, 스킬 쿨다운 등
class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    this.currentHearts = 3,
    this.currentHealth = 100,
    this.maxHealth = 100,
    this.currentMana = 100,
    this.maxMana = 100,
    this.heartGauge = 0,
    this.maxHeartGauge = 100,
  });

  final int currentHearts;
  final double currentHealth;
  final double maxHealth;
  final double currentMana;
  final double maxMana;
  final double heartGauge;
  final double maxHeartGauge;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // 상단 좌측: 체력/마나/심장 게이지
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 심장 표시 영역
                HeartsDisplay(currentHearts: currentHearts),
                const SizedBox(height: 8),
                // HP 바
                ResourceBar(
                  label: 'HP',
                  current: currentHealth,
                  max: maxHealth,
                  color: Colors.green,
                  width: 150,
                ),
                const SizedBox(height: 4),
                // 마나 바
                ResourceBar(
                  label: 'MP',
                  current: currentMana,
                  max: maxMana,
                  color: Colors.blue,
                  width: 150,
                ),
                const SizedBox(height: 4),
                // 심장 게이지 바
                HeartGaugeBar(
                  current: heartGauge,
                  max: maxHeartGauge,
                  width: 150,
                ),
              ],
            ),
          ),

          // 하단 중앙: 스킬 슬롯
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: SkillSlotsDisplay(),
          ),

          // 디버그 정보 (상단 우측)
          const Positioned(
            right: 60,
            top: 16,
            child: DebugInfo(),
          ),
        ],
      ),
    );
  }
}

/// 심장 표시 위젯
/// PRD 4.2: 3개의 심장 (Body, Mind, Soul)
class HeartsDisplay extends StatelessWidget {
  const HeartsDisplay({
    super.key,
    required this.currentHearts,
  });

  final int currentHearts;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        HeartConstants.maxHearts,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: HeartIcon(
            type: _getHeartType(index),
            isFilled: index < currentHearts,
          ),
        ),
      ),
    );
  }

  /// 심장 타입 반환 (Body, Mind, Soul)
  HeartType _getHeartType(int index) {
    switch (index) {
      case 0:
        return HeartType.body;
      case 1:
        return HeartType.mind;
      case 2:
        return HeartType.soul;
      default:
        return HeartType.body;
    }
  }
}

/// 심장 타입
enum HeartType {
  body, // 신체 - 빨간색
  mind, // 정신 - 파란색
  soul, // 영혼 - 보라색
}

/// 개별 심장 아이콘
class HeartIcon extends StatelessWidget {
  const HeartIcon({
    super.key,
    required this.type,
    required this.isFilled,
  });

  final HeartType type;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isFilled ? _getHeartColor() : Colors.grey.shade800,
        shape: BoxShape.circle,
        border: Border.all(
          color: _getHeartColor().withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: _getHeartColor().withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.favorite,
          size: 16,
          color: isFilled ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  /// 심장 타입별 색상
  Color _getHeartColor() {
    switch (type) {
      case HeartType.body:
        return Colors.red;
      case HeartType.mind:
        return Colors.blue;
      case HeartType.soul:
        return Colors.purple;
    }
  }
}

/// 리소스 바 (HP, MP 등)
class ResourceBar extends StatelessWidget {
  const ResourceBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    this.width = 120,
  });

  final String label;
  final double current;
  final double max;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / max).clamp(0.0, 1.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 바
        Container(
          width: width,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Stack(
            children: [
              // 채워진 부분
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // 수치
              Center(
                child: Text(
                  '${current.toInt()}/${max.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 심장 게이지 바 (궁극기용)
class HeartGaugeBar extends StatelessWidget {
  const HeartGaugeBar({
    super.key,
    required this.current,
    required this.max,
    this.width = 120,
  });

  final double current;
  final double max;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / max).clamp(0.0, 1.0);
    final isFull = ratio >= 1.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 심장 아이콘
        Icon(
          Icons.favorite,
          size: 14,
          color: isFull ? Colors.purple : Colors.purple.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        // 바
        Container(
          width: width,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isFull
                  ? Colors.purple
                  : Colors.purple.withValues(alpha: 0.3),
              width: isFull ? 2 : 1,
            ),
            boxShadow: isFull
                ? [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // 채워진 부분
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade700,
                        Colors.purple,
                        Colors.purple.shade300,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 빛나는 효과 (가득 찼을 때)
              if (isFull)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              // 텍스트
              Center(
                child: Text(
                  isFull ? 'ULTIMATE READY!' : '${(ratio * 100).toInt()}%',
                  style: TextStyle(
                    color: isFull ? Colors.yellow : Colors.white70,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 스킬 슬롯 표시
class SkillSlotsDisplay extends StatelessWidget {
  const SkillSlotsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 스킬 1-4
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SkillSlot(
              slotNumber: index + 1,
              keyLabel: ['Q', 'W', 'E', 'R'][index],
              cooldownRatio: 0,
              isReady: true,
            ),
          );
        }),
        const SizedBox(width: 16),
        // 대시
        const SkillSlot(
          slotNumber: 0,
          keyLabel: 'SPACE',
          isReady: true,
          isDash: true,
        ),
        const SizedBox(width: 8),
        // 궁극기
        const SkillSlot(
          slotNumber: 5,
          keyLabel: 'F',
          isReady: false,
          isUltimate: true,
        ),
      ],
    );
  }
}

/// 개별 스킬 슬롯
class SkillSlot extends StatelessWidget {
  const SkillSlot({
    super.key,
    required this.slotNumber,
    required this.keyLabel,
    this.cooldownRatio = 0,
    this.isReady = true,
    this.isDash = false,
    this.isUltimate = false,
  });

  final int slotNumber;
  final String keyLabel;
  final double cooldownRatio;
  final bool isReady;
  final bool isDash;
  final bool isUltimate;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (isUltimate) {
      borderColor = isReady ? Colors.purple : Colors.grey;
    } else if (isDash) {
      borderColor = Colors.cyan;
    } else {
      borderColor = isReady ? Colors.blue : Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 슬롯 박스
        Container(
          width: isDash ? 60 : 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: isUltimate && isReady ? 3 : 2,
            ),
            boxShadow: isUltimate && isReady
                ? [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // 쿨다운 오버레이
              if (cooldownRatio > 0)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: FractionallySizedBox(
                      heightFactor: cooldownRatio,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              // 아이콘
              Center(
                child: Icon(
                  _getSlotIcon(),
                  color: isReady ? Colors.white : Colors.grey,
                  size: isDash ? 20 : 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 키 라벨
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: borderColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            keyLabel,
            style: TextStyle(
              color: borderColor,
              fontSize: isDash ? 8 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getSlotIcon() {
    if (isDash) return Icons.double_arrow;
    if (isUltimate) return Icons.auto_awesome;
    switch (slotNumber) {
      case 1:
        return Icons.flash_on;
      case 2:
        return Icons.shield;
      case 3:
        return Icons.whatshot;
      case 4:
        return Icons.blur_circular;
      default:
        return Icons.circle_outlined;
    }
  }
}

/// 디버그 정보 표시 (개발 중)
class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Phase 2: Core Systems',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 10,
        ),
      ),
    );
  }
}
