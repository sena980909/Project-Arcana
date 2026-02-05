/// Arcana: The Three Hearts - 보스 체력바
/// 화면 상단에 표시되는 대형 보스 체력바
library;

import 'package:flutter/material.dart';

/// 보스 체력바 위젯
class BossHealthBar extends StatelessWidget {
  const BossHealthBar({
    super.key,
    required this.bossName,
    required this.currentHealth,
    required this.maxHealth,
    this.isEnraged = false,
  });

  /// 보스 이름
  final String bossName;

  /// 현재 체력
  final double currentHealth;

  /// 최대 체력
  final double maxHealth;

  /// 분노 모드 여부
  final bool isEnraged;

  @override
  Widget build(BuildContext context) {
    final healthRatio = (currentHealth / maxHealth).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 보스 이름
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isEnraged)
                Icon(
                  Icons.whatshot,
                  color: Colors.red.shade400,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Text(
                bossName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEnraged ? Colors.red.shade400 : Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: isEnraged
                          ? Colors.red.withValues(alpha: 0.8)
                          : Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isEnraged)
                Icon(
                  Icons.whatshot,
                  color: Colors.red.shade400,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 체력바
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isEnraged ? Colors.red.shade600 : Colors.grey.shade600,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEnraged
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // 체력바 배경
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
                    ),
                  ),
                ),

                // 체력바
                FractionallySizedBox(
                  widthFactor: healthRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getHealthBarColors(healthRatio),
                      ),
                    ),
                  ),
                ),

                // 분노 모드 펄스 효과
                if (isEnraged)
                  Positioned.fill(
                    child: _RagePulseEffect(),
                  ),

                // 체력 텍스트
                Center(
                  child: Text(
                    '${currentHealth.toInt()} / ${maxHealth.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 분노 모드 표시
          if (isEnraged)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'ENRAGED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                  letterSpacing: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _getHealthBarColors(double ratio) {
    if (isEnraged || ratio <= 0.3) {
      return [
        Colors.red.shade400,
        Colors.red.shade700,
      ];
    } else if (ratio <= 0.6) {
      return [
        Colors.orange.shade400,
        Colors.orange.shade700,
      ];
    } else {
      return [
        Colors.red.shade600,
        Colors.red.shade900,
      ];
    }
  }
}

/// 분노 모드 펄스 효과
class _RagePulseEffect extends StatefulWidget {
  @override
  State<_RagePulseEffect> createState() => _RagePulseEffectState();
}

class _RagePulseEffectState extends State<_RagePulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.red.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }
}
