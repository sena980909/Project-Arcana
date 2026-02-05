# Bug Report: Code Review Analysis

**분석일:** 2026-02-05
**분석자:** Lead QA Engineer (AI)
**검토 범위:** 테스트 케이스 70개 기준 코드 분석

---

## Executive Summary

코드 분석 결과 **5개의 잠재적 버그**와 **2개의 확인된 버그**를 발견했습니다.

| Severity | Count | Description |
|----------|-------|-------------|
| CRITICAL | 1 | 데이터 손실 가능성 |
| HIGH | 1 | 게임플레이 영향 |
| MEDIUM | 2 | UX 저하 |
| LOW | 3 | 시각적/마이너 이슈 |

---

## CRITICAL BUGS

### BUG-001: 저장 데이터 손상 가능성
**TC-016 관련**

**파일:** `lib/data/services/save_manager.dart:133-138`

**현재 코드:**
```dart
Future<bool> saveGame(SaveData data) async {
  try {
    final jsonString = jsonEncode(data.toJson());
    await _prefs?.setString(_saveKey, jsonString);  // ← 원자적 쓰기 아님
    debugPrint('Game saved successfully');
    return true;
  } catch (e) {
    debugPrint('Failed to save game: $e');
    return false;
  }
}
```

**문제:**
- `SharedPreferences.setString()`은 원자적(atomic) 쓰기를 보장하지 않음
- 게임 저장 중 앱 크래시/강제 종료 시 데이터가 부분적으로만 기록될 수 있음
- 손상된 JSON은 로드 시 파싱 실패를 유발함

**재현 단계:**
1. 보스전 진행 중 저장 버튼 클릭
2. 저장 진행 중 Alt+F4로 강제 종료
3. 게임 재시작 후 이어하기 시도
4. 잠재적으로 세이브 데이터 손상

**권장 수정:**
```dart
Future<bool> saveGame(SaveData data) async {
  try {
    final jsonString = jsonEncode(data.toJson());

    // 1. 임시 키에 먼저 저장
    await _prefs?.setString('${_saveKey}_temp', jsonString);

    // 2. 백업 생성
    final existingData = _prefs?.getString(_saveKey);
    if (existingData != null) {
      await _prefs?.setString('${_saveKey}_backup', existingData);
    }

    // 3. 실제 키에 저장
    await _prefs?.setString(_saveKey, jsonString);

    // 4. 임시 키 삭제
    await _prefs?.remove('${_saveKey}_temp');

    return true;
  } catch (e) {
    // 복구 시도...
    return false;
  }
}
```

**Severity:** CRITICAL
**Status:** FIXED (2026-02-05)

---

## HIGH SEVERITY BUGS

### BUG-002: 대화 스킵 스팸 시 대화 누락
**TC-028 관련**

**파일:** `lib/game/managers/dialogue_manager.dart:134-159`

**현재 코드:**
```dart
void advance() {
  if (_currentNode == null || _currentSequence == null) return;

  // ← 쿨다운/디바운스 없음!

  if (_currentNode!.hasChoices) {
    _state = DialogueState.choosing;
    return;
  }
  // ...
}
```

**문제:**
- `advance()` 메서드에 호출 제한이 없음
- 매크로/빠른 입력으로 0.1초에 10회 호출 가능
- 중요한 스토리 대화가 플레이어 의도 없이 스킵될 수 있음

**재현 단계:**
1. NPC 대화 시작
2. Enter 키를 빠르게 연타 (10회/초)
3. 대화 내용을 읽지 못하고 종료됨

**권장 수정:**
```dart
double _advanceCooldown = 0;
static const double _minAdvanceInterval = 0.15; // 150ms

void advance() {
  if (_advanceCooldown > 0) return;  // 쿨다운 체크
  _advanceCooldown = _minAdvanceInterval;

  // ... 기존 로직
}

void update(double dt) {
  if (_advanceCooldown > 0) {
    _advanceCooldown -= dt;
  }
}
```

**Severity:** HIGH
**Status:** FIXED (2026-02-05)

---

## MEDIUM SEVERITY BUGS

### BUG-003: 적 음수 체력 시 체력바 렌더링 오류
**TC-011 관련**

**파일:** `lib/game/enemies/base_enemy.dart:132, 178-227`

**현재 코드:**
```dart
void _drawHealthBar(Canvas canvas) {
  final healthRatio = health / data.maxHealth;  // ← health가 음수면?
  // ...
  canvas.drawRect(
    Rect.fromLTWH(0, -8, size.x * healthRatio, 4),  // ← 음수 width
    fgPaint,
  );
}

void takeDamage(double damage) {
  // ...
  health -= actualDamage;  // ← 음수가 될 수 있음
  // ...
  if (health <= 0) {
    _die();  // ← 같은 프레임에서 render가 먼저 호출되면?
  }
}
```

**문제:**
- `takeDamage()`에서 체력이 0 이하로 감소
- `_die()` 호출 전 같은 프레임에서 `render()` 호출 시
- 음수 `healthRatio`로 인해 체력바가 반대 방향으로 그려질 수 있음

**권장 수정:**
```dart
void _drawHealthBar(Canvas canvas) {
  final healthRatio = (health / data.maxHealth).clamp(0.0, 1.0);  // 클램프 추가
  // ...
}
```

**Severity:** MEDIUM (시각적 오류)
**Status:** FIXED (2026-02-05)

---

### BUG-004: 플레이어와 보스 동시 사망 시 불확실한 결과
**TC-009 관련**

**파일:** `lib/game/characters/player.dart`, `lib/game/enemies/base_enemy.dart`

**문제:**
- 플레이어와 보스가 같은 프레임에 HP 0이 될 경우
- `onGameOver`와 `onBossDefeated` 콜백 호출 순서가 비결정적
- 승리/패배 화면 중 어느 것이 표시될지 불확실

**시나리오:**
```
Frame N:
  - 보스 공격 → 플레이어 HP 0 → _loseHeart() → _die() → onGameOver
  - 플레이어 공격 → 보스 HP 0 → _die() → (콜백 없음, arcana_game에서 체크)
```

**현재 상태:** 보스 사망 콜백이 arcana_game.dart의 update에서 체크되므로, 플레이어가 먼저 죽으면 게임오버가 먼저 발생할 가능성 높음.

**권장 수정:**
```dart
// arcana_game.dart
void _checkBossDefeated() {
  // 플레이어가 이미 죽었으면 체크 스킵
  if (_player?.isDead == true) return;

  // 보스 처치 체크...
}
```

**Severity:** MEDIUM
**Status:** FIXED (2026-02-05)

---

## LOW SEVERITY BUGS

### BUG-005: 적 스폰 직후 히트박스 등록 지연
**TC-046 관련**

**파일:** `lib/game/enemies/base_enemy.dart:53-73`

**현재 코드:**
```dart
@override
Future<void> onLoad() async {
  await super.onLoad();  // ← 비동기

  health = data.maxHealth;
  ai = EnemyAI(...);

  add(RectangleHitbox(...));  // ← onLoad 완료 후에야 히트박스 추가
}
```

**문제:**
- `onLoad()`가 비동기이므로 컴포넌트가 world에 추가된 후 1프레임 지연
- 그 사이에 플레이어 공격 시 히트 판정 누락 가능

**영향:** 매우 드문 케이스 (플레이어가 적 스폰 직후 0.016초 내에 공격해야 함)

**Severity:** LOW
**Status:** OPEN (우선순위 낮음)

---

### BUG-006: 환경 오브젝트 중복 대화 트리거 가능성
**TC-060 관련**

**파일:** `lib/game/decorations/story_object.dart:86-91`

**현재 코드:**
```dart
void _checkPlayerProximity() {
  // ...
  final wasNearby = _playerNearby;
  _playerNearby = distance < 48;

  if (_playerNearby && !wasNearby && !_interacted) {
    _interact();
  }
}
```

**문제:**
- 플레이어가 범위를 나갔다 다시 들어오면 대화가 재트리거 될 수 있음
- `_interacted = true`는 `startDialogue`가 성공한 경우에만 설정됨
- 대화 시스템이 바쁠 때 `startDialogue`가 실패하면 다음 접근 시 재시도됨

**현재 상태:** 의도된 동작일 수 있음 (대화 재시도). 단, 명확한 사양 확인 필요.

**Severity:** LOW
**Status:** NEEDS CLARIFICATION

---

### BUG-007: 체력바 UI 오버플로우 (999+ HP)
**TC-032 관련**

**현재 상태:** 체력바는 비율 기반 렌더링이므로 시각적 문제 없음.
단, 숫자 텍스트 표시 시 UI 밖으로 삐져나갈 수 있음.

**Severity:** LOW (현재 숫자 표시 없음)
**Status:** NOT A BUG (현재 구현 기준)

---

## VERIFIED NO BUGS

다음 테스트 케이스는 코드 검토 결과 **버그 없음** 확인:

| TC ID | 검토 항목 | 결과 |
|-------|----------|------|
| TC-052 | 대각선 이동 정규화 | `_keyboardVelocity.normalized()` 적용됨 (line 613) |
| TC-020 | 인벤토리 풀 시 아이템 획득 | `return false` 반환 (line 97) |
| TC-021 | 스택 오버플로우 | `maxStack` 제한 적용됨 |
| TC-049 | 렌더링 우선순위 | priority 값 명시됨 (이전 수정 완료) |

---

## Action Items

| Priority | Bug ID | Action | Status |
|----------|--------|--------|--------|
| P0 | BUG-001 | 저장 시스템 원자적 쓰기 구현 | **FIXED** |
| P1 | BUG-002 | 대화 advance 디바운스 추가 | **FIXED** |
| P2 | BUG-003 | 체력바 healthRatio 클램프 | **FIXED** |
| P2 | BUG-004 | 동시 사망 시나리오 처리 | **FIXED** |
| P3 | BUG-005 | 히트박스 즉시 등록 검토 | NOT A BUG (문서화) |

## Fix Summary (2026-02-05)

### BUG-001 수정 내용
- `save_manager.dart`: 원자적 쓰기 패턴 적용
- 임시 키 → 백업 → 메인 키 순서로 저장
- 앱 시작 시 미완료 쓰기 복구 로직 추가
- 로드 실패 시 백업에서 복구 시도

### BUG-002 수정 내용
- `dialogue_manager.dart`: 150ms 디바운스 추가
- `_lastAdvanceTime` 타임스탬프로 스팸 방지
- 너무 빠른 입력은 무시됨

### BUG-003 수정 내용
- `base_enemy.dart`: `healthRatio.clamp(0.0, 1.0)` 적용
- 음수/초과 체력 비율 방지

### BUG-004 수정 내용
- `arcana_game.dart`: `_onBossDefeated()`에 플레이어 생존 체크 추가
- 동시 사망 시 게임오버 우선 처리

---

*Generated by Lead QA Engineer AI*
*Last Updated: 2026-02-05*
