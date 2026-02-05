/// Arcana: The Three Hearts - 메인 메뉴 화면
/// 게임 시작 화면
library;

import 'package:flutter/material.dart';
import '../../game/managers/audio_manager.dart';

/// 메인 메뉴 화면
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({
    super.key,
    required this.onStartGame,
    this.onContinue,
    this.onSettings,
    this.hasSaveData = false,
  });

  /// 새 게임 시작 콜백
  final VoidCallback onStartGame;

  /// 이어하기 콜백
  final VoidCallback? onContinue;

  /// 설정 콜백
  final VoidCallback? onSettings;

  /// 저장 데이터 존재 여부
  final bool hasSaveData;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    // 메인 메뉴 BGM 재생
    AudioManager.instance.playBgm(BgmTrack.mainMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0a1a),
              Color(0xFF1a1a3e),
              Color(0xFF0a0a1a),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 타이틀
                  const _GameTitle(),

                  const SizedBox(height: 60),

                  // 메뉴 버튼들
                  _MenuButtons(
                    onStartGame: widget.onStartGame,
                    onContinue: widget.onContinue,
                    onSettings: widget.onSettings,
                    hasSaveData: widget.hasSaveData,
                  ),

                  const SizedBox(height: 60),

                  // 버전 정보
                  const _VersionInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 게임 타이틀
class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 심볼 (3개의 하트)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HeartSymbol(color: Colors.red.shade400, label: 'Body'),
            const SizedBox(width: 24),
            _HeartSymbol(color: Colors.blue.shade400, label: 'Mind'),
            const SizedBox(width: 24),
            _HeartSymbol(color: Colors.purple.shade400, label: 'Soul'),
          ],
        ),

        const SizedBox(height: 32),

        // 메인 타이틀
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFFA500),
              Color(0xFFFFD700),
            ],
          ).createShader(bounds),
          child: const Text(
            'ARCANA',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 12,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 서브 타이틀
        Text(
          'THE THREE HEARTS',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade400,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }
}

/// 하트 심볼
class _HeartSymbol extends StatelessWidget {
  const _HeartSymbol({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 메뉴 버튼들
class _MenuButtons extends StatelessWidget {
  const _MenuButtons({
    required this.onStartGame,
    this.onContinue,
    this.onSettings,
    required this.hasSaveData,
  });

  final VoidCallback onStartGame;
  final VoidCallback? onContinue;
  final VoidCallback? onSettings;
  final bool hasSaveData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이어하기 (저장 데이터가 있을 때만)
        if (hasSaveData && onContinue != null) ...[
          _MenuButton(
            text: '이어하기',
            icon: Icons.play_arrow,
            onPressed: onContinue!,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
        ],

        // 새 게임
        _MenuButton(
          text: '새 게임',
          icon: Icons.add,
          onPressed: onStartGame,
          isPrimary: !hasSaveData,
        ),

        const SizedBox(height: 16),

        // 설정
        if (onSettings != null)
          _MenuButton(
            text: '설정',
            icon: Icons.settings,
            onPressed: onSettings!,
          ),
      ],
    );
  }
}

/// 메뉴 버튼
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFFFD700)
              : Colors.grey.shade800,
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isPrimary
                  ? const Color(0xFFFFA500)
                  : Colors.grey.shade600,
              width: 2,
            ),
          ),
          elevation: isPrimary ? 8 : 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 버전 정보
class _VersionInfo extends StatelessWidget {
  const _VersionInfo();

  @override
  Widget build(BuildContext context) {
    return Text(
      'v0.3.0 - Phase 3',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
    );
  }
}
