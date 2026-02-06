/// Arcana: The Three Hearts - 아이템 데이터 모델
library;

/// 아이템 타입
enum ItemType {
  consumable, // 소비템
  equipment, // 장비
  material, // 재료
  key, // 키 아이템
}

/// 장비 슬롯
enum EquipSlot {
  weapon,
  armor,
  accessory1,
  accessory2,
}

/// 아이템 데이터
class ItemData {
  const ItemData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.price = 0,
    this.sellPrice = 0,
    this.stackable = true,
    this.maxStack = 99,
    this.effect = const {},
    this.equipSlot,
    this.stats = const {},
    this.spriteKey = '',
    this.rarity = 'common',
  });

  final String id;
  final String name;
  final String description;
  final ItemType type;
  final int price;
  final int sellPrice;
  final bool stackable;
  final int maxStack;
  final Map<String, dynamic> effect; // 소비템 효과 (예: {'heal': 30})
  final EquipSlot? equipSlot;
  final Map<String, double> stats; // 장비 스탯 (예: {'damage': 10, 'defense': 5})
  final String spriteKey;
  final String rarity; // common, uncommon, rare, epic, legendary

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      type: ItemType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'consumable'),
        orElse: () => ItemType.consumable,
      ),
      price: json['price'] as int? ?? 0,
      sellPrice: json['sellPrice'] as int? ?? 0,
      stackable: json['stackable'] as bool? ?? true,
      maxStack: json['maxStack'] as int? ?? 99,
      effect: json['effect'] as Map<String, dynamic>? ?? {},
      equipSlot: json['equipSlot'] != null
          ? EquipSlot.values.firstWhere(
              (e) => e.name == json['equipSlot'],
              orElse: () => EquipSlot.weapon,
            )
          : null,
      stats: (json['stats'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      spriteKey: json['spriteKey'] as String? ?? '',
      rarity: json['rarity'] as String? ?? 'common',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'price': price,
        'sellPrice': sellPrice,
        'stackable': stackable,
        'maxStack': maxStack,
        'effect': effect,
        'equipSlot': equipSlot?.name,
        'stats': stats,
        'spriteKey': spriteKey,
        'rarity': rarity,
      };
}

/// 인벤토리 아이템 (스택 포함)
class InventoryItem {
  InventoryItem({
    required this.itemId,
    this.quantity = 1,
  });

  final String itemId;
  int quantity;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemId: json['itemId'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'quantity': quantity,
      };
}
