/// Arcana: The Three Hearts - 대화 오버레이 위젯
/// 게임 내 대화/스토리 표시 UI
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/model/dialogue.dart';

/// 대화 오버레이 위젯
class DialogueOverlay extends StatefulWidget {
  const DialogueOverlay({
    required this.node,
    required this.choices,
    required this.onAdvance,
    required this.onChoiceSelected,
    super.key,
  });

  /// 현재 대화 노드
  final DialogueNode node;

  /// 표시할 선택지 목록
  final List<DialogueChoice> choices;

  /// 다음 대화로 진행 콜백
  final VoidCallback onAdvance;

  /// 선택지 선택 콜백
  final void Function(int index) onChoiceSelected;

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  /// 타이핑 효과용 표시할 텍스트 길이
  int _displayedTextLength = 0;

  /// 타이핑 완료 여부
  bool _typingComplete = false;

  /// 타이핑 속도 (밀리초/글자)
  static const int _typingSpeed = 30;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
    _startTypingEffect();
  }

  @override
  void didUpdateWidget(DialogueOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 노드가 변경되면 타이핑 효과 재시작
    if (oldWidget.node.id != widget.node.id) {
      _displayedTextLength = 0;
      _typingComplete = false;
      _startTypingEffect();
    }
  }

  /// 타이핑 효과 시작
  void _startTypingEffect() {
    final text = widget.node.text;
    _displayedTextLength = 0;
    _typingComplete = false;

    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(milliseconds: _typingSpeed));

      if (!mounted) return false;

      if (_displayedTextLength < text.length) {
        setState(() {
          _displayedTextLength++;
        });
        return true;
      } else {
        setState(() {
          _typingComplete = true;
        });
        return false;
      }
    });
  }

  /// 타이핑 스킵 (즉시 완료)
  void _skipTyping() {
    setState(() {
      _displayedTextLength = widget.node.text.length;
      _typingComplete = true;
    });
  }

  /// 탭 처리
  void _handleTap() {
    if (!_typingComplete) {
      _skipTyping();
      return;
    }

    // 선택지가 있으면 진행 불가
    if (widget.node.hasChoices) {
      return;
    }

    widget.onAdvance();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _handleTap();
          }
        }
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 대화 박스
                    _buildDialogueBox(context),

                    // 선택지 (있는 경우)
                    if (widget.node.hasChoices && _typingComplete)
                      _buildChoices(context),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 대화 박스 빌드
  Widget _buildDialogueBox(BuildContext context) {
    final speakerName = _getSpeakerName(widget.node.speakerId);
    final displayedText = widget.node.text.substring(0, _displayedTextLength);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSpeakerColor(widget.node.speakerId),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSpeakerColor(widget.node.speakerId).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 화자 이름
          if (speakerName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                speakerName,
                style: TextStyle(
                  color: _getSpeakerColor(widget.node.speakerId),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // 대화 내용
          Text(
            displayedText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),

          // 진행 표시 (타이핑 완료 & 선택지 없음)
          if (_typingComplete && !widget.node.hasChoices)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBlinkingIndicator(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 깜빡이는 진행 표시
  Widget _buildBlinkingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 2).clamp(0, 1) > 0.5
              ? 1 - ((value * 2) - 1)
              : value * 2,
          child: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white70,
            size: 24,
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  /// 선택지 빌드
  Widget _buildChoices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: List.generate(widget.choices.length, (index) {
          final choice = widget.choices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ChoiceButton(
              text: choice.text,
              index: index + 1,
              onTap: () => widget.onChoiceSelected(index),
            ),
          );
        }),
      ),
    );
  }

  /// 화자 이름 반환
  String _getSpeakerName(String speakerId) {
    switch (speakerId) {
      case 'player':
        return '';
      case 'system':
        return '';
      case 'unknown':
        return '???';
      case 'liliana':
        return '릴리아나';
      case 'volkan':
        return '볼칸';
      case 'elias':
        return '엘리아스';
      case 'merchant':
        return '상인';
      case 'ash_merchant':
        return '재의 상인';
      case 'yggdra':
        return '이그드라';
      default:
        return speakerId;
    }
  }

  /// 화자별 테마 색상
  Color _getSpeakerColor(String speakerId) {
    switch (speakerId) {
      case 'player':
        return Colors.cyan;
      case 'system':
        return Colors.grey;
      case 'unknown':
        return Colors.purple;
      case 'liliana':
        return Colors.pink;
      case 'ash_merchant':
        return Colors.orange;
      case 'yggdra':
        return Colors.green;
      default:
        return Colors.white70;
    }
  }
}

/// 선택지 버튼 위젯
class _ChoiceButton extends StatefulWidget {
  const _ChoiceButton({
    required this.text,
    required this.index,
    required this.onTap,
  });

  final String text;
  final int index;
  final VoidCallback onTap;

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isHovered ? Colors.cyan : Colors.white30,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 번호
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _isHovered ? Colors.cyan : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      color: _isHovered ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 텍스트
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _isHovered ? Colors.cyan : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
