/// Arcana: The Three Hearts - 스폰 시스템
library;

import 'dart:math';

import 'package:flame/components.dart';

import '../../data/models/game_state.dart';
import '../../data/models/monster_data.dart';
import '../../data/repositories/config_repository.dart';
import '../enemy.dart';
import '../player.dart';
import '../components/npc_component.dart';
import 'map_loader.dart';

/// 스폰 시스템
/// 맵의 스폰 포인트에 따라 적, 아이템, NPC를 생성합니다.
class SpawnSystem {
  SpawnSystem({
    required this.world,
    required this.player,
    required this.assetPath,
    this.onEnemyDeath,
    this.onEnemyAttackHit,
  });

  final World world;
  final Player player;
  final String assetPath;
  final void Function(Enemy)? onEnemyDeath;
  final void Function(double)? onEnemyAttackHit;

  final List<Enemy> _enemies = [];
  final List<NpcComponent> _npcs = [];
  final Random _random = Random();

  /// 스폰된 적 목록
  List<Enemy> get enemies => List.unmodifiable(_enemies);

  /// NPC 목록
  List<NpcComponent> get npcs => List.unmodifiable(_npcs);

  /// 맵의 스폰 포인트에서 적 생성
  void spawnFromMap(LoadedMap loadedMap, {int chapter = 1}) {
    // 기존 적 제거
    clearEnemies();

    for (final spawnPoint in loadedMap.spawnPoints) {
      switch (spawnPoint.type) {
        case 'monster':
          _spawnMonster(spawnPoint, chapter);
        case 'boss':
          _spawnBoss(spawnPoint, chapter);
        case 'chest':
          // TODO: 상자 생성
          break;
        case 'npc':
          _spawnNpc(spawnPoint);
      }
    }
  }

  /// 몬스터 스폰
  void _spawnMonster(SpawnPoint spawnPoint, int chapter) {
    final monsterId = spawnPoint.monsterId ?? _getRandomMonsterId(chapter);
    final monsterData = ConfigRepository.instance.getMonster(monsterId);

    for (int i = 0; i < spawnPoint.count; i++) {
      // 약간의 위치 변동
      final offsetX = (i > 0) ? (_random.nextDouble() - 0.5) * 50 : 0.0;
      final offsetY = (i > 0) ? (_random.nextDouble() - 0.5) * 50 : 0.0;

      final position = Vector2(
        spawnPoint.x * MapLoader.tileSize + MapLoader.tileSize / 2 + offsetX,
        spawnPoint.y * MapLoader.tileSize + MapLoader.tileSize / 2 + offsetY,
      );

      // 엘리트 몬스터 처리
      MonsterData? finalData = monsterData;
      if (spawnPoint.isElite && monsterData != null) {
        finalData = _createEliteMonster(monsterData);
      }

      // 챕터별 난이도 스케일링
      if (finalData != null && chapter > 1) {
        finalData = _scaleMonster(finalData, chapter);
      }

      final enemy = Enemy(
        position: position,
        assetPath: assetPath,
        enemyType: monsterId,
        player: player,
        monsterData: finalData,
        onDeath: (e) {
          _enemies.remove(e);
          onEnemyDeath?.call(e);
        },
        onAttackHit: onEnemyAttackHit,
      );

      _enemies.add(enemy);
      world.add(enemy);
    }
  }

  /// 보스 스폰
  void _spawnBoss(SpawnPoint spawnPoint, int chapter) {
    final monsterId = spawnPoint.monsterId ?? 'boss_forest_guardian';
    final monsterData = ConfigRepository.instance.getMonster(monsterId);

    final position = Vector2(
      spawnPoint.x * MapLoader.tileSize + MapLoader.tileSize / 2,
      spawnPoint.y * MapLoader.tileSize + MapLoader.tileSize / 2,
    );

    // 챕터별 보스 스케일링
    MonsterData? finalData = monsterData;
    if (finalData != null && chapter > 1) {
      finalData = _scaleBoss(finalData, chapter);
    }

    final enemy = Enemy(
      position: position,
      assetPath: assetPath,
      enemyType: monsterId,
      player: player,
      monsterData: finalData,
      onDeath: (e) {
        _enemies.remove(e);
        onEnemyDeath?.call(e);
      },
      onAttackHit: onEnemyAttackHit,
    );

    _enemies.add(enemy);
    world.add(enemy);
  }

  /// NPC 스폰
  void _spawnNpc(SpawnPoint spawnPoint) {
    final position = Vector2(
      spawnPoint.x * MapLoader.tileSize + MapLoader.tileSize / 2,
      spawnPoint.y * MapLoader.tileSize + MapLoader.tileSize / 2,
    );

    final npcType = spawnPoint.monsterId ?? 'merchant';

    final npc = NpcComponent(
      position: position,
      assetPath: assetPath,
      player: player,
      npcType: npcType,
    );

    _npcs.add(npc);
    world.add(npc);
  }

  /// 랜덤 몬스터 ID 선택
  String _getRandomMonsterId(int chapter) {
    final monsters = _getMonstersForChapter(chapter);
    if (monsters.isEmpty) return 'goblin';
    return monsters[_random.nextInt(monsters.length)];
  }

  /// 챕터별 등장 몬스터
  List<String> _getMonstersForChapter(int chapter) {
    switch (chapter) {
      case 1:
        return ['goblin', 'tiny_zombie', 'skelet'];
      case 2:
        return ['skelet', 'imp', 'chort'];
      case 3:
        return ['orc_warrior', 'chort', 'imp'];
      case 4:
        return ['chort', 'orc_warrior', 'skelet'];
      case 5:
        return ['chort', 'orc_warrior', 'imp'];
      case 6:
        return ['chort', 'orc_warrior', 'imp', 'skelet'];
      default:
        return ['goblin', 'skelet'];
    }
  }

  /// 엘리트 몬스터 생성
  MonsterData _createEliteMonster(MonsterData base) {
    return MonsterData(
      id: '${base.id}_elite',
      name: '엘리트 ${base.name}',
      hp: base.hp * 2,
      damage: base.damage * 1.5,
      speed: base.speed * 1.1,
      detectionRange: base.detectionRange * 1.2,
      attackRange: base.attackRange * 1.1,
      spritePrefix: base.spritePrefix,
      aiType: base.aiType,
      attackPatterns: base.attackPatterns,
      goldReward: base.goldReward * 3,
      expReward: base.expReward * 3,
      isBoss: false,
    );
  }

  /// 챕터별 몬스터 스케일링
  MonsterData _scaleMonster(MonsterData base, int chapter) {
    final scale = 1.0 + (chapter - 1) * 0.4;
    return MonsterData(
      id: base.id,
      name: base.name,
      hp: base.hp * scale,
      damage: base.damage * scale,
      speed: base.speed,
      detectionRange: base.detectionRange,
      attackRange: base.attackRange,
      spritePrefix: base.spritePrefix,
      aiType: base.aiType,
      attackPatterns: base.attackPatterns.map((p) => AttackPattern(
        name: p.name,
        damage: p.damage * scale,
        range: p.range,
        telegraphDuration: p.telegraphDuration,
        attackDuration: p.attackDuration,
        cooldown: p.cooldown,
        shape: p.shape,
        width: p.width,
        height: p.height,
        angle: p.angle,
      )).toList(),
      goldReward: (base.goldReward * scale).toInt(),
      expReward: (base.expReward * scale).toInt(),
      isBoss: base.isBoss,
    );
  }

  /// 챕터별 보스 스케일링
  MonsterData _scaleBoss(MonsterData base, int chapter) {
    final scale = 1.0 + (chapter - 1) * 0.5;
    return MonsterData(
      id: base.id,
      name: base.name,
      hp: base.hp * scale,
      damage: base.damage * scale,
      speed: base.speed,
      detectionRange: base.detectionRange,
      attackRange: base.attackRange,
      spritePrefix: base.spritePrefix,
      aiType: base.aiType,
      attackPatterns: base.attackPatterns.map((p) => AttackPattern(
        name: p.name,
        damage: p.damage * scale,
        range: p.range,
        telegraphDuration: max(0.3, p.telegraphDuration - (chapter - 1) * 0.1),
        attackDuration: p.attackDuration,
        cooldown: max(1.0, p.cooldown - (chapter - 1) * 0.2),
        shape: p.shape,
        width: p.width,
        height: p.height,
        angle: p.angle,
      )).toList(),
      goldReward: (base.goldReward * scale).toInt(),
      expReward: (base.expReward * scale).toInt(),
      isBoss: base.isBoss,
    );
  }

  /// 특정 위치에 적 스폰
  Enemy spawnEnemyAt(Vector2 position, String enemyType) {
    final monsterData = ConfigRepository.instance.getMonster(enemyType);

    final enemy = Enemy(
      position: position,
      assetPath: assetPath,
      enemyType: enemyType,
      player: player,
      monsterData: monsterData,
      onDeath: (e) {
        _enemies.remove(e);
        onEnemyDeath?.call(e);
      },
      onAttackHit: onEnemyAttackHit,
    );

    _enemies.add(enemy);
    world.add(enemy);

    return enemy;
  }

  /// 모든 적 제거
  void clearEnemies() {
    for (final enemy in _enemies) {
      enemy.removeFromParent();
    }
    _enemies.clear();

    for (final npc in _npcs) {
      npc.removeFromParent();
    }
    _npcs.clear();
  }

  /// 모든 적 처치
  void killAllEnemies() {
    for (final enemy in [..._enemies]) {
      enemy.takeDamage(9999);
    }
  }

  /// 살아있는 적 수
  int get aliveEnemyCount => _enemies.where((e) => !e.isDead).length;

  /// 보스 존재 여부
  bool get hasBoss => _enemies.any((e) => e.monsterData?.isBoss == true && !e.isDead);
}
