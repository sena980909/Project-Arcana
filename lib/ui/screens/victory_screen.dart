/// Arcana: The Three Hearts - 승리 화면
/// 게임 클리어 시 표시되는 화면
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_controller.dart';
import '../../providers/game_state_provider.dart';

/// 승리 화면
class VictoryScreen extends ConsumerWidget {
  const VictoryScreen({
    super.key,
    required this.onMainMenu,
    required this.onNewGame,
    this.endingType = EndingType.normal,
  });

  /// 메인 메뉴 콜백
  final VoidCallback onMainMenu;

  /// 새 게임 콜백
  final VoidCallback onNewGame;

  /// 엔딩 타입
  final EndingType endingType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final isTrueEnding = endingType == EndingType.truE;

    // 엔딩별 색상
    final primaryColor = isTrueEnding ? Colors.cyan : Colors.amber;
    final secondaryColor = isTrueEnding ? Colors.purple : Colors.amber.shade900;

    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1a1a2e),
                    secondaryColor.withValues(alpha: 0.3),
                    const Color(0xFF1a1a2e),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.shade600,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 축하 메시지
                  _VictoryHeader(isTrueEnding: isTrueEnding),

                  const SizedBox(height: 32),

                  // 최종 스탯
                  _FinalStats(
                    gameState: gameState,
                    isTrueEnding: isTrueEnding,
                  ),

                  const SizedBox(height: 32),

                  // 버튼들
                  _VictoryButtons(
                    onMainMenu: onMainMenu,
                    onNewGame: onNewGame,
                    isTrueEnding: isTrueEnding,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 승리 헤더
class _VictoryHeader extends StatelessWidget {
  const _VictoryHeader({this.isTrueEnding = false});

  final bool isTrueEnding;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isTrueEnding ? Colors.cyan : Colors.amber;

    return Column(
      children: [
        // 아이콘
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isTrueEnding
                  ? [Colors.cyan.shade300, Colors.purple.shade700]
                  : [Colors.amber.shade300, Colors.amber.shade700],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            isTrueEnding ? Icons.favorite : Icons.emoji_events,
            size: 64,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // 엔딩 타이틀
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isTrueEnding
                ? [Colors.cyan.shade300, Colors.purple.shade400, Colors.cyan.shade300]
                : [Colors.amber.shade300, Colors.amber.shade600, Colors.amber.shade300],
          ).createShader(bounds),
          child: Text(
            isTrueEnding ? 'TRUE ENDING' : 'ENDING',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 엔딩별 메시지
        Text(
          isTrueEnding
              ? '세 개의 심장이 하나가 되었습니다.\n"기억하겠어. 네가 준 모든 것을."'
              : '망각 속에서 평화를 찾았습니다.\n"잊는 것도... 하나의 평화"',
          style: TextStyle(
            fontSize: 16,
            color: isTrueEnding ? Colors.cyan.shade200 : Colors.amber.shade200,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 최종 스탯
class _FinalStats extends StatelessWidget {
  const _FinalStats({required this.gameState, this.isTrueEnding = false});

  final GameState gameState;
  final bool isTrueEnding;

  @override
  Widget build(BuildContext context) {
    final accentColor = isTrueEnding ? Colors.cyan : Colors.amber;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.shade700.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            isTrueEnding ? '완전한 기록' : '최종 기록',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            icon: Icons.star,
            label: '최종 점수',
            value: isTrueEnding ? '${gameState.score + 10000}' : '${gameState.score}',
            color: accentColor,
          ),
          const Divider(height: 24, color: Colors.grey),
          _StatRow(
            icon: Icons.layers,
            label: '클리어 챕터',
            value: 'Chapter ${gameState.currentFloor}',
            color: Colors.blue,
          ),
          const Divider(height: 24, color: Colors.grey),
          _StatRow(
            icon: Icons.timer,
            label: '플레이 시간',
            value: _formatDuration(gameState.playTime),
            color: Colors.green,
          ),
          const Divider(height: 24, color: Colors.grey),
          _StatRow(
            icon: Icons.pest_control,
            label: '처치한 적',
            value: '${gameState.enemiesKilled}',
            color: Colors.red,
          ),
          const Divider(height: 24, color: Colors.grey),
          _StatRow(
            icon: Icons.inventory_2,
            label: '획득 아이템',
            value: '${gameState.itemsCollected}',
            color: Colors.purple,
          ),
          if (isTrueEnding) ...[
            const Divider(height: 24, color: Colors.grey),
            _StatRow(
              icon: Icons.favorite,
              label: '세 개의 심장',
              value: '완성',
              color: Colors.pink,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}

/// 스탯 행
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 승리 버튼들
class _VictoryButtons extends StatelessWidget {
  const _VictoryButtons({
    required this.onMainMenu,
    required this.onNewGame,
    this.isTrueEnding = false,
  });

  final VoidCallback onMainMenu;
  final VoidCallback onNewGame;
  final bool isTrueEnding;

  @override
  Widget build(BuildContext context) {
    final buttonColor = isTrueEnding ? Colors.cyan.shade700 : Colors.amber.shade700;

    return Column(
      children: [
        // 새 게임
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNewGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.replay),
                const SizedBox(width: 8),
                Text(
                  isTrueEnding ? '새로운 여정' : '새 게임',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 메인 메뉴
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onMainMenu,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home),
                SizedBox(width: 8),
                Text(
                  '메인 메뉴',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
