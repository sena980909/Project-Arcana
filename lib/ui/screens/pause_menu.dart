/// Arcana: The Three Hearts - 일시정지 메뉴
/// 게임 중 일시정지 오버레이
library;

import 'package:flutter/material.dart';

/// 일시정지 메뉴
class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
    this.onSettings,
    this.currentFloor = 1,
  });

  /// 게임 재개 콜백
  final VoidCallback onResume;

  /// 재시작 콜백
  final VoidCallback onRestart;

  /// 메인 메뉴 콜백
  final VoidCallback onMainMenu;

  /// 설정 콜백
  final VoidCallback? onSettings;

  /// 현재 층
  final int currentFloor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade700,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀
                const _PauseTitle(),

                const SizedBox(height: 16),

                // 현재 상태
                _StatusInfo(currentFloor: currentFloor),

                const SizedBox(height: 24),

                // 버튼들
                _PauseButtons(
                  onResume: onResume,
                  onRestart: onRestart,
                  onMainMenu: onMainMenu,
                  onSettings: onSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 일시정지 타이틀
class _PauseTitle extends StatelessWidget {
  const _PauseTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.pause_circle_outline,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        const Text(
          '일시정지',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// 현재 상태 정보
class _StatusInfo extends StatelessWidget {
  const _StatusInfo({required this.currentFloor});

  final int currentFloor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers,
            size: 20,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            'Chapter $currentFloor',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

/// 일시정지 버튼들
class _PauseButtons extends StatelessWidget {
  const _PauseButtons({
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
    this.onSettings,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 계속하기
        _PauseButton(
          text: '계속하기',
          icon: Icons.play_arrow,
          onPressed: onResume,
          isPrimary: true,
        ),

        const SizedBox(height: 12),

        // 재시작
        _PauseButton(
          text: '재시작',
          icon: Icons.refresh,
          onPressed: () => _showConfirmDialog(
            context,
            '재시작',
            '현재 진행 상황이 사라집니다.\n정말 재시작하시겠습니까?',
            onRestart,
          ),
        ),

        const SizedBox(height: 12),

        // 설정
        if (onSettings != null) ...[
          _PauseButton(
            text: '설정',
            icon: Icons.settings,
            onPressed: onSettings!,
          ),
          const SizedBox(height: 12),
        ],

        // 메인 메뉴
        _PauseButton(
          text: '메인 메뉴',
          icon: Icons.home,
          onPressed: () => _showConfirmDialog(
            context,
            '메인 메뉴',
            '현재 진행 상황이 사라집니다.\n메인 메뉴로 이동하시겠습니까?',
            onMainMenu,
          ),
          isDanger: true,
        ),
      ],
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 일시정지 버튼
class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isDanger = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    if (isPrimary) {
      backgroundColor = const Color(0xFF4CAF50);
      foregroundColor = Colors.white;
      borderColor = Colors.green.shade300;
    } else if (isDanger) {
      backgroundColor = Colors.transparent;
      foregroundColor = Colors.red.shade400;
      borderColor = Colors.red.shade400;
    } else {
      backgroundColor = Colors.grey.shade800;
      foregroundColor = Colors.white;
      borderColor = Colors.grey.shade600;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: 2),
          ),
          elevation: isPrimary ? 4 : 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
