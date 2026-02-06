/// Arcana: The Three Hearts - 인벤토리 오버레이
library;

import 'package:flutter/material.dart';

import '../data/models/item_data.dart';
import '../data/repositories/config_repository.dart';

/// 인벤토리 오버레이
class InventoryOverlay extends StatefulWidget {
  const InventoryOverlay({
    required this.inventory,
    required this.equipment,
    required this.onClose,
    required this.onUseItem,
    required this.onEquipItem,
    required this.onUnequipItem,
    super.key,
  });

  final List<InventoryItem> inventory;
  final Map<String, String?> equipment; // slot -> itemId
  final VoidCallback onClose;
  final void Function(String itemId) onUseItem;
  final void Function(String itemId, String slot) onEquipItem;
  final void Function(String slot) onUnequipItem;

  @override
  State<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay> {
  int _selectedTab = 0; // 0: 전체, 1: 소비, 2: 장비, 3: 재료
  String? _selectedItemId;

  List<InventoryItem> get _filteredInventory {
    if (_selectedTab == 0) return widget.inventory;

    final types = [null, ItemType.consumable, ItemType.equipment, ItemType.material];
    final filterType = types[_selectedTab];

    return widget.inventory.where((item) {
      final data = ConfigRepository.instance.getItem(item.itemId);
      return data?.type == filterType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          width: 700,
          height: 500,
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withAlpha(150)),
          ),
          child: Column(
            children: [
              // 헤더
              _buildHeader(),

              // 탭
              _buildTabs(),

              // 메인 콘텐츠
              Expanded(
                child: Row(
                  children: [
                    // 인벤토리 그리드
                    Expanded(
                      flex: 2,
                      child: _buildInventoryGrid(),
                    ),

                    // 구분선
                    Container(width: 1, color: Colors.white24),

                    // 장비 & 아이템 정보
                    Expanded(
                      flex: 1,
                      child: _buildRightPanel(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(30))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '인벤토리',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['전체', '소비', '장비', '재료'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber.withAlpha(50) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white30,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.amber : Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInventoryGrid() {
    final items = _filteredInventory;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 30, // 고정 슬롯 수
      itemBuilder: (context, index) {
        final item = index < items.length ? items[index] : null;
        return _buildItemSlot(item);
      },
    );
  }

  Widget _buildItemSlot(InventoryItem? item) {
    final isSelected = item != null && _selectedItemId == item.itemId;
    final itemData = item != null ? ConfigRepository.instance.getItem(item.itemId) : null;

    return InkWell(
      onTap: item != null ? () => setState(() => _selectedItemId = item.itemId) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withAlpha(50)
              : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? Colors.amber
                : (item != null ? _getRarityColor(itemData?.rarity) : Colors.white24),
          ),
        ),
        child: item != null && itemData != null
            ? Stack(
                children: [
                  // 아이콘
                  Center(
                    child: Icon(
                      _getItemIcon(itemData),
                      color: _getRarityColor(itemData.rarity),
                      size: 24,
                    ),
                  ),
                  // 수량
                  if (item.quantity > 1)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        // 장비 슬롯
        _buildEquipmentPanel(),

        const Divider(color: Colors.white24),

        // 선택된 아이템 정보
        Expanded(child: _buildItemInfo()),
      ],
    );
  }

  Widget _buildEquipmentPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '장비',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEquipSlot('weapon', Icons.gavel, '무기'),
              _buildEquipSlot('armor', Icons.shield, '방어구'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEquipSlot('accessory1', Icons.diamond, '장신구1'),
              _buildEquipSlot('accessory2', Icons.diamond, '장신구2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipSlot(String slot, IconData icon, String label) {
    final itemId = widget.equipment[slot];
    final itemData = itemId != null ? ConfigRepository.instance.getItem(itemId) : null;

    return Column(
      children: [
        InkWell(
          onTap: itemId != null ? () => widget.onUnequipItem(slot) : null,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: itemData != null
                    ? _getRarityColor(itemData.rarity)
                    : Colors.white24,
              ),
            ),
            child: Icon(
              itemData != null ? _getItemIcon(itemData) : icon,
              color: itemData != null
                  ? _getRarityColor(itemData.rarity)
                  : Colors.white30,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildItemInfo() {
    if (_selectedItemId == null) {
      return const Center(
        child: Text(
          '아이템을 선택하세요',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final itemData = ConfigRepository.instance.getItem(_selectedItemId!);
    if (itemData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름
          Text(
            itemData.name,
            style: TextStyle(
              color: _getRarityColor(itemData.rarity),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // 타입
          Text(
            _getItemTypeName(itemData.type),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // 설명
          Text(
            itemData.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // 스탯 (장비인 경우)
          if (itemData.stats.isNotEmpty) ...[
            ...itemData.stats.entries.map((e) => Text(
              '${_getStatName(e.key)}: +${e.value.toInt()}',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            )),
            const SizedBox(height: 12),
          ],

          const Spacer(),

          // 액션 버튼
          if (itemData.type == ItemType.consumable)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onUseItem(_selectedItemId!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withAlpha(200),
                ),
                child: const Text('사용'),
              ),
            ),
          if (itemData.type == ItemType.equipment)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final slot = itemData.equipSlot?.name ?? 'weapon';
                  widget.onEquipItem(_selectedItemId!, slot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withAlpha(200),
                ),
                child: const Text('장착'),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRarityColor(String? rarity) {
    switch (rarity) {
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemIcon(ItemData item) {
    switch (item.type) {
      case ItemType.consumable:
        if (item.id.contains('health')) return Icons.favorite;
        if (item.id.contains('mana')) return Icons.water_drop;
        return Icons.science;
      case ItemType.equipment:
        if (item.equipSlot == EquipSlot.weapon) return Icons.gavel;
        if (item.equipSlot == EquipSlot.armor) return Icons.shield;
        return Icons.diamond;
      case ItemType.material:
        return Icons.category;
      case ItemType.key:
        return Icons.vpn_key;
    }
  }

  String _getItemTypeName(ItemType type) {
    switch (type) {
      case ItemType.consumable:
        return '소비 아이템';
      case ItemType.equipment:
        return '장비';
      case ItemType.material:
        return '재료';
      case ItemType.key:
        return '키 아이템';
    }
  }

  String _getStatName(String stat) {
    switch (stat) {
      case 'damage':
        return '공격력';
      case 'defense':
        return '방어력';
      case 'maxHp':
        return '최대 HP';
      case 'maxMana':
        return '최대 MP';
      case 'speed':
        return '이동속도';
      default:
        return stat;
    }
  }
}
