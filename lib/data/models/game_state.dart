/// Arcana: The Three Hearts - 게임 상태 모델
library;

/// 챕터 정보
class ChapterInfo {
  ChapterInfo({
    required this.id,
    required this.name,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bossDefeated = false,
  });

  final int id;
  final String name;
  bool isUnlocked;
  bool isCompleted;
  bool bossDefeated;

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      bossDefeated: json['bossDefeated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'bossDefeated': bossDefeated,
      };
}

/// 게임 상태 (저장용)
class GameState {
  GameState({
    this.currentChapter = 1,
    this.currentFloor = 1,
    this.currentRoom = 0,
    this.playTimeSeconds = 0,
    this.totalDeaths = 0,
    this.totalKills = 0,
    Map<String, bool>? flags,
    List<ChapterInfo>? chapters,
    Map<String, bool>? discoveredItems,
    Map<String, bool>? discoveredMonsters,
  })  : flags = flags ?? {},
        chapters = chapters ?? _defaultChapters(),
        discoveredItems = discoveredItems ?? {},
        discoveredMonsters = discoveredMonsters ?? {};

  int currentChapter;
  int currentFloor;
  int currentRoom;
  int playTimeSeconds;
  int totalDeaths;
  int totalKills;
  Map<String, bool> flags; // 스토리 플래그
  List<ChapterInfo> chapters;
  Map<String, bool> discoveredItems; // 도감
  Map<String, bool> discoveredMonsters;

  static List<ChapterInfo> _defaultChapters() => [
        ChapterInfo(id: 1, name: '잊혀진 숲', isUnlocked: true),
        ChapterInfo(id: 2, name: '심연의 동굴'),
        ChapterInfo(id: 3, name: '황혼의 성'),
        ChapterInfo(id: 4, name: '얼어붙은 봉우리'),
        ChapterInfo(id: 5, name: '화염의 심장'),
        ChapterInfo(id: 6, name: '허공의 왕좌'),
      ];

  String get formattedPlayTime {
    final hours = playTimeSeconds ~/ 3600;
    final minutes = (playTimeSeconds % 3600) ~/ 60;
    final seconds = playTimeSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentChapter: json['currentChapter'] as int? ?? 1,
      currentFloor: json['currentFloor'] as int? ?? 1,
      currentRoom: json['currentRoom'] as int? ?? 0,
      playTimeSeconds: json['playTimeSeconds'] as int? ?? 0,
      totalDeaths: json['totalDeaths'] as int? ?? 0,
      totalKills: json['totalKills'] as int? ?? 0,
      flags: (json['flags'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool),
          ) ??
          {},
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => ChapterInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          _defaultChapters(),
      discoveredItems: (json['discoveredItems'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool),
          ) ??
          {},
      discoveredMonsters:
          (json['discoveredMonsters'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, v as bool),
              ) ??
              {},
    );
  }

  Map<String, dynamic> toJson() => {
        'currentChapter': currentChapter,
        'currentFloor': currentFloor,
        'currentRoom': currentRoom,
        'playTimeSeconds': playTimeSeconds,
        'totalDeaths': totalDeaths,
        'totalKills': totalKills,
        'flags': flags,
        'chapters': chapters.map((e) => e.toJson()).toList(),
        'discoveredItems': discoveredItems,
        'discoveredMonsters': discoveredMonsters,
      };

  GameState copyWith({
    int? currentChapter,
    int? currentFloor,
    int? currentRoom,
    int? playTimeSeconds,
    int? totalDeaths,
    int? totalKills,
    Map<String, bool>? flags,
    List<ChapterInfo>? chapters,
    Map<String, bool>? discoveredItems,
    Map<String, bool>? discoveredMonsters,
  }) {
    return GameState(
      currentChapter: currentChapter ?? this.currentChapter,
      currentFloor: currentFloor ?? this.currentFloor,
      currentRoom: currentRoom ?? this.currentRoom,
      playTimeSeconds: playTimeSeconds ?? this.playTimeSeconds,
      totalDeaths: totalDeaths ?? this.totalDeaths,
      totalKills: totalKills ?? this.totalKills,
      flags: flags ?? this.flags,
      chapters: chapters ?? this.chapters,
      discoveredItems: discoveredItems ?? this.discoveredItems,
      discoveredMonsters: discoveredMonsters ?? this.discoveredMonsters,
    );
  }
}

/// 맵 데이터
class MapData {
  const MapData({
    required this.id,
    required this.name,
    required this.chapter,
    required this.floor,
    required this.width,
    required this.height,
    required this.layout,
    this.spawnPoints = const [],
    this.playerSpawn = const [0, 0],
    this.exitPoint = const [0, 0],
  });

  final String id;
  final String name;
  final int chapter;
  final int floor;
  final int width;
  final int height;
  final String layout; // ASCII 맵 레이아웃
  final List<SpawnPoint> spawnPoints;
  final List<int> playerSpawn;
  final List<int> exitPoint;

  factory MapData.fromJson(Map<String, dynamic> json) {
    return MapData(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown',
      chapter: json['chapter'] as int? ?? 1,
      floor: json['floor'] as int? ?? 1,
      width: json['width'] as int? ?? 20,
      height: json['height'] as int? ?? 15,
      layout: json['layout'] as String? ?? '',
      spawnPoints: (json['spawnPoints'] as List<dynamic>?)
              ?.map((e) => SpawnPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      playerSpawn: (json['playerSpawn'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [0, 0],
      exitPoint: (json['exitPoint'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [0, 0],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'chapter': chapter,
        'floor': floor,
        'width': width,
        'height': height,
        'layout': layout,
        'spawnPoints': spawnPoints.map((e) => e.toJson()).toList(),
        'playerSpawn': playerSpawn,
        'exitPoint': exitPoint,
      };
}

/// 스폰 포인트
class SpawnPoint {
  const SpawnPoint({
    required this.x,
    required this.y,
    required this.type,
    this.monsterId,
    this.itemId,
    this.count = 1,
    this.isElite = false,
  });

  final int x;
  final int y;
  final String type; // monster, item, npc, chest, boss
  final String? monsterId;
  final String? itemId;
  final int count;
  final bool isElite;

  factory SpawnPoint.fromJson(Map<String, dynamic> json) {
    return SpawnPoint(
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
      type: json['type'] as String? ?? 'monster',
      monsterId: json['monsterId'] as String?,
      itemId: json['itemId'] as String?,
      count: json['count'] as int? ?? 1,
      isElite: json['isElite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'type': type,
        'monsterId': monsterId,
        'itemId': itemId,
        'count': count,
        'isElite': isElite,
      };
}
