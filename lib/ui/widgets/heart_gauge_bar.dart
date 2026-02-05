/// Arcana: The Three Hearts - 심장 게이지 바
/// 궁극기 게이지 UI 위젯
library;

import 'package:flutter/material.dart';

/// 심장 게이지 바 위젯
class HeartGaugeBar extends StatelessWidget {
  const HeartGaugeBar({
    super.key,
    required this.current,
    required this.max,
    this.width = 200,
    this.height = 16,
    this.showLabel = true,
  });

  /// 현재 게이지
  final double current;

  /// 최대 게이지
  final double max;

  /// 바 너비
  final double width;

  /// 바 높이
  final double height;

  /// 라벨 표시 여부
  final bool showLabel;

  /// 게이지 비율
  double get ratio => max > 0 ? (current / max).clamp(0.0, 1.0) : 0;

  /// 궁극기 사용 가능 여부 (100% 충전)
  bool get isReady => current >= max;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 심장 아이콘
                Icon(
                  isReady ? Icons.favorite : Icons.favorite_border,
                  color: isReady ? const Color(0xFFFF4081) : Colors.grey,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '심장 게이지',
                  style: TextStyle(
                    color: isReady ? const Color(0xFFFF4081) : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${current.toInt()}/${max.toInt()}',
                  style: TextStyle(
                    color: isReady ? const Color(0xFFFF4081) : Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

        // 게이지 바
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: isReady
                  ? const Color(0xFFFF4081)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // 배경 그라데이션
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade900.withValues(alpha: 0.3),
                      Colors.pink.shade900.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),

              // 게이지 채움
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: width * ratio,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  gradient: LinearGradient(
                    colors: isReady
                        ? [
                            const Color(0xFFFF4081),
                            const Color(0xFFE91E63),
                            const Color(0xFFF50057),
                          ]
                        : [
                            Colors.purple.shade400,
                            Colors.pink.shade400,
                          ],
                  ),
                  boxShadow: isReady
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF4081).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),

              // 광택 효과
              Positioned(
                top: 2,
                left: 4,
                right: 4,
                child: Container(
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 4),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Ready 텍스트 (100% 충전 시)
              if (isReady)
                Center(
                  child: Text(
                    'READY!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height * 0.6,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
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

/// 컴팩트 심장 게이지 (미니 버전)
class HeartGaugeMini extends StatelessWidget {
  const HeartGaugeMini({
    super.key,
    required this.current,
    required this.max,
    this.size = 32,
  });

  final double current;
  final double max;
  final double size;

  double get ratio => max > 0 ? (current / max).clamp(0.0, 1.0) : 0;
  bool get isReady => current >= max;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(
                color: isReady
                    ? const Color(0xFFFF4081)
                    : Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),

          // 게이지 표시 (원형)
          SizedBox(
            width: size - 4,
            height: size - 4,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 3,
              backgroundColor: Colors.purple.shade900.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isReady ? const Color(0xFFFF4081) : Colors.pink.shade400,
              ),
            ),
          ),

          // 중앙 심장 아이콘
          Icon(
            isReady ? Icons.favorite : Icons.favorite_border,
            color: isReady ? const Color(0xFFFF4081) : Colors.white70,
            size: size * 0.5,
          ),
        ],
      ),
    );
  }
}
