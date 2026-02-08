/// Arcana: The Three Hearts - 모바일 터치 컨트롤
library;

import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';

/// 모바일 가상 조이스틱 + 액션 버튼 오버레이
class MobileControls extends StatefulWidget {
  const MobileControls({
    required this.onDirectionChanged,
    required this.onAttack,
    required this.onDash,
    required this.onSkill,
    required this.onUltimate,
    this.onRestart,
    this.onInteract,
    this.showInteractButton = false,
    this.showRestartButton = false,
    super.key,
  });

  final ValueChanged<Vector2> onDirectionChanged;
  final VoidCallback onAttack;
  final VoidCallback onDash;
  final ValueChanged<int> onSkill;
  final VoidCallback onUltimate;
  final VoidCallback? onRestart;
  final VoidCallback? onInteract;
  final bool showInteractButton;
  final bool showRestartButton;

  @override
  State<MobileControls> createState() => _MobileControlsState();
}

class _MobileControlsState extends State<MobileControls> {
  // 조이스틱 상태
  Offset _joystickCenter = Offset.zero;
  Offset _joystickKnob = Offset.zero;
  bool _joystickActive = false;
  int? _joystickPointerId;

  static const double _joystickRadius = 50.0;
  static const double _knobRadius = 20.0;
  static const double _deadZone = 0.15;

  void _onJoystickDown(PointerDownEvent event) {
    _joystickPointerId = event.pointer;
    setState(() {
      _joystickCenter = event.localPosition;
      _joystickKnob = event.localPosition;
      _joystickActive = true;
    });
    widget.onDirectionChanged(Vector2.zero());
  }

  void _onJoystickMove(PointerMoveEvent event) {
    if (!_joystickActive || event.pointer != _joystickPointerId) return;

    final delta = event.localPosition - _joystickCenter;
    final distance = delta.distance;

    // 조이스틱 범위 내로 클램프
    final clampedDelta = distance > _joystickRadius
        ? (delta / distance) * _joystickRadius
        : delta;

    setState(() {
      _joystickKnob = _joystickCenter + clampedDelta;
    });

    // 방향 계산 (정규화)
    final normalizedDistance = (distance / _joystickRadius).clamp(0.0, 1.0);
    if (normalizedDistance < _deadZone) {
      widget.onDirectionChanged(Vector2.zero());
    } else {
      final dir = Vector2(clampedDelta.dx, clampedDelta.dy);
      if (dir.length > 0) dir.normalize();
      widget.onDirectionChanged(dir);
    }
  }

  void _onJoystickUp(PointerUpEvent event) {
    if (event.pointer != _joystickPointerId) return;
    _joystickPointerId = null;
    setState(() {
      _joystickActive = false;
    });
    widget.onDirectionChanged(Vector2.zero());
  }

  void _onJoystickCancel(PointerCancelEvent event) {
    if (event.pointer != _joystickPointerId) return;
    _joystickPointerId = null;
    setState(() {
      _joystickActive = false;
    });
    widget.onDirectionChanged(Vector2.zero());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 왼쪽: 조이스틱 영역
        Positioned(
          left: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.45,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Listener(
            onPointerDown: _onJoystickDown,
            onPointerMove: _onJoystickMove,
            onPointerUp: _onJoystickUp,
            onPointerCancel: _onJoystickCancel,
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: _JoystickPainter(
                center: _joystickCenter,
                knob: _joystickKnob,
                active: _joystickActive,
                joystickRadius: _joystickRadius,
                knobRadius: _knobRadius,
              ),
            ),
          ),
        ),

        // 오른쪽: 액션 버튼
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildActionButtons(),
        ),

        // NPC 상호작용 버튼 (NPC 근처일 때만)
        if (widget.showInteractButton && widget.onInteract != null)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            bottom: 80,
            child: _ActionButton(
              label: 'TALK',
              size: 56,
              color: Colors.amber.shade700,
              borderColor: Colors.yellow,
              onPressed: widget.onInteract!,
            ),
          ),

        // 게임오버 시 재시작 버튼
        if (widget.showRestartButton && widget.onRestart != null)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            bottom: MediaQuery.of(context).size.height / 2 - 30,
            child: _ActionButton(
              label: 'RETRY',
              size: 80,
              color: Colors.red.shade700,
              borderColor: Colors.yellow,
              onPressed: widget.onRestart!,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: 170,
      height: 200,
      child: Stack(
        children: [
          // 공격 버튼 (크고 중앙)
          Positioned(
            right: 0,
            bottom: 40,
            child: _ActionButton(
              label: 'ATK',
              size: 64,
              color: Colors.red.shade700,
              onPressed: widget.onAttack,
            ),
          ),

          // 대시 버튼
          Positioned(
            right: 70,
            bottom: 10,
            child: _ActionButton(
              label: 'DASH',
              size: 48,
              color: Colors.cyan.shade700,
              onPressed: widget.onDash,
            ),
          ),

          // 스킬 Q
          Positioned(
            left: 0,
            top: 60,
            child: _ActionButton(
              label: 'Q',
              size: 44,
              color: Colors.orange.shade700,
              onPressed: () => widget.onSkill(0),
            ),
          ),

          // 스킬 E
          Positioned(
            left: 50,
            top: 30,
            child: _ActionButton(
              label: 'E',
              size: 44,
              color: Colors.green.shade700,
              onPressed: () => widget.onSkill(1),
            ),
          ),

          // 스킬 X
          Positioned(
            left: 100,
            top: 10,
            child: _ActionButton(
              label: 'X',
              size: 44,
              color: Colors.blue.shade700,
              onPressed: () => widget.onSkill(2),
            ),
          ),

          // 궁극기 R
          Positioned(
            right: 70,
            top: 0,
            child: _ActionButton(
              label: 'R',
              size: 48,
              color: Colors.purple.shade700,
              borderColor: Colors.yellow.shade600,
              onPressed: widget.onUltimate,
            ),
          ),
        ],
      ),
    );
  }
}

/// 액션 버튼 위젯
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.size,
    required this.color,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final double size;
  final Color color;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onPressed();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? widget.color.withAlpha(220)
              : widget.color.withAlpha(140),
          border: Border.all(
            color: widget.borderColor ?? Colors.white.withAlpha(80),
            width: widget.borderColor != null ? 2.5 : 1.5,
          ),
          boxShadow: _pressed
              ? null
              : [
                  BoxShadow(
                    color: widget.color.withAlpha(60),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white.withAlpha(_pressed ? 255 : 200),
              fontSize: widget.size * 0.28,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 조이스틱 그리기
class _JoystickPainter extends CustomPainter {
  _JoystickPainter({
    required this.center,
    required this.knob,
    required this.active,
    required this.joystickRadius,
    required this.knobRadius,
  });

  final Offset center;
  final Offset knob;
  final bool active;
  final double joystickRadius;
  final double knobRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) {
      // 비활성 시 힌트 표시
      final hintCenter = Offset(size.width * 0.45, size.height * 0.55);
      canvas.drawCircle(
        hintCenter,
        joystickRadius,
        Paint()..color = Colors.white.withAlpha(20),
      );
      canvas.drawCircle(
        hintCenter,
        joystickRadius,
        Paint()
          ..color = Colors.white.withAlpha(30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        hintCenter,
        knobRadius,
        Paint()..color = Colors.white.withAlpha(25),
      );
      return;
    }

    // 외부 원 (베이스)
    canvas.drawCircle(
      center,
      joystickRadius,
      Paint()..color = Colors.white.withAlpha(30),
    );
    canvas.drawCircle(
      center,
      joystickRadius,
      Paint()
        ..color = Colors.white.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 내부 원 (노브)
    canvas.drawCircle(
      knob,
      knobRadius,
      Paint()..color = Colors.white.withAlpha(80),
    );
    canvas.drawCircle(
      knob,
      knobRadius,
      Paint()
        ..color = Colors.white.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.knob != knob ||
        oldDelegate.active != active;
  }
}
