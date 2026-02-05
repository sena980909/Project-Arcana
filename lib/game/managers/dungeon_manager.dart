/// Arcana: The Three Hearts - 던전 관리자
/// 던전 생성, 방 전환, 진행 상태 관리
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../data/model/item.dart';
import '../../data/model/npc.dart';
import '../../data/model/room.dart';
import '../characters/npc_component.dart';
import '../decorations/dropped_item.dart';
import '../enemies/boss_baldur.dart';
import '../enemies/boss_liliana.dart';
import '../enemies/boss_oblivion.dart';
import '../enemies/boss_shadow.dart';
import '../enemies/boss_silencia.dart';
import '../enemies/boss_slime.dart';
import '../enemies/boss_yggdra.dart';
import '../enemies/base_enemy.dart';
import '../enemies/dummy_enemy.dart';
import '../enemies/slime_enemy.dart';
import '../maps/dungeon_generator.dart';
import '../maps/room_component.dart';
import '../decorations/story_object.dart';

/// 던전 관리자
class DungeonManager extends Component with HasGameRef {
  DungeonManager({
    this.onRoomCleared,
    this.onFloorCleared,
    this.onBossDefeated,
    int initialFloor = 1,
  }) : _currentFloor = initialFloor;

  /// 방 클리어 콜백
  final void Function(Room room)? onRoomCleared;

  /// 층 클리어 콜백
  final void Function(int floor)? onFloorCleared;

  /// 보스 처치 콜백
  final VoidCallback? onBossDefeated;

  /// 던전 생성기
  final DungeonGenerator _generator = DungeonGenerator();

  /// 현재 던전
  Dungeon? _currentDungeon;

  /// 현재 방
  Room? _currentRoom;

  /// 현재 방 컴포넌트
  RoomComponent? _currentRoomComponent;

  /// 현재 층
  int _currentFloor;

  /// 현재 방의 남은 적 수
  int _remainingEnemies = 0;

  /// 현재 층 게터
  int get currentFloor => _currentFloor;

  /// 현재 방 게터
  Room? get currentRoom => _currentRoom;

  /// 던전 게터
  Dungeon? get dungeon => _currentDungeon;

  /// 방 클리어 여부
  bool get isRoomCleared => _remainingEnemies <= 0;

  /// 새 던전 생성
  Future<void> generateNewDungeon() async {
    _currentDungeon = _generator.generate(_currentFloor);
    await _loadRoom(_currentDungeon!.startRoom);
  }

  /// 다음 층으로 이동
  Future<void> nextFloor() async {
    _currentFloor++;
    await generateNewDungeon();
    onFloorCleared?.call(_currentFloor - 1);
  }

  /// 방 로드
  Future<void> _loadRoom(Room room) async {
    // 기존 방 제거
    _currentRoomComponent?.removeFromParent();

    // 기존 엔티티들 정리 (NPC, 적, 아이템, 스토리 오브젝트)
    _cleanupRoomEntities();

    _currentRoom = room;

    // 새 방 컴포넌트 생성
    _currentRoomComponent = RoomComponent(
      room: room,
      onEnemyKilled: _onEnemyKilled,
    );

    gameRef.world.add(_currentRoomComponent!);

    // 적 스폰
    _spawnEnemiesForRoom(room);

    // 아이템 스폰 (보물방인 경우)
    if (room.type == RoomType.treasure) {
      _spawnTreasure(room);
    }

    // NPC 스폰 (시작방 또는 상점방)
    _spawnNpcsForRoom(room);

    // 숨겨진 아이템 스폰 (트루 엔딩용)
    _spawnHiddenItemsForRoom(room);

    // 환경 스토리텔링 오브젝트 스폰
    _spawnStoryObjectsForRoom(room);

    // 디버그: 방 로드 완료 상태
    debugPrint('[DungeonManager] Room loaded: type=${room.type}, enemies=$_remainingEnemies, isCleared=$isRoomCleared');
  }

  /// 방 타입에 따른 NPC 스폰
  void _spawnNpcsForRoom(Room room) {
    // 챕터 1 시작 방: 재의 상인
    if (room.type == RoomType.start && _currentFloor == 1) {
      final center = RoomBuilder.getRoomCenter(room);
      // 상인은 방 중앙에서 약간 오른쪽에 배치
      final npcPos = center + Vector2(48, 0);

      gameRef.world.add(NpcComponent(
        npcData: Npcs.ashMerchant,
        position: npcPos,
      ));
    }

    // 챕터 2 시작 방: 재의 상인 재등장 + 눈먼 기사
    if (room.type == RoomType.start && _currentFloor == 2) {
      final center = RoomBuilder.getRoomCenter(room);

      // 재의 상인 (왼쪽)
      gameRef.world.add(NpcComponent(
        npcData: Npcs.ashMerchant,
        position: center + Vector2(-60, 0),
      ));

      // 눈먼 기사 (오른쪽)
      gameRef.world.add(NpcComponent(
        npcData: Npcs.blindKnight,
        position: center + Vector2(60, 0),
      ));
    }

    // 챕터 3 시작 방: 말 없는 수녀
    if (room.type == RoomType.start && _currentFloor == 3) {
      final center = RoomBuilder.getRoomCenter(room);

      // 말 없는 수녀 (중앙 약간 오른쪽)
      gameRef.world.add(NpcComponent(
        npcData: Npcs.voicelessNun,
        position: center + Vector2(48, 0),
      ));
    }

    // 챕터 3 일반 방 (첫 번째): 배교한 사제
    // 보스방 직전 방에 배치하는 것이 이상적이지만, 간단히 normal 방 첫 번째에 배치
    if (room.type == RoomType.normal && _currentFloor == 3) {
      // 사제는 한 번만 등장
      final alreadySpawned = gameRef.world.children.whereType<NpcComponent>()
          .any((npc) => npc.npcData.id == 'apostate_priest');

      if (!alreadySpawned) {
        final center = RoomBuilder.getRoomCenter(room);
        gameRef.world.add(NpcComponent(
          npcData: Npcs.apostatePriest,
          position: center + Vector2(0, -30),
        ));
      }
    }

    // 챕터 4 시작 방: 정원사
    if (room.type == RoomType.start && _currentFloor == 4) {
      final center = RoomBuilder.getRoomCenter(room);

      // 정원사 (중앙 약간 오른쪽)
      gameRef.world.add(NpcComponent(
        npcData: Npcs.gardener,
        position: center + Vector2(48, 0),
      ));
    }

    // 챕터 5 시작 방: 미래의 자신 (???)
    // 과거의 자신은 거울의 방에서 등장 (특수 이벤트로 처리)
    if (room.type == RoomType.start && _currentFloor == 5) {
      final center = RoomBuilder.getRoomCenter(room);

      // 미래의 자신 (심연 입구에서 인도)
      gameRef.world.add(NpcComponent(
        npcData: Npcs.futureSelf,
        position: center + Vector2(48, 0),
      ));
    }

    // 챕터 6 시작 방: 잊혀진 현자
    if (room.type == RoomType.start && _currentFloor == 6) {
      final center = RoomBuilder.getRoomCenter(room);

      // 잊혀진 현자 (망각의 옥좌 입구에서 조언)
      gameRef.world.add(NpcComponent(
        npcData: Npcs.forgottenSage,
        position: center + Vector2(48, 0),
      ));
    }

    // 챕터 6 보스방 근처: 봉인된 리리아나
    // (보스 처치 후 특수 이벤트로 해방 - 일단 보스방 스폰은 arcana_game에서 처리)

    // 상점방: 일반 상인
    if (room.type == RoomType.shop) {
      final center = RoomBuilder.getRoomCenter(room);
      gameRef.world.add(NpcComponent(
        npcData: Npcs.merchant,
        position: center,
      ));
    }
  }

  /// 숨겨진 아이템 스폰 (트루 엔딩 필수 아이템)
  /// GDD 기준:
  /// - 약속의 반지: Chapter 4 맵 (49, 1) - 숨겨진 정원 구석
  /// - 첫 번째 기억의 결정: Chapter 5 맵 (5, 5) - 기억의 제단
  void _spawnHiddenItemsForRoom(Room room) {
    // 챕터 4: 약속의 반지 (보스방 직전 또는 마지막 일반방에 배치)
    // 정원 구석 = 방 오른쪽 상단 끝
    if (_currentFloor == 4 && room.type == RoomType.normal) {
      // 이미 스폰되었는지 확인
      final alreadySpawned = gameRef.world.children.whereType<DroppedItem>()
          .any((item) => item.item.id == 'promise_ring');

      if (!alreadySpawned) {
        // GDD: (49, 1) 타일 좌표 → 픽셀 좌표로 변환
        // 방의 오른쪽 상단 구석에 배치 (발견하기 어렵게)
        final hiddenPos = Vector2(
          room.width * 32 - 48, // 오른쪽 벽에서 48px 안쪽
          48, // 위쪽 벽에서 48px 아래
        );

        gameRef.world.add(DroppedItem(
          item: Items.promiseRing,
          position: hiddenPos,
        ));

        debugPrint('[Hidden Item] 약속의 반지 스폰 @ $hiddenPos (Ch4)');
      }
    }

    // 챕터 5: 첫 번째 기억의 결정 (시작방 또는 특수 방에 배치)
    // 기억의 제단 = 방 왼쪽 상단
    if (_currentFloor == 5 && room.type == RoomType.start) {
      // 이미 스폰되었는지 확인
      final alreadySpawned = gameRef.world.children.whereType<DroppedItem>()
          .any((item) => item.item.id == 'first_memory_crystal');

      if (!alreadySpawned) {
        // GDD: (5, 5) 타일 좌표 → 픽셀 좌표로 변환
        // 방의 왼쪽 상단 구석에 배치 (제단 위치)
        final hiddenPos = Vector2(
          5 * 32, // 5번째 타일 (x)
          5 * 32, // 5번째 타일 (y)
        );

        gameRef.world.add(DroppedItem(
          item: Items.firstMemoryCrystal,
          position: hiddenPos,
        ));

        debugPrint('[Hidden Item] 기억의 결정 스폰 @ $hiddenPos (Ch5)');
      }
    }
  }

  /// 환경 스토리텔링 오브젝트 스폰
  /// 각 챕터별 벽화, 비문, 제단 등 배치
  void _spawnStoryObjectsForRoom(Room room) {
    // 일반방 또는 보물방에만 스폰 (시작방, 보스방 제외)
    if (room.type != RoomType.normal && room.type != RoomType.treasure) {
      return;
    }

    final center = RoomBuilder.getRoomCenter(room);

    // 챕터별 스토리 오브젝트 배치 (각 챕터당 1개씩, 첫 번째 일반방에만)
    final alreadySpawned = gameRef.world.children.whereType<StoryObject>().isNotEmpty;
    if (alreadySpawned) return;

    switch (_currentFloor) {
      case 1:
        // 챕터 1: 잊혀진 숲 - 벽화 (약속의 장면)
        gameRef.world.add(StoryObject(
          position: center + Vector2(-80, -40),
          type: StoryObjectType.mural,
          dialogueId: 'env_ch1_mural',
        ));
        // 비문 (정령의 경고)
        gameRef.world.add(StoryObject(
          position: center + Vector2(80, -40),
          type: StoryObjectType.inscription,
          dialogueId: 'env_ch1_inscription',
        ));

      case 2:
        // 챕터 2: 무너진 성채 - 초상화
        gameRef.world.add(StoryObject(
          position: center + Vector2(-80, -40),
          type: StoryObjectType.mural,
          dialogueId: 'env_ch2_mural',
        ));
        // 금속판 (연대기)
        gameRef.world.add(StoryObject(
          position: center + Vector2(80, -40),
          type: StoryObjectType.inscription,
          dialogueId: 'env_ch2_inscription',
        ));

      case 3:
        // 챕터 3: 침묵의 성당 - 스테인드글라스
        gameRef.world.add(StoryObject(
          position: center + Vector2(-80, -40),
          type: StoryObjectType.mural,
          dialogueId: 'env_ch3_mural',
        ));
        // 고해실 기록
        gameRef.world.add(StoryObject(
          position: center + Vector2(80, -40),
          type: StoryObjectType.inscription,
          dialogueId: 'env_ch3_inscription',
        ));

      case 4:
        // 챕터 4: 피의 정원 - 석상
        gameRef.world.add(StoryObject(
          position: center + Vector2(-80, -40),
          type: StoryObjectType.statue,
          dialogueId: 'env_ch4_statue',
        ));
        // 일기장
        gameRef.world.add(StoryObject(
          position: center + Vector2(80, -40),
          type: StoryObjectType.inscription,
          dialogueId: 'env_ch4_inscription',
        ));

      case 5:
        // 챕터 5: 기억의 심연 - 깨진 거울
        gameRef.world.add(StoryObject(
          position: center + Vector2(-80, -40),
          type: StoryObjectType.mural, // 거울도 mural 타입 사용
          dialogueId: 'env_ch5_mirror',
        ));
        // 기억 조각
        gameRef.world.add(StoryObject(
          position: center + Vector2(80, -40),
          type: StoryObjectType.inscription,
          dialogueId: 'env_ch5_inscription',
        ));

      case 6:
        // 챕터 6: 망각의 옥좌 - 기념비
        gameRef.world.add(StoryObject(
          position: center + Vector2(-80, -40),
          type: StoryObjectType.memorial,
          dialogueId: 'env_ch6_memorial',
        ));
        // 옥좌 비문
        gameRef.world.add(StoryObject(
          position: center + Vector2(80, -40),
          type: StoryObjectType.inscription,
          dialogueId: 'env_ch6_inscription',
        ));
    }

    debugPrint('[Story Object] 환경 오브젝트 스폰 (Ch$_currentFloor)');
  }

  /// 방 전환 시 기존 엔티티 정리
  void _cleanupRoomEntities() {
    // NPC 제거
    final npcs = gameRef.world.children.whereType<NpcComponent>().toList();
    for (final npc in npcs) {
      npc.removeFromParent();
    }

    // 드롭 아이템 제거
    final items = gameRef.world.children.whereType<DroppedItem>().toList();
    for (final item in items) {
      item.removeFromParent();
    }

    // 스토리 오브젝트 제거
    final storyObjects = gameRef.world.children.whereType<StoryObject>().toList();
    for (final obj in storyObjects) {
      obj.removeFromParent();
    }

    // 적 제거 (BaseEnemy 및 하위 클래스)
    final enemies = gameRef.world.children.whereType<BaseEnemy>().toList();
    for (final enemy in enemies) {
      enemy.removeFromParent();
    }

    // DummyEnemy 제거 (BaseEnemy 상속 안함)
    final dummies = gameRef.world.children.whereType<DummyEnemy>().toList();
    for (final dummy in dummies) {
      dummy.removeFromParent();
    }

    // 보스 제거
    final bosses = gameRef.world.children.where((c) =>
      c.runtimeType.toString().contains('Boss')).toList();
    for (final boss in bosses) {
      boss.removeFromParent();
    }

    debugPrint('[DungeonManager] Cleaned up ${npcs.length} NPCs, ${items.length} items, ${storyObjects.length} story objects, ${enemies.length + dummies.length} enemies');
  }

  /// 방 타입에 따른 적 스폰
  void _spawnEnemiesForRoom(Room room) {
    _remainingEnemies = 0;

    if (room.type == RoomType.start ||
        room.type == RoomType.treasure ||
        room.type == RoomType.shop ||
        room.type == RoomType.rest) {
      // 적이 없는 방은 즉시 클리어 처리
      room.isCleared = true;
      debugPrint('[DungeonManager] No enemies for ${room.type} - auto cleared');
      return; // 적 없음
    }

    // 보스방인 경우
    if (room.type == RoomType.boss) {
      final bossPos = RoomBuilder.getRoomCenter(room);

      // 층별 보스 선택
      switch (_currentFloor) {
        case 1:
          // 챕터 1: 이그드라 (잊혀진 숲)
          final yggdra = BossYggdra(position: bossPos);
          gameRef.world.add(yggdra);
        case 2:
          // 챕터 2: 발두르 (무너진 성채)
          final baldur = BossBaldur(position: bossPos);
          gameRef.world.add(baldur);
        case 3:
          // 챕터 3: 실렌시아 (침묵의 성당)
          final silencia = BossSilencia(position: bossPos);
          gameRef.world.add(silencia);
        case 4:
          // 챕터 4: 리리아나 (피의 정원)
          final liliana = BossLiliana(position: bossPos);
          gameRef.world.add(liliana);
        case 5:
          // 챕터 5: 그림자 자아 (기억의 심연)
          final shadow = BossShadow(position: bossPos);
          gameRef.world.add(shadow);
        case 6:
          // 챕터 6: 망각의 화신 (망각의 옥좌)
          final oblivion = BossOblivion(position: bossPos);
          gameRef.world.add(oblivion);
        default:
          // 이후 층: 일반 보스
          final boss = BossSlime(position: bossPos);
          gameRef.world.add(boss);
      }

      _remainingEnemies = 1;
      return;
    }

    final spawnPositions = RoomBuilder.getEnemySpawnPositions(
      room,
      _getEnemyCountForRoom(room),
    );

    for (final pos in spawnPositions) {
      final enemy = _createEnemyForFloor(pos);
      gameRef.world.add(enemy);
      _remainingEnemies++;
    }
  }

  /// 방 타입별 적 수
  int _getEnemyCountForRoom(Room room) {
    switch (room.type) {
      case RoomType.normal:
        return 2 + _currentFloor ~/ 2;
      case RoomType.combat:
        return 3 + _currentFloor ~/ 2;
      case RoomType.boss:
        return 1; // 보스 1마리
      default:
        return 0;
    }
  }

  /// 층에 맞는 적 생성
  Component _createEnemyForFloor(Vector2 position) {
    // 층이 높을수록 강한 적 등장 확률 증가
    if (_currentFloor >= 3) {
      return GoblinEnemy(position: position);
    }
    return SlimeEnemy(position: position);
  }

  /// 보물방 아이템 스폰
  void _spawnTreasure(Room room) {
    final pos = RoomBuilder.getItemSpawnPosition(room);

    // 챕터별 스토리 아이템 + 일반 아이템
    Item storyItem;
    Item? bonusItem;

    switch (_currentFloor) {
      case 1:
        // 챕터 1: 부서진 나뭇잎 펜던트
        storyItem = Items.brokenLeafPendant;
        bonusItem = Items.healthPotion;
      case 2:
        // 챕터 2: 깨진 왕관 조각
        storyItem = Items.brokenCrownShard;
        bonusItem = Items.leatherArmor;
      case 3:
        // 챕터 3: 첫 번째 기억 조각
        storyItem = Items.memoryFragment1;
        bonusItem = Items.ironSword;
      case 4:
        // 챕터 4: 리리아나의 반지 (숨겨진 약속의 반지와 별개)
        storyItem = Items.lilianaRing;
        bonusItem = Items.largeHealthPotion;
      case 5:
        // 챕터 5: 그림자의 파편
        storyItem = Items.shadowFragment;
        bonusItem = Items.flameSword;
      case 6:
        // 챕터 6: 망각의 눈물은 보스 드롭으로만
        storyItem = Items.largeHealthPotion;
        bonusItem = Items.chainMail;
      default:
        storyItem = Items.healthPotion;
    }

    // 스토리 아이템 스폰
    gameRef.world.add(DroppedItem(
      item: storyItem,
      position: pos,
    ));

    // 보너스 아이템 스폰 (약간 옆에)
    if (bonusItem != null) {
      gameRef.world.add(DroppedItem(
        item: bonusItem,
        position: pos + Vector2(40, 0),
      ));
    }
  }

  /// 적 처치 콜백 (내부용)
  void _onEnemyKilled() {
    onEnemyKilled();
  }

  /// 적 처치 알림 (외부 호출용 - BaseEnemy에서 호출)
  void onEnemyKilled() {
    _remainingEnemies--;
    debugPrint('[DungeonManager] Enemy killed. Remaining: $_remainingEnemies');

    if (_remainingEnemies <= 0) {
      _currentRoom?.isCleared = true;
      debugPrint('[DungeonManager] Room cleared!');
      onRoomCleared?.call(_currentRoom!);

      // 보스방이면 보스 처치 콜백
      if (_currentRoom?.type == RoomType.boss) {
        onBossDefeated?.call();
      }
    }
  }

  /// 문을 통해 다른 방으로 이동
  Future<void> moveToRoom(DoorDirection direction) async {
    if (_currentRoom == null || _currentDungeon == null) return;

    final nextRoomId = _currentRoom!.doors[direction];
    if (nextRoomId == null) return;

    final nextRoom = _currentDungeon!.getRoomById(nextRoomId);
    if (nextRoom == null) return;

    // 현재 방이 클리어되지 않았으면 이동 불가
    if (!isRoomCleared && _currentRoom!.type != RoomType.start) {
      return;
    }

    await _loadRoom(nextRoom);
  }

  /// 플레이어 시작 위치
  Vector2 getPlayerStartPosition() {
    if (_currentRoom == null) {
      return Vector2(160, 160);
    }
    return RoomBuilder.getRoomCenter(_currentRoom!);
  }

  /// 던전 리셋
  void reset() {
    _currentFloor = 1;
    _currentDungeon = null;
    _currentRoom = null;
    _currentRoomComponent?.removeFromParent();
    _currentRoomComponent = null;
    _remainingEnemies = 0;
  }
}
