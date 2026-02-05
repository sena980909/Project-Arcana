/// Arcana: The Three Hearts - 인벤토리 관리
/// Riverpod 기반 인벤토리 Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/item.dart';

/// 인벤토리 상태
class InventoryState {
  const InventoryState({
    this.slots = const [],
    this.maxSlots = 20,
    this.equippedWeapon,
    this.equippedArmor,
    this.gold = 0,
  });

  /// 인벤토리 슬롯 목록
  final List<InventorySlot> slots;

  /// 최대 슬롯 수
  final int maxSlots;

  /// 장착된 무기
  final Item? equippedWeapon;

  /// 장착된 방어구
  final Item? equippedArmor;

  /// 보유 골드
  final int gold;

  /// 총 공격력 보너스
  int get totalAttackBonus => equippedWeapon?.attackBonus ?? 0;

  /// 총 방어력 보너스
  int get totalDefenseBonus => equippedArmor?.defenseBonus ?? 0;

  /// 복사본 생성
  InventoryState copyWith({
    List<InventorySlot>? slots,
    int? maxSlots,
    Item? equippedWeapon,
    Item? equippedArmor,
    int? gold,
    bool clearWeapon = false,
    bool clearArmor = false,
  }) {
    return InventoryState(
      slots: slots ?? this.slots,
      maxSlots: maxSlots ?? this.maxSlots,
      equippedWeapon: clearWeapon ? null : (equippedWeapon ?? this.equippedWeapon),
      equippedArmor: clearArmor ? null : (equippedArmor ?? this.equippedArmor),
      gold: gold ?? this.gold,
    );
  }
}

/// 인벤토리 Notifier
class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState());

  /// 아이템 추가
  bool addItem(Item item, {int quantity = 1}) {
    final newSlots = List<InventorySlot>.from(state.slots);

    // 중첩 가능한 아이템이면 기존 슬롯에 추가 시도
    if (item.stackable) {
      final existingSlotIndex = newSlots.indexWhere(
        (slot) => slot.item.id == item.id && slot.quantity < item.maxStack,
      );

      if (existingSlotIndex != -1) {
        final existingSlot = newSlots[existingSlotIndex];
        final canAdd = item.maxStack - existingSlot.quantity;
        final toAdd = quantity > canAdd ? canAdd : quantity;

        newSlots[existingSlotIndex] = InventorySlot(
          item: item,
          quantity: existingSlot.quantity + toAdd,
        );

        // 남은 수량이 있으면 새 슬롯에 추가
        final remaining = quantity - toAdd;
        if (remaining > 0) {
          if (newSlots.length >= state.maxSlots) return false;
          newSlots.add(InventorySlot(item: item, quantity: remaining));
        }

        state = state.copyWith(slots: newSlots);
        return true;
      }
    }

    // 새 슬롯에 추가
    if (newSlots.length >= state.maxSlots) return false;

    newSlots.add(InventorySlot(item: item, quantity: quantity));
    state = state.copyWith(slots: newSlots);
    return true;
  }

  /// 아이템 제거
  bool removeItem(String itemId, {int quantity = 1}) {
    final newSlots = List<InventorySlot>.from(state.slots);

    final slotIndex = newSlots.indexWhere((slot) => slot.item.id == itemId);
    if (slotIndex == -1) return false;

    final slot = newSlots[slotIndex];
    if (slot.quantity < quantity) return false;

    if (slot.quantity == quantity) {
      newSlots.removeAt(slotIndex);
    } else {
      newSlots[slotIndex] = InventorySlot(
        item: slot.item,
        quantity: slot.quantity - quantity,
      );
    }

    state = state.copyWith(slots: newSlots);
    return true;
  }

  /// 아이템 사용 (소모품)
  int? useItem(String itemId) {
    final slot = state.slots.firstWhere(
      (s) => s.item.id == itemId,
      orElse: () => InventorySlot(
        item: const Item(
          id: '',
          name: '',
          description: '',
          type: ItemType.consumable,
        ),
      ),
    );

    if (slot.item.id.isEmpty) return null;
    if (slot.item.type != ItemType.consumable) return null;

    final healAmount = slot.item.healthRestore;
    removeItem(itemId);

    return healAmount;
  }

  /// 무기 장착
  void equipWeapon(Item weapon) {
    if (weapon.type != ItemType.weapon) return;

    // 기존 장착 무기가 있으면 인벤토리로
    if (state.equippedWeapon != null) {
      addItem(state.equippedWeapon!);
    }

    // 인벤토리에서 제거
    removeItem(weapon.id);

    state = state.copyWith(equippedWeapon: weapon);
  }

  /// 방어구 장착
  void equipArmor(Item armor) {
    if (armor.type != ItemType.armor) return;

    // 기존 장착 방어구가 있으면 인벤토리로
    if (state.equippedArmor != null) {
      addItem(state.equippedArmor!);
    }

    // 인벤토리에서 제거
    removeItem(armor.id);

    state = state.copyWith(equippedArmor: armor);
  }

  /// 무기 해제
  void unequipWeapon() {
    if (state.equippedWeapon == null) return;

    addItem(state.equippedWeapon!);
    state = state.copyWith(clearWeapon: true);
  }

  /// 방어구 해제
  void unequipArmor() {
    if (state.equippedArmor == null) return;

    addItem(state.equippedArmor!);
    state = state.copyWith(clearArmor: true);
  }

  /// 골드 추가
  void addGold(int amount) {
    state = state.copyWith(gold: state.gold + amount);
  }

  /// 골드 사용
  bool spendGold(int amount) {
    if (state.gold < amount) return false;
    state = state.copyWith(gold: state.gold - amount);
    return true;
  }

  /// 인벤토리 초기화
  void clear() {
    state = const InventoryState();
  }

  /// 특정 아이템 보유 여부 확인
  bool hasItem(String itemId) {
    return state.slots.any((slot) => slot.item.id == itemId);
  }

  /// 특정 아이템 수량 확인
  int getItemQuantity(String itemId) {
    final slot = state.slots.firstWhere(
      (s) => s.item.id == itemId,
      orElse: () => InventorySlot(
        item: const Item(
          id: '',
          name: '',
          description: '',
          type: ItemType.consumable,
        ),
        quantity: 0,
      ),
    );
    return slot.quantity;
  }

  /// 세이브 데이터에서 로드
  void loadFromSave({
    required Map<String, int> itemIds,
    required int gold,
    String? equippedWeaponId,
    String? equippedArmorId,
  }) {
    // 인벤토리 슬롯 복원
    final slots = <InventorySlot>[];
    for (final entry in itemIds.entries) {
      final item = Items.findById(entry.key);
      if (item != null) {
        slots.add(InventorySlot(item: item, quantity: entry.value));
      }
    }

    // 장비 복원
    final weapon = equippedWeaponId != null
        ? Items.findById(equippedWeaponId)
        : null;
    final armor = equippedArmorId != null
        ? Items.findById(equippedArmorId)
        : null;

    state = InventoryState(
      slots: slots,
      gold: gold,
      equippedWeapon: weapon,
      equippedArmor: armor,
    );
  }
}

/// 인벤토리 Provider
final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier();
});
