/// Arcana: The Three Hearts - 게임 상수
/// PRD 3.1 및 4.1에 따른 물리/전투 상수 정의
library;

/// 게임 물리 상수
class PhysicsConstants {
  PhysicsConstants._();

  /// 기본 이동 속도 (픽셀/초)
  static const double baseSpeed = 100.0;

  /// 대시 속도 배율
  static const double dashMultiplier = 2.5;

  /// 중력 가속도
  static const double gravity = 9.8;

  /// 타일 크기 (PRD 6.1: 16x16 또는 32x32)
  static const double tileSize = 16.0;

  /// 게임 줌 레벨 (PRD 6.1: 2.0x ~ 3.0x)
  static const double zoomLevel = 2.5;
}

/// 전투 상수 (PRD 4.1 전투 공식)
class CombatConstants {
  CombatConstants._();

  /// 최소 데미지 (PRD: 1은 무조건 들어감)
  static const int minimumDamage = 1;

  /// 크리티컬 배율 (PRD: 기본 1.5배)
  static const double criticalMultiplier = 1.5;

  /// 방어력 감소 계수 (PRD: DEF * 0.5)
  static const double defenseMultiplier = 0.5;

  /// 데미지 랜덤 범위 (PRD: 0.9 ~ 1.1)
  static const double damageRandomMin = 0.9;
  static const double damageRandomMax = 1.1;

  /// 속성 상성 배율 (PRD: 1.5배)
  static const double elementalAdvantageMultiplier = 1.5;
}

/// 하트 시스템 상수 (PRD 4.2)
class HeartConstants {
  HeartConstants._();

  /// 최대 심장 개수
  static const int maxHearts = 3;

  /// Heart 1 (Body) 파괴 시 페널티
  static const double bodyLostSpeedPenalty = 0.10; // 10% 감소
  static const double bodyLostDefensePenalty = 0.20; // 20% 감소

  /// Heart 2 (Mind) 파괴 시 페널티
  static const double mindLostBrightnessPenalty = 0.30; // 30% 어두워짐
  static const double mindLostCooldownPenalty = 0.25; // 25% 쿨타임 증가
}

/// UI 상수
class UIConstants {
  UIConstants._();

  /// 화면 흔들림 지속 시간 (초)
  static const double screenShakeDuration = 0.1;

  /// 히트스톱 지속 시간 (초)
  static const double hitStopDuration = 0.05;

  /// 데미지 숫자 표시 시간 (초)
  static const double damageNumberDuration = 0.8;
}
