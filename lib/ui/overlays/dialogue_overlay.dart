/// Arcana: The Three Hearts - 대화 오버레이
/// 대화 UI 위젯
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/model/dialogue.dart';

/// 대화 오버레이 위젯
class DialogueOverlay extends StatefulWidget {
  const DialogueOverlay({
    super.key,
    required this.currentNode,
    required this.visibleChoices,
    required this.onAdvance,
    required this.onChoiceSelected,
  });

  /// 현재 대화 노드
  final DialogueNode currentNode;

  /// 표시할 선택지 목록
  final List<DialogueChoice> visibleChoices;

  /// 다음 대화로 진행 콜백
  final VoidCallback onAdvance;

  /// 선택지 선택 콜백
  final void Function(int index) onChoiceSelected;

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 포커스 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// 키보드 이벤트 처리
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // 스페이스바 또는 엔터키로 대화 진행
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (widget.visibleChoices.isEmpty) {
          widget.onAdvance();
          return KeyEventResult.handled;
        }
      }

      // 숫자키로 선택지 선택 (1, 2, 3, 4)
      if (widget.visibleChoices.isNotEmpty) {
        final keyNumber = _getNumberFromKey(event.logicalKey);
        if (keyNumber != null && keyNumber > 0 && keyNumber <= widget.visibleChoices.length) {
          widget.onChoiceSelected(keyNumber - 1);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  /// 키에서 숫자 추출
  int? _getNumberFromKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) return 1;
    if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) return 2;
    if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) return 3;
    if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) return 4;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.visibleChoices.isEmpty ? widget.onAdvance : null,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: SafeArea(
            child: Column(
              children: [
                // 상단 여백
                const Spacer(),

                // 대화 박스
                _buildDialogueBox(context),

                // 하단 여백
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 대화 박스 빌드
  Widget _buildDialogueBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        border: Border.all(
          color: const Color(0xFF8B4513),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 화자 이름
          _buildSpeakerName(),

          // 대사 텍스트
          _buildDialogueText(),

          // 선택지 (있는 경우)
          if (widget.visibleChoices.isNotEmpty) _buildChoices(),

          // 진행 안내 (선택지 없는 경우)
          if (widget.visibleChoices.isEmpty) _buildContinueHint(),
        ],
      ),
    );
  }

  /// 화자 이름
  Widget _buildSpeakerName() {
    final speaker = Speakers.findById(widget.currentNode.speakerId);
    final speakerName = speaker?.name ?? widget.currentNode.speakerId;

    if (speakerName.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF8B4513),
            width: 2,
          ),
        ),
      ),
      child: Text(
        speakerName,
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 대사 텍스트
  Widget _buildDialogueText() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.currentNode.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  /// 선택지 목록
  Widget _buildChoices() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(color: Color(0xFF8B4513)),
          const SizedBox(height: 8),
          ...widget.visibleChoices.asMap().entries.map((entry) {
            return _buildChoiceButton(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  /// 선택지 버튼
  Widget _buildChoiceButton(int index, DialogueChoice choice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onChoiceSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8B4513),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D1B4E).withValues(alpha: 0.8),
                  const Color(0xFF1a1a2e).withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                // 선택지 번호
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF1a1a2e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 선택지 텍스트
                Expanded(
                  child: Text(
                    choice.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),

                // 화살표
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 진행 안내
  Widget _buildContinueHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '[Space] 또는 터치하여 계속',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.5),
            size: 12,
          ),
        ],
      ),
    );
  }
}

/// 대화 상태 관리 위젯
class DialogueOverlayController extends StatefulWidget {
  const DialogueOverlayController({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DialogueOverlayController> createState() => DialogueOverlayControllerState();
}

class DialogueOverlayControllerState extends State<DialogueOverlayController> {
  DialogueNode? _currentNode;
  List<DialogueChoice> _visibleChoices = [];
  VoidCallback? _onAdvance;
  void Function(int)? _onChoiceSelected;

  /// 대화 표시
  void showDialogue({
    required DialogueNode node,
    required List<DialogueChoice> visibleChoices,
    required VoidCallback onAdvance,
    required void Function(int) onChoiceSelected,
  }) {
    setState(() {
      _currentNode = node;
      _visibleChoices = visibleChoices;
      _onAdvance = onAdvance;
      _onChoiceSelected = onChoiceSelected;
    });
  }

  /// 대화 숨기기
  void hideDialogue() {
    setState(() {
      _currentNode = null;
      _visibleChoices = [];
      _onAdvance = null;
      _onChoiceSelected = null;
    });
  }

  /// 현재 대화 노드 업데이트
  void updateNode({
    required DialogueNode node,
    required List<DialogueChoice> visibleChoices,
  }) {
    setState(() {
      _currentNode = node;
      _visibleChoices = visibleChoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentNode != null)
          DialogueOverlay(
            currentNode: _currentNode!,
            visibleChoices: _visibleChoices,
            onAdvance: _onAdvance ?? () {},
            onChoiceSelected: _onChoiceSelected ?? (_) {},
          ),
      ],
    );
  }
}
