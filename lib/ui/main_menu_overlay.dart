/// Arcana: The Three Hearts - 메인 메뉴 오버레이
library;

import 'package:flutter/material.dart';

import '../data/services/database_service.dart';
import '../game/systems/audio_system.dart';

/// 메인 메뉴 오버레이
class MainMenuOverlay extends StatefulWidget {
  const MainMenuOverlay({
    required this.onNewGame,
    required this.onContinue,
    required this.onLoadSlot,
    super.key,
  });

  final VoidCallback onNewGame;
  final VoidCallback onContinue;
  final void Function(int slot) onLoadSlot;

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool _showLoadScreen = false;
  List<SaveSlot?> _saveSlots = [null, null, null];
  bool _hasContinueData = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _loadSaveData();

    // 메인 타이틀 BGM 재생
    AudioSystem.instance.playMainTitleBgm();
  }

  Future<void> _loadSaveData() async {
    final slots = await DatabaseService.instance.getAllSaveSlots();
    setState(() {
      _saveSlots = slots;
      _hasContinueData = slots.any((s) => s != null);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0a1a),
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: _showLoadScreen ? _buildLoadScreen() : _buildMainMenu(),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 타이틀
          _buildTitle(),
          const SizedBox(height: 80),

          // 메뉴 버튼들
          _buildMenuButton('새 게임', widget.onNewGame),
          const SizedBox(height: 16),

          if (_hasContinueData) ...[
            _buildMenuButton('이어하기', widget.onContinue),
            const SizedBox(height: 16),
          ],

          _buildMenuButton('불러오기', () {
            setState(() => _showLoadScreen = true);
          }),
          const SizedBox(height: 16),

          _buildMenuButton('설정', () {
            // TODO: 설정 화면
          }, enabled: false),
          const SizedBox(height: 16),

          _buildMenuButton('종료', () {
            // 앱 종료
          }, enabled: false),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // 메인 타이틀
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFFA500),
              Color(0xFFFF6347),
            ],
          ).createShader(bounds),
          child: const Text(
            'ARCANA',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 12,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(4, 4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 서브 타이틀
        const Text(
          'The Three Hearts',
          style: TextStyle(
            fontSize: 24,
            color: Colors.amber,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    String text,
    VoidCallback onTap, {
    bool enabled = true,
  }) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? Colors.amber.withAlpha(30)
              : Colors.grey.withAlpha(20),
          foregroundColor: enabled ? Colors.amber : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: enabled ? Colors.amber.withAlpha(100) : Colors.grey.withAlpha(50),
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadScreen() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withAlpha(100)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '저장 슬롯',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _showLoadScreen = false),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 슬롯들
            for (int i = 0; i < 3; i++) ...[
              _buildSaveSlot(i + 1, _saveSlots[i]),
              if (i < 2) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveSlot(int slot, SaveSlot? saveData) {
    final isEmpty = saveData == null;

    return InkWell(
      onTap: isEmpty ? null : () => widget.onLoadSlot(slot),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmpty
              ? Colors.white.withAlpha(5)
              : Colors.amber.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEmpty ? Colors.white24 : Colors.amber.withAlpha(80),
          ),
        ),
        child: isEmpty
            ? Row(
                children: [
                  const Icon(Icons.save, color: Colors.white30, size: 32),
                  const SizedBox(width: 16),
                  Text(
                    '슬롯 $slot - 비어있음',
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '슬롯 $slot',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          saveData.summary,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDate(saveData.updatedAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
