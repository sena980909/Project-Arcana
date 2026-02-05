# Development Log: 심장 게이지/스킬 시스템 구현

**날짜:** 2026-02-04
**상태:** 완료

## 작업 내용

GDD 7장 "스킬 시스템"에 따라 심장 게이지 및 스킬 시스템 구현.

### 1. 심장 게이지 Provider (lib/providers/heart_gauge_provider.dart)

#### HeartGaugeState
- `current`: 현재 게이지 (0-100)
- `max`: 최대 게이지 (100)
- `ratio`: 게이지 비율
- `canUseUltimate`: 궁극기 사용 가능 여부

#### HeartGaugeNotifier
- `onDamageDealt(damage)`: 데미지/10 충전
- `onDamageTaken(damage)`: 데미지/5 충전
- `onPerfectDodge()`: 10 충전
- `onKill()`: 5 충전
- `consume(amount)`: 게이지 소모

### 2. 플레이어 스킬 Provider (lib/providers/player_skill_provider.dart)

#### PlayerSkillState
- `currentMana`, `maxMana`: 마나 상태
- `equippedSkills`: 장착된 스킬 ID (4슬롯)
- `skillCooldowns`: 스킬별 쿨다운

#### PlayerSkillNotifier
- `consumeMana(amount)`: 마나 소모
- `restoreMana(amount)`: 마나 회복
- `regenMana(dt)`: 자연 회복
- `equipSkill(slot, id)`: 스킬 장착
- `startCooldown(id, duration)`: 쿨다운 시작
- `updateCooldowns(dt)`: 쿨다운 업데이트

### 3. 스킬 관리자 (lib/game/managers/skill_manager.dart)

#### SkillManager (Flame Component)
- 스킬 설정 초기화 (`initialize`)
- 스킬 사용 조건 체크 (`canUseSkill`)
- 스킬 실행 (`useSkill`)
- 스킬 효과 발동 (`_executeSkillEffect`)
- 피드백 적용 (화면 흔들림, 사운드)
- 게이지 충전 콜백 (데미지/회피/처치)

#### SkillUseResult
```dart
enum SkillUseResult {
  success,      // 성공
  onCooldown,   // 쿨다운 중
  noMana,       // 마나 부족
  noHeartGauge, // 심장 게이지 부족
  notUnlocked,  // 해금되지 않음
  invalid,      // 유효하지 않은 스킬
}
```

### 4. HUD UI 확장 (lib/game/interface/game_hud.dart)

#### 새 위젯
- `ResourceBar`: HP/MP 바 (라벨 + 프로그레스 바)
- `HeartGaugeBar`: 심장 게이지 바 (보라색, 가득 차면 빛남)
- `SkillSlotsDisplay`: 스킬 슬롯 컨테이너
- `SkillSlot`: 개별 스킬 슬롯 (아이콘 + 키 라벨 + 쿨다운)

#### HUD 레이아웃
```
┌────────────────────────────────────────────────────────┐
│ [Hearts]   [HP Bar]████████████░░░░  150/150           │
│            [MP Bar]████████░░░░░░░░  80/100            │
│            [Heart]███████░░░░░░░░░░  70%      [Debug]  │
├────────────────────────────────────────────────────────┤
│                                                        │
│                    [게임 화면]                          │
│                                                        │
├────────────────────────────────────────────────────────┤
│    [Q] [W] [E] [R]      [SPACE]    [F]                 │
│    스킬1-4              대시       궁극기               │
└────────────────────────────────────────────────────────┘
```

## 변경 파일

### 신규
- lib/providers/heart_gauge_provider.dart
- lib/providers/player_skill_provider.dart
- lib/game/managers/skill_manager.dart

### 수정
- lib/game/interface/game_hud.dart

## 기존 파일 (참조)
- lib/data/models/skill_data.dart (스킬 데이터 모델)
- lib/config/constants.dart (상수 정의)

## 심장 게이지 충전 공식

| 이벤트 | 충전량 |
|--------|--------|
| 데미지 가함 | damage / 10 |
| 데미지 받음 | damage / 5 |
| 완벽 회피 | 10 |
| 적 처치 | 5 |

## 테스트 결과
- 빌드 성공 (Windows)
- UI 레이아웃 확인

## 다음 단계
- [ ] 스킬 키 입력 연동 (Q, W, E, R, F)
- [ ] 스킬 이펙트 시각화 강화
- [ ] 스킬 설정 JSON 로딩
- [ ] 챕터 1 컨텐츠 구현

---
*Log by: Claude Agent (Scribe Role)*
