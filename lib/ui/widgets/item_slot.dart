/// Arcana: The Three Hearts - 아이템 슬롯 위젯
/// 인벤토리 및 장비 UI용
library;

import 'package:flutter/material.dart';

import '../../data/model/item.dart';

/// 아이템 슬롯 위젯
class ItemSlotWidget extends StatelessWidget {
  const ItemSlotWidget({
    super.key,
    this.slot,
    this.isEquipSlot = false,
    this.slotType,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  /// 인벤토리 슬롯 (null이면 빈 슬롯)
  final InventorySlot? slot;

  /// 장비 슬롯 여부
  final bool isEquipSlot;

  /// 슬롯 타입 (장비 슬롯인 경우)
  final ItemType? slotType;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 롱프레스 콜백
  final VoidCallback? onLongPress;

  /// 선택 여부
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final hasItem = slot != null && slot!.item.id.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _getBackgroundColor(hasItem),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(hasItem),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: hasItem ? _buildItemContent() : _buildEmptyContent(),
      ),
    );
  }

  /// 배경색 결정
  Color _getBackgroundColor(bool hasItem) {
    if (!hasItem) {
      return Colors.grey.shade900.withValues(alpha: 0.5);
    }
    return slot!.item.rarityColor.withValues(alpha: 0.2);
  }

  /// 테두리색 결정
  Color _getBorderColor(bool hasItem) {
    if (isSelected) {
      return Colors.yellow;
    }
    if (!hasItem) {
      return Colors.grey.shade700;
    }
    return slot!.item.rarityColor;
  }

  /// 아이템 내용 빌드
  Widget _buildItemContent() {
    return Stack(
      children: [
        // 아이템 아이콘
        Center(
          child: _ItemIcon(item: slot!.item),
        ),

        // 수량 (1개 이상일 때)
        if (slot!.quantity > 1)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${slot!.quantity}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // 희귀도 표시
        Positioned(
          left: 2,
          top: 2,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: slot!.item.rarityColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  /// 빈 슬롯 내용 빌드
  Widget _buildEmptyContent() {
    if (!isEquipSlot || slotType == null) {
      return const SizedBox.shrink();
    }

    // 장비 슬롯 타입 표시
    return Center(
      child: Icon(
        _getSlotTypeIcon(),
        size: 24,
        color: Colors.grey.shade600,
      ),
    );
  }

  /// 슬롯 타입에 따른 아이콘
  IconData _getSlotTypeIcon() {
    switch (slotType) {
      case ItemType.weapon:
        return Icons.gpp_good;
      case ItemType.armor:
        return Icons.shield;
      default:
        return Icons.help_outline;
    }
  }
}

/// 아이템 아이콘 위젯
class _ItemIcon extends StatelessWidget {
  const _ItemIcon({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: item.rarityColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          _getItemIcon(),
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  IconData _getItemIcon() {
    switch (item.type) {
      case ItemType.weapon:
        return Icons.gpp_good;
      case ItemType.armor:
        return Icons.shield;
      case ItemType.consumable:
        return Icons.local_drink;
      case ItemType.key:
        return Icons.vpn_key;
    }
  }
}

/// 아이템 상세 정보 다이얼로그
class ItemDetailDialog extends StatelessWidget {
  const ItemDetailDialog({
    super.key,
    required this.item,
    this.quantity = 1,
    this.onUse,
    this.onEquip,
    this.onDrop,
  });

  final Item item;
  final int quantity;
  final VoidCallback? onUse;
  final VoidCallback? onEquip;
  final VoidCallback? onDrop;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: item.rarityColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                _ItemIcon(item: item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: item.rarityColor,
                        ),
                      ),
                      Text(
                        item.rarity.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: item.rarityColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (quantity > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'x$quantity',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),

            // 설명
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 12),

            // 스탯
            if (item.attackBonus > 0)
              _StatLine(
                icon: Icons.gpp_good,
                label: '공격력',
                value: '+${item.attackBonus}',
                color: Colors.red,
              ),
            if (item.defenseBonus > 0)
              _StatLine(
                icon: Icons.shield,
                label: '방어력',
                value: '+${item.defenseBonus}',
                color: Colors.blue,
              ),
            if (item.healthRestore > 0)
              _StatLine(
                icon: Icons.favorite,
                label: '체력 회복',
                value: '+${item.healthRestore}',
                color: Colors.green,
              ),

            const SizedBox(height: 20),

            // 액션 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDrop != null)
                  TextButton(
                    onPressed: onDrop,
                    child: const Text('버리기',
                        style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(width: 8),
                if (onUse != null && item.type == ItemType.consumable)
                  ElevatedButton(
                    onPressed: onUse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('사용'),
                  ),
                if (onEquip != null &&
                    (item.type == ItemType.weapon ||
                        item.type == ItemType.armor))
                  ElevatedButton(
                    onPressed: onEquip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.rarityColor,
                    ),
                    child: const Text('장착'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 스탯 라인
class _StatLine extends StatelessWidget {
  const _StatLine({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
