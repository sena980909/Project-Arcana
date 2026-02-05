/// Arcana: The Three Hearts - 인벤토리 화면
/// 아이템 관리 및 장비 UI
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/item.dart';
import '../../providers/inventory_provider.dart';
import '../widgets/item_slot.dart';

/// 인벤토리 화면
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({
    super.key,
    this.onClose,
    this.onUseItem,
  });

  /// 닫기 콜백
  final VoidCallback? onClose;

  /// 아이템 사용 콜백 (회복량 반환)
  final void Function(int healAmount)? onUseItem;

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int? _selectedSlotIndex;

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 장비 섹션
                    _buildEquipmentSection(inventory),

                    const SizedBox(height: 24),

                    // 골드
                    _buildGoldSection(inventory),

                    const SizedBox(height: 24),

                    // 인벤토리 그리드
                    _buildInventoryGrid(inventory),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 빌드
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade700),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, color: Colors.white),
          const SizedBox(width: 12),
          const Text(
            '인벤토리',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 장비 섹션 빌드
  Widget _buildEquipmentSection(InventoryState inventory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '장비',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 무기 슬롯
            Column(
              children: [
                ItemSlotWidget(
                  slot: inventory.equippedWeapon != null
                      ? InventorySlot(item: inventory.equippedWeapon!)
                      : null,
                  isEquipSlot: true,
                  slotType: ItemType.weapon,
                  onTap: () => _onEquipSlotTap(inventory.equippedWeapon, true),
                ),
                const SizedBox(height: 4),
                Text(
                  '무기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // 방어구 슬롯
            Column(
              children: [
                ItemSlotWidget(
                  slot: inventory.equippedArmor != null
                      ? InventorySlot(item: inventory.equippedArmor!)
                      : null,
                  isEquipSlot: true,
                  slotType: ItemType.armor,
                  onTap: () => _onEquipSlotTap(inventory.equippedArmor, false),
                ),
                const SizedBox(height: 4),
                Text(
                  '방어구',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // 스탯 표시
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatDisplay(
                      icon: Icons.gpp_good,
                      label: '공격력 보너스',
                      value: '+${inventory.totalAttackBonus}',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _StatDisplay(
                      icon: Icons.shield,
                      label: '방어력 보너스',
                      value: '+${inventory.totalDefenseBonus}',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 골드 섹션 빌드
  Widget _buildGoldSection(InventoryState inventory) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on, color: Colors.amber.shade400),
          const SizedBox(width: 8),
          Text(
            '${inventory.gold}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade300,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Gold',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade400,
            ),
          ),
        ],
      ),
    );
  }

  /// 인벤토리 그리드 빌드
  Widget _buildInventoryGrid(InventoryState inventory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '소지품',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${inventory.slots.length}/${inventory.maxSlots}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            inventory.maxSlots,
            (index) {
              final slot =
                  index < inventory.slots.length ? inventory.slots[index] : null;

              return ItemSlotWidget(
                slot: slot,
                isSelected: _selectedSlotIndex == index,
                onTap: () => _onInventorySlotTap(index, slot),
                onLongPress: slot != null
                    ? () => _showItemDetail(slot)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 장비 슬롯 탭
  void _onEquipSlotTap(Item? equippedItem, bool isWeapon) {
    if (equippedItem == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => ItemDetailDialog(
        item: equippedItem,
        onDrop: () {
          Navigator.pop(context);
          if (isWeapon) {
            ref.read(inventoryProvider.notifier).unequipWeapon();
          } else {
            ref.read(inventoryProvider.notifier).unequipArmor();
          }
        },
      ),
    );
  }

  /// 인벤토리 슬롯 탭
  void _onInventorySlotTap(int index, InventorySlot? slot) {
    if (slot == null) {
      setState(() {
        _selectedSlotIndex = null;
      });
      return;
    }

    setState(() {
      _selectedSlotIndex = _selectedSlotIndex == index ? null : index;
    });

    _showItemDetail(slot);
  }

  /// 아이템 상세 표시
  void _showItemDetail(InventorySlot slot) {
    showDialog<void>(
      context: context,
      builder: (context) => ItemDetailDialog(
        item: slot.item,
        quantity: slot.quantity,
        onUse: slot.item.type == ItemType.consumable
            ? () {
                Navigator.pop(context);
                final healAmount = ref
                    .read(inventoryProvider.notifier)
                    .useItem(slot.item.id);
                if (healAmount != null && widget.onUseItem != null) {
                  widget.onUseItem!(healAmount);
                }
              }
            : null,
        onEquip: (slot.item.type == ItemType.weapon ||
                slot.item.type == ItemType.armor)
            ? () {
                Navigator.pop(context);
                if (slot.item.type == ItemType.weapon) {
                  ref.read(inventoryProvider.notifier).equipWeapon(slot.item);
                } else {
                  ref.read(inventoryProvider.notifier).equipArmor(slot.item);
                }
              }
            : null,
        onDrop: () {
          Navigator.pop(context);
          ref.read(inventoryProvider.notifier).removeItem(slot.item.id);
        },
      ),
    );
  }
}

/// 스탯 표시 위젯
class _StatDisplay extends StatelessWidget {
  const _StatDisplay({
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
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
