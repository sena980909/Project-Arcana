/// Arcana: The Three Hearts - 게임 로거 (네이티브)
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 게임 로거 - 파일 + 콘솔 로깅 (네이티브)
class GameLogger {
  GameLogger._();
  static final GameLogger instance = GameLogger._();

  File? _logFile;
  final List<String> _buffer = [];
  bool _initialized = false;

  /// 로거 초기화
  Future<void> init() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/ArcanaLogs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      _logFile = File('${logDir.path}/game_log_$timestamp.txt');
      await _logFile!.writeAsString('=== Arcana: The Three Hearts - 게임 로그 ===\n');
      await _logFile!.writeAsString('시작 시간: ${DateTime.now()}\n\n', mode: FileMode.append);

      _initialized = true;
      debugPrint('[GameLogger] 로그 파일 생성: ${_logFile!.path}');
    } catch (e) {
      debugPrint('[GameLogger] 초기화 실패: $e');
    }
  }

  /// 로그 기록
  void log(String category, String message) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.split('.').first;
    final logLine = '[$timestamp][$category] $message';

    debugPrint(logLine);

    _buffer.add(logLine);

    if (_buffer.length >= 10) {
      _flush();
    }
  }

  /// 적 스폰 로그
  void logEnemySpawn(String type, double x, double y) {
    log('ENEMY', '스폰: $type @ ($x, $y)');
  }

  /// 적 사망 로그
  void logEnemyDeath(String type, double x, double y, {double? remainingHp}) {
    log('ENEMY', '사망: $type @ ($x, $y) - 남은HP: ${remainingHp ?? 0}');
  }

  /// 적 피격 로그
  void logEnemyHit(String type, double damage, double remainingHp) {
    log('ENEMY', '피격: $type - 데미지: $damage, 남은HP: $remainingHp');
  }

  /// 플레이어 공격 로그
  void logPlayerAttack(int comboCount, double damage, int hitCount) {
    log('PLAYER', '공격: 콤보${comboCount + 1} - 데미지: $damage, 적중: $hitCount명');
  }

  /// 플레이어 대시 로그
  void logPlayerDash(double x, double y) {
    log('PLAYER', '대시 @ ($x, $y)');
  }

  /// 플레이어 피격 로그
  void logPlayerHit(double damage, double remainingHp) {
    log('PLAYER', '피격: 데미지 $damage, 남은HP: $remainingHp');
  }

  /// 아이템 구매 로그
  void logItemBuy(String itemId, int cost, int remainingGold) {
    log('SHOP', '구매: $itemId - 비용: $cost, 남은골드: $remainingGold');
  }

  /// 골드 획득 로그
  void logGoldGain(int amount, int total) {
    log('REWARD', '골드 획득: +$amount (총: $total)');
  }

  /// 버퍼를 파일에 쓰기
  Future<void> _flush() async {
    if (_logFile == null || _buffer.isEmpty) return;

    try {
      final content = _buffer.join('\n') + '\n';
      await _logFile!.writeAsString(content, mode: FileMode.append);
      _buffer.clear();
    } catch (e) {
      debugPrint('[GameLogger] 파일 쓰기 실패: $e');
    }
  }

  /// 종료 시 남은 버퍼 저장
  Future<void> close() async {
    log('SYSTEM', '게임 종료');
    await _flush();
  }

  /// 로그 파일 경로 반환
  String? get logFilePath => _logFile?.path;
}
