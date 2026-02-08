/// Arcana: The Three Hearts - 게임 로거 (웹)
library;

import 'package:flutter/foundation.dart';

/// 게임 로거 - 콘솔 전용 (웹)
class GameLogger {
  GameLogger._();
  static final GameLogger instance = GameLogger._();

  /// 로거 초기화
  Future<void> init() async {
    debugPrint('[GameLogger] 웹 모드 - 콘솔 로깅만 사용');
  }

  /// 로그 기록
  void log(String category, String message) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.split('.').first;
    final logLine = '[$timestamp][$category] $message';
    debugPrint(logLine);
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

  /// 종료
  Future<void> close() async {
    log('SYSTEM', '게임 종료');
  }

  /// 로그 파일 경로 (웹에서는 없음)
  String? get logFilePath => null;
}
