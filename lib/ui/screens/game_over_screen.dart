/// Arcana: The Three Hearts - 게임 오버 화면
/// PRD 기반 게임 오버 UI
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_state_provider.dart';

/// 게임 오버 화면
class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({
    super.key,
    required this.onRestart,
    required this.onMainMenu,
  });

  /// 재시작 콜백
  final VoidCallback onRestart;

  /// 메인 메뉴 콜백
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.shade800,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade900.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 게임 오버 타이틀
              const _GameOverTitle(),

              const SizedBox(height: 24),

              // 통계
              _StatsSection(gameState: gameState),

              const SizedBox(height: 32),

              // 버튼들
              _ActionButtons(
                onRestart: onRestart,
                onMainMenu: onMainMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 게임 오버 타이틀
class _GameOverTitle extends StatelessWidget {
  const _GameOverTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 해골 아이콘
        Icon(
          Icons.dangerous,
          size: 64,
          color: Colors.red.shade600,
        ),

        const SizedBox(height: 16),

        // GAME OVER 텍스트
        Text(
          'GAME OVER',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade500,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Colors.red.shade900,
                blurRadius: 10,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 부제
        Text(
          '영혼이 흩어졌습니다...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// 통계 섹션
class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.layers,
            label: '도달 챕터',
            value: 'Chapter ${gameState.currentFloor}',
          ),
          const Divider(height: 16, color: Colors.grey),
          _StatRow(
            icon: Icons.star,
            label: '점수',
            value: '${gameState.score}',
          ),
          const Divider(height: 16, color: Colors.grey),
          _StatRow(
            icon: Icons.timer,
            label: '플레이 시간',
            value: _formatDuration(gameState.playTime),
          ),
          const Divider(height: 16, color: Colors.grey),
          _StatRow(
            icon: Icons.pest_control,
            label: '처치한 적',
            value: '${gameState.enemiesKilled}',
          ),
          const Divider(height: 16, color: Colors.grey),
          _StatRow(
            icon: Icons.inventory_2,
            label: '획득 아이템',
            value: '${gameState.itemsCollected}',
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 통계 행
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 8),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// 액션 버튼들
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onRestart,
    required this.onMainMenu,
  });

  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 재시작 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onRestart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text(
                  '다시 시작',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 메인 메뉴 버튼
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
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
