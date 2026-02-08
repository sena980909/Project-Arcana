/// Arcana: The Three Hearts - 설정 오버레이
library;

import 'package:flutter/material.dart';

import '../game/systems/audio_system.dart';

/// 설정 오버레이
class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({
    required this.onClose,
    super.key,
  });

  final VoidCallback onClose;

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  late double _bgmVolume;
  late double _sfxVolume;
  late bool _bgmEnabled;
  late bool _sfxEnabled;

  @override
  void initState() {
    super.initState();
    _bgmVolume = AudioSystem.instance.bgmVolume;
    _sfxVolume = AudioSystem.instance.sfxVolume;
    _bgmEnabled = AudioSystem.instance.bgmEnabled;
    _sfxEnabled = AudioSystem.instance.sfxEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withAlpha(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(180),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '설정',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BGM 설정
            _buildToggleRow(
              label: 'BGM',
              icon: Icons.music_note,
              enabled: _bgmEnabled,
              onChanged: (val) {
                setState(() => _bgmEnabled = val);
                AudioSystem.instance.setBgmEnabled(val);
                if (val) {
                  AudioSystem.instance.playMainTitleBgm();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSliderRow(
              label: 'BGM 볼륨',
              value: _bgmVolume,
              enabled: _bgmEnabled,
              onChanged: (val) {
                setState(() => _bgmVolume = val);
                AudioSystem.instance.setBgmVolume(val);
              },
            ),
            const SizedBox(height: 20),

            // SFX 설정
            _buildToggleRow(
              label: 'SFX',
              icon: Icons.volume_up,
              enabled: _sfxEnabled,
              onChanged: (val) {
                setState(() => _sfxEnabled = val);
                AudioSystem.instance.setSfxEnabled(val);
              },
            ),
            const SizedBox(height: 12),
            _buildSliderRow(
              label: 'SFX 볼륨',
              value: _sfxVolume,
              enabled: _sfxEnabled,
              onChanged: (val) {
                setState(() => _sfxVolume = val);
                AudioSystem.instance.setSfxVolume(val);
              },
            ),
            const SizedBox(height: 28),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withAlpha(30),
                  foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.amber.withAlpha(100)),
                  ),
                ),
                child: const Text(
                  '닫기',
                  style: TextStyle(fontSize: 16, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required IconData icon,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: enabled ? Colors.amber : Colors.grey, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white54,
              fontSize: 16,
            ),
          ),
        ),
        Switch(
          value: enabled,
          onChanged: onChanged,
          activeColor: Colors.amber,
          inactiveTrackColor: Colors.grey.shade700,
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        const SizedBox(width: 30),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white70 : Colors.white30,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: enabled ? Colors.amber : Colors.grey,
              inactiveTrackColor: Colors.grey.shade800,
              thumbColor: enabled ? Colors.amber : Colors.grey,
              overlayColor: Colors.amber.withAlpha(30),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              color: enabled ? Colors.white70 : Colors.white30,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
