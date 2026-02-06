/// Arcana: The Three Hearts - 상점 오버레이
library;

import 'package:flutter/material.dart';

/// 상점 아이템
class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final int cost;
  final IconData icon;
}

/// 상점 오버레이
class ShopOverlay extends StatelessWidget {
  const ShopOverlay({
    required this.gold,
    required this.onClose,
    required this.onBuy,
    super.key,
  });

  final int gold;
  final VoidCallback onClose;
  final void Function(String itemId, int cost) onBuy;

  static const List<ShopItem> _items = [
    ShopItem(
      id: 'potion',
      name: '체력 포션',
      description: 'HP를 30 회복합니다.',
      cost: 25,
      icon: Icons.local_drink,
    ),
    ShopItem(
      id: 'mana_potion',
      name: '마나 포션',
      description: 'MP를 20 회복합니다.',
      cost: 20,
      icon: Icons.water_drop,
    ),
    ShopItem(
      id: 'strength_scroll',
      name: '힘의 두루마리',
      description: '30초간 공격력 +20%',
      cost: 50,
      icon: Icons.fitness_center,
    ),
    ShopItem(
      id: 'shield_scroll',
      name: '방어의 두루마리',
      description: '30초간 방어력 +30%',
      cost: 50,
      icon: Icons.shield,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a4a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withAlpha(50),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              _buildHeader(),

              // 아이템 목록
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) => _buildItemTile(_items[index]),
                ),
              ),

              // 푸터
              _buildFooter(),
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
        color: Colors.amber.withAlpha(30),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '여행 상인',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$gold G',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ShopItem item) {
    final canAfford = gold >= item.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canAfford ? Colors.green.withAlpha(100) : Colors.grey.withAlpha(50),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: canAfford ? Colors.green.withAlpha(50) : Colors.grey.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: canAfford ? Colors.green : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            color: canAfford ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          item.description,
          style: TextStyle(
            color: canAfford ? Colors.white70 : Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: canAfford ? () => onBuy(item.id, item.cost) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? Colors.green : Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text('${item.cost} G'),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            label: const Text('닫기 (ESC)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
