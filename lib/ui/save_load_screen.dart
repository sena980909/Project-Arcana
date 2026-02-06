/// Arcana: The Three Hearts - 저장/불러오기 화면
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/database_service.dart';
import '../providers/game_providers.dart';

/// 저장/불러오기 화면
class SaveLoadScreen extends ConsumerStatefulWidget {
  const SaveLoadScreen({
    required this.mode,
    required this.onClose,
    this.onSaveComplete,
    this.onLoadComplete,
    super.key,
  });

  final SaveLoadMode mode;
  final VoidCallback onClose;
  final VoidCallback? onSaveComplete;
  final VoidCallback? onLoadComplete;

  @override
  ConsumerState<SaveLoadScreen> createState() => _SaveLoadScreenState();
}

enum SaveLoadMode { save, load }

class _SaveLoadScreenState extends ConsumerState<SaveLoadScreen> {
  List<SaveSlot?> _saveSlots = [null, null, null];
  bool _isLoading = true;
  int? _selectedSlot;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSaveSlots();
  }

  Future<void> _loadSaveSlots() async {
    setState(() => _isLoading = true);

    try {
      final slots = await DatabaseService.instance.getAllSaveSlots();
      setState(() {
        _saveSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _saveSlots = [null, null, null];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGame(int slot) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final playerState = ref.read(playerStateProvider);
      final gameState = ref.read(gameStateProvider);

      await DatabaseService.instance.saveGame(slot, playerState, gameState);

      await _loadSaveSlots();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('슬롯 $slot에 저장되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onSaveComplete?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _loadGame(int slot) async {
    if (_isProcessing) return;

    final saveSlot = _saveSlots[slot - 1];
    if (saveSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('빈 슬롯입니다.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      ref.read(playerStateProvider.notifier).loadState(saveSlot.playerState);
      ref.read(gameStateProvider.notifier).loadState(saveSlot.gameState);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('슬롯 $slot에서 불러왔습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onLoadComplete?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('불러오기 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteSlot(int slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('저장 데이터 삭제', style: TextStyle(color: Colors.white)),
        content: Text(
          '슬롯 $slot의 저장 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteSave(slot);
      await _loadSaveSlots();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('슬롯 $slot 삭제됨'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(150),
                blurRadius: 20,
                spreadRadius: 5,
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
                  Text(
                    widget.mode == SaveLoadMode.save ? '게임 저장' : '게임 불러오기',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 로딩 인디케이터
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.amber),
                )
              else
                // 슬롯 목록
                Column(
                  children: [
                    for (int i = 1; i <= 3; i++) _buildSlotCard(i),
                  ],
                ),

              const SizedBox(height: 16),

              // 닫기 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(int slot) {
    final saveSlot = _saveSlots[slot - 1];
    final isEmpty = saveSlot == null;
    final isSelected = _selectedSlot == slot;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.amber.withAlpha(30)
            : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.white.withAlpha(30),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedSlot = slot);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 슬롯 번호
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? Colors.grey.withAlpha(50)
                        : Colors.amber.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$slot',
                      style: TextStyle(
                        color: isEmpty ? Colors.grey : Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 슬롯 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEmpty ? '빈 슬롯' : saveSlot.summary,
                        style: TextStyle(
                          color: isEmpty ? Colors.grey : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '저장: ${_formatDateTime(saveSlot.updatedAt)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 액션 버튼
                Row(
                  children: [
                    if (widget.mode == SaveLoadMode.save)
                      _buildActionButton(
                        icon: Icons.save,
                        label: isEmpty ? '저장' : '덮어쓰기',
                        color: Colors.green,
                        onPressed: () => _saveGame(slot),
                      ),
                    if (widget.mode == SaveLoadMode.load && !isEmpty)
                      _buildActionButton(
                        icon: Icons.play_arrow,
                        label: '불러오기',
                        color: Colors.blue,
                        onPressed: () => _loadGame(slot),
                      ),
                    if (!isEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _deleteSlot(slot),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: '삭제',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(200),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: _isProcessing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
