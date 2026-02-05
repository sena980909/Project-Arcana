# Plan: 심장 게이지/스킬 시스템 완성

## 목표
GDD 7장에 따라 심장 게이지 충전/사용 시스템과 스킬 실행 시스템 구현

## 현재 상태
- `lib/data/models/skill_data.dart`: 스킬 데이터 모델 완료
  - SkillData, SkillType, SkillCategory, SkillHitbox, SkillFeedback
  - ResourceSystemConfig (마나/심장 게이지 설정)
  - SkillsConfig (전체 스킬 설정)

## 구현 항목

### 1. 심장 게이지 Provider (lib/providers/heart_gauge_provider.dart)
```dart
class HeartGaugeState {
  double current;      // 0-100
  double max;          // 100
}

- onDamageDealt(int damage) → 데미지/10 충전
- onDamageTaken(int damage) → 데미지/5 충전
- onPerfectDodge() → 10 충전
- onKill() → 5 충전
- useForUltimate(double cost) → 사용
```

### 2. 플레이어 스킬 상태 (lib/providers/player_skill_provider.dart)
```dart
class PlayerSkillState {
  double currentMana;
  double maxMana;
  List<String> equippedSkills;  // 4슬롯
  Map<String, double> skillCooldowns;
}
```

### 3. 스킬 매니저 (lib/game/managers/skill_manager.dart)
- 스킬 사용 조건 체크 (쿨다운, 마나/게이지)
- 스킬 효과 발동
- 쿨다운 관리

### 4. UI 컴포넌트
- 심장 게이지 바 (HUD)
- 스킬 슬롯 UI (쿨다운 표시)

## 체크리스트
- [x] heart_gauge_provider.dart 생성
- [x] player_skill_provider.dart 생성
- [x] skill_manager.dart 생성
- [x] player.dart에 스킬 키 바인딩 추가 (1,2,3,4 키)
- [x] ArcanaGame에 SkillManager 통합
- [x] GameController 스킬 Provider 연동
- [x] 스킬 슬롯 UI 생성 (skill_slots.dart)
- [x] 심장 게이지 UI 생성 (heart_gauge_bar.dart)
- [x] HUD에 통합 (arcana_app.dart)
- [x] 기본 스킬 설정 (SkillsConfig.defaultConfig)

## 완료 날짜
2026-02-05 (전체 완료)
