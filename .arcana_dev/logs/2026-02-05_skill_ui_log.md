# Skill System UI Log

**Date:** 2026-02-05
**Phase:** Phase 4 - Integration & Polish (UI 확장)
**Focus:** 심장 게이지/스킬 슬롯 UI 구현

## Summary

심장 게이지 바와 스킬 슬롯 UI 위젯 구현 및 HUD 통합 완료.

## Implemented Features

### 1. HeartGaugeBar (심장 게이지 바)

**파일:** `lib/ui/widgets/heart_gauge_bar.dart`

```dart
class HeartGaugeBar extends StatelessWidget {
  // 심장 게이지 바 (궁극기 게이지)
  // - 그라데이션 채움 효과
  // - 100% 충전 시 READY! 표시
  // - 애니메이션 지원
}

class HeartGaugeMini extends StatelessWidget {
  // 컴팩트 원형 버전
}
```

**특징:**
- 퍼플/핑크 그라데이션 테마
- 100% 충전 시 글로우 효과
- "READY!" 텍스트 오버레이
- 라벨 표시 옵션

### 2. SkillSlotsWidget (스킬 슬롯 UI)

**파일:** `lib/ui/widgets/skill_slots.dart`

```dart
class SkillSlotsWidget extends StatelessWidget {
  // 전체 스킬 슬롯 UI
  // - 마나 바 (세로)
  // - 4개 스킬 슬롯
  // - 쿨다운 오버레이
  // - 마나 코스트 표시
}

class SkillSlotsCompact extends StatelessWidget {
  // 컴팩트 버전 (모바일용)
}
```

**특징:**
- 스킬 타입별 색상 (basic/active/dash/ultimate)
- 카테고리별 아이콘 매핑
- 쿨다운 타이머 표시
- 마나 부족 시 빨간색 오버레이

### 3. HUD 통합

**파일:** `lib/app/arcana_app.dart`

```dart
class _BottomHUD extends StatelessWidget {
  // 좌측: 심장 게이지
  // 우측: 스킬 슬롯 (컴팩트)
}
```

## Files Created/Modified

| File | Action | Description |
|------|--------|-------------|
| `lib/ui/widgets/heart_gauge_bar.dart` | Created | 심장 게이지 바 위젯 |
| `lib/ui/widgets/skill_slots.dart` | Created | 스킬 슬롯 UI 위젯 |
| `lib/app/arcana_app.dart` | Modified | HUD에 하단 UI 추가 |

## Build Verification

```
√ flutter analyze: No issues
√ flutter build windows --release: Success
```

## Technical Notes

### Provider 연동
```dart
final heartGauge = ref.watch(heartGaugeProvider);
final playerSkill = ref.watch(playerSkillProvider);
```

### SkillCategory 아이콘 매핑
- melee → sports_martial_arts
- ranged → gps_fixed
- aoeAttack → blur_circular
- dashAttack → flash_on
- defense → shield
- movement → directions_run
- buffUltimate → auto_fix_high
- attackUltimate → local_fire_department
- heart → favorite

## Remaining Tasks

- [x] SkillManager를 ArcanaGame에 통합
- [x] Player에서 스킬 사용 시 Provider 업데이트
- [ ] 실제 스킬 장착 UI (스킬 선택 화면)

---

## Update 2 - 스킬 시스템 게임 연동

### 추가된 기능

**1. ArcanaGame 스킬 매니저 통합:**
```dart
// 스킬 관리자 초기화
_skillManager = SkillManager(
  onSkillUsed: _handleSkillUsed,
  onManaConsumed: _handleManaConsumed,
  onHeartGaugeConsumed: _handleHeartGaugeConsumed,
  onCooldownStarted: _handleCooldownStarted,
);
_skillManager.initialize(SkillsConfig.defaultConfig);
add(_skillManager);
```

**2. Player 스킬 키 바인딩:**
- 1키: 슬롯 1 (기본 공격)
- 2키: 슬롯 2 (대시)
- 3키: 슬롯 3 (강공격)
- 4키: 슬롯 4 (궁극기)

```dart
if (event is KeyDownEvent) {
  if (event.logicalKey == LogicalKeyboardKey.digit1) {
    onSkillUse?.call(0);
  } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
    onSkillUse?.call(1);
  }
  // ...
}
```

**3. Provider 연동:**
- `heartGaugeProvider`: 심장 게이지 상태 동기화
- `playerSkillProvider`: 마나/쿨다운 상태 동기화

**4. 기본 스킬 설정 (SkillsConfig.defaultConfig):**
- basic_attack: 기본 공격 (데미지 20, 쿨다운 0.4초)
- dash: 대시 (마나 15, 쿨다운 1.5초)
- heavy_attack: 강공격 (데미지 50, 마나 20, 쿨다운 2초)
- ultimate_body: 궁극기 (데미지 150, 심장 게이지 100)

### 빌드 검증
```
√ flutter analyze: No errors (warnings/info only)
√ flutter build windows --release: Success
```

---

## Update 3 - 심장 게이지 충전 연동

### 추가된 기능

**1. Player 데미지 콜백:**
```dart
typedef OnDamageDealt = void Function(double damage);
typedef OnDamageTaken = void Function(double damage);
```

**2. 공격 적중 시 콜백 호출:**
```dart
void _dealDamageToEnemies() {
  // ... 데미지 처리 ...
  if (totalDamageDealt > 0) {
    onDamageDealt?.call(totalDamageDealt);
  }
}
```

**3. 피격 시 콜백 호출:**
```dart
void takeDamage(double damage) {
  // ... 데미지 처리 ...
  onDamageTaken?.call(actualDamage);
}
```

**4. ArcanaGame 콜백 연결:**
```dart
_player = ArcanaPlayer(
  // ...
  onDamageDealt: _handlePlayerDamageDealt,
  onDamageTaken: _handlePlayerDamageTaken,
);

void _handlePlayerDamageDealt(double damage) {
  onDamageDealt(damage); // → SkillManager.onDamageDealt
}

void _handlePlayerDamageTaken(double damage) {
  onDamageTaken(damage); // → SkillManager.onDamageTaken
}
```

### 심장 게이지 충전 로직
- 공격 적중: 데미지 10당 1 충전
- 피격: 데미지 5당 1 충전
- 완벽 회피: 10 충전
- 적 처치: 5 충전

### 빌드 검증
```
√ flutter analyze: No errors
√ flutter build windows --release: Success
```

---

## Update 4 - 버그 수정

### 수정된 버그

**1. 마나 동기화 문제 (Critical)**
- 문제: SkillManager와 PlayerSkillProvider 간 마나 값 불일치
- 수정: `_onManaChanged()` 콜백 구현으로 동기화

**2. Provider 초기화 누락 (Critical)**
- 문제: `startNewGame()`, `continueGame()` 에서 Provider 미초기화
- 수정: `ResourceSystemConfig`으로 양 Provider 초기화

**3. 대화 체인 Race Condition (High)**
- 문제: `Future.delayed` 콜백이 게임 상태 변경 후에도 실행
- 수정: `_safeStartDialogue()` 메서드 추가
```dart
void _safeStartDialogue(String dialogueId, {int delayMs = 1500}) {
  Future.delayed(Duration(milliseconds: delayMs), () {
    if (!_isPaused && !isInDialogue && _player != null) {
      startDialogue(dialogueId);
    }
  });
}
```

### 적용 범위
- 프롤로그 대화
- 보스 조우 대화 (6개 챕터)
- 보스 처치 대화 (6개 챕터)
- 챕터 엔딩 대화 체인
- 승리 화면 트리거

### 빌드 검증
```
√ flutter analyze: No errors
√ flutter build windows --release: Success
```

---

## Update 5 - 버그 수정 및 저장/이어하기 시스템 개선

### 버그 수정

**1. 캐릭터가 바닥 아래로 가라앉는 문제**
- 원인: 플레이어 위치 경계 제한이 없었음
- 수정: `arcana_game.dart`에 `_clampPlayerPosition()` 함수 추가
```dart
void _clampPlayerPosition() {
  // 방 크기 기준 플레이어 위치 제한
  final minX = wallThickness + halfSize;
  final maxX = roomWidth - wallThickness - halfSize;
  _player!.position.x = _player!.position.x.clamp(minX, maxX);
  _player!.position.y = _player!.position.y.clamp(minY, maxY);
}
```

**2. 대화 중 자동 일시정지 버그**
- 원인: 플레이어/적의 `_applyHitStop()`이 대화 중에도 `pauseEngine()` 호출
- 수정: `ArcanaGameInterface` 인터페이스 추가, 모든 히트스톱에서 대화 상태 체크
```dart
// player.dart, base_enemy.dart, dummy_enemy.dart
void _applyHitStop() {
  if (gameRef is ArcanaGameInterface) {
    final game = gameRef as ArcanaGameInterface;
    if (game.isGamePaused) return;  // 대화 중이면 스킵
  }
  // ...
}
```

### 저장/이어하기 시스템 개선

**1. DungeonManager 초기 층 지원**
```dart
DungeonManager({
  // ...
  int initialFloor = 1,
}) : _currentFloor = initialFloor;
```

**2. ArcanaGame 초기 상태 지원**
```dart
ArcanaGame({
  // ...
  this.initialFloor = 1,
  this.initialHearts = 3,
  this.initialHealth = 100,
  this.initialMaxHealth = 100,
});
```

**3. continueGame() 저장 데이터 적용**
```dart
final game = ArcanaGame(
  // ...
  initialFloor: saveData.currentFloor,
  initialHearts: saveData.currentHearts,
  initialHealth: saveData.health,
  initialMaxHealth: saveData.maxHealth,
);
```

### 변경 파일

| 파일 | 변경 내용 |
|------|----------|
| `lib/game/characters/player.dart` | ArcanaGameInterface 인터페이스 추가, _applyHitStop 수정 |
| `lib/game/arcana_game.dart` | 인터페이스 구현, _clampPlayerPosition, 초기 상태 파라미터 |
| `lib/game/enemies/base_enemy.dart` | _applyHitStop 대화 상태 체크 |
| `lib/game/enemies/dummy_enemy.dart` | _applyHitStop 대화 상태 체크 |
| `lib/game/managers/dungeon_manager.dart` | initialFloor 파라미터 |
| `lib/app/game_controller.dart` | continueGame에 저장 데이터 전달 |

### 빌드 검증
```
√ flutter analyze: No errors
√ flutter build windows --release: Success
```

---
*Generated by Claude Code - Project Arcana Development*
