# Test Plan: Project Arcana Alpha Build v0.98

**작성일:** 2026-02-05
**QA 담당:** Lead QA Engineer (AI)
**대상 빌드:** arcana_the_three_hearts.exe (Windows Debug)
**테스트 철학:** "무조건 부서진다"는 전제하에 극한 테스트

---

## 1. Combat Mechanics (전투/조작) - 15 Cases

### 1.1 Input Abuse (입력 남용)
- [ ] **TC-001 [Spam Attack]:** 공격 버튼(Z/J)을 매크로 수준(초당 10회)으로 연타할 때 애니메이션이 끊기거나 다중 히트가 발생하는가?
- [ ] **TC-002 [Spam Dash]:** Space 키를 연속으로 10번 빠르게 누를 때 대시 쿨다운이 무시되는가?
- [ ] **TC-003 [Simultaneous Input]:** 이동(WASD) + 공격(Z) + 스킬(Q) + 대시(Space)를 동시에 입력할 때 크래시가 발생하는가?
- [ ] **TC-004 [Key Held]:** 공격 키를 5초간 누르고 있을 때 무한 공격이 발생하거나 메모리 누수가 있는가?

### 1.2 Hitbox & Collision (충돌 판정)
- [ ] **TC-005 [Hitbox Edge]:** 몬스터 뒤통수에 딱 붙었을 때 공격이 히트하는가? (정상: 히트해야 함)
- [ ] **TC-006 [Wall Clip]:** 벽 모서리에서 대시 시 벽을 뚫고 지나가는가?
- [ ] **TC-007 [Door Stuck]:** 문 진입 직전 공격 시 문과 플레이어가 겹치는 상태로 멈추는가?
- [ ] **TC-008 [Enemy Stack]:** 여러 적이 같은 위치에 겹쳤을 때 개별 히트 판정이 정상 작동하는가?

### 1.3 Death & Game Over (사망 처리)
- [ ] **TC-009 [Simultaneous Death]:** 플레이어와 보스가 동시에 HP 0이 될 때, 승리인가 패배인가? (정상: 승리)
- [ ] **TC-010 [Death Potion]:** 사망 직전(HP 1) 물약 사용 시 체력 회복이 정상 적용되는가?
- [ ] **TC-011 [Negative HP]:** 체력 100에서 데미지 150을 받았을 때 HP가 음수로 표시되지 않는가?
- [ ] **TC-012 [Heart Loss]:** 심장 손실 시 정확히 HP가 풀로 회복되는가? (PRD 4.2 검증)

### 1.4 Boss Combat (보스 전투)
- [ ] **TC-013 [Boss Phase Skip]:** 보스 HP를 한 번에 50% 이상 깎았을 때 페이즈 전환이 스킵되는가?
- [ ] **TC-014 [Boss Boundary]:** 보스방에서 보스를 밀어서 벽 밖으로 보낼 수 있는가?
- [ ] **TC-015 [Boss Respawn]:** 보스 처치 후 방을 나갔다 들어오면 보스가 다시 스폰되는가? (정상: 안 됨)

---

## 2. Data & State (데이터/저장) - 12 Cases

### 2.1 Save/Load System
- [ ] **TC-016 [Save Corruption]:** 저장 중 게임을 강제 종료(Alt+F4)하면 세이브 파일이 손상되는가?
- [ ] **TC-017 [Load During Combat]:** 보스전 중 로드 시 보스 HP와 페이즈가 초기화되는가?
- [ ] **TC-018 [Save Timing]:** 대화 진행 중 저장 시 대화 상태가 올바르게 복원되는가?
- [ ] **TC-019 [Floor Save]:** 6층에서 저장 후 로드 시 정확히 6층에서 시작하는가?

### 2.2 Inventory System
- [ ] **TC-020 [Inventory Full]:** 인벤토리 20칸이 가득 찼을 때 아이템 획득 시 아이템이 사라지는가? (정상: 획득 거부)
- [ ] **TC-021 [Stack Overflow]:** 포션 99개 보유 상태에서 1개 더 획득 시 100이 되는가 아니면 새 슬롯인가?
- [ ] **TC-022 [Negative Gold]:** 골드 0 상태에서 구매 시도 시 음수 골드가 되는가?
- [ ] **TC-023 [Equip Race]:** 장착 해제와 동시에 다른 아이템 장착 시 둘 다 장착되는가?

### 2.3 Flag System (스토리 플래그)
- [ ] **TC-024 [Flag Persistence]:** `has_heart_of_past` 플래그 설정 후 저장/로드 시 유지되는가?
- [ ] **TC-025 [Duplicate Flag]:** 같은 플래그를 2번 설정해도 부작용이 없는가?
- [ ] **TC-026 [True Ending Flags]:** 3개 트루엔딩 플래그 모두 충족 시 엔딩 분기가 정상 작동하는가?
- [ ] **TC-027 [Missing Item Check]:** 약속의 반지 없이 Ch6 보스 처치 시 노멀 엔딩으로 가는가?

---

## 3. UI/UX & Responsive (인터페이스) - 10 Cases

### 3.1 Dialogue System
- [ ] **TC-028 [Dialogue Skip]:** 대화 스킵 버튼을 0.1초 간격으로 연타할 때 텍스트가 겹치거나 크래시가 나는가?
- [ ] **TC-029 [Choice Spam]:** 선택지가 표시되기 전에 Enter를 누르면 선택이 스킵되는가?
- [ ] **TC-030 [Dialogue Chain]:** 연속 대화(ch3_memory_recovery → ch3_epilogue) 전환 시 대화가 끊기는가?
- [ ] **TC-031 [NPC Interrupt]:** NPC 대화 중 공격당하면 대화가 중단되는가? (정상: 중단 안 됨)

### 3.2 HUD & Display
- [ ] **TC-032 [HP Bar Overflow]:** HP 바에 999 이상의 체력이 표시될 때 UI가 깨지는가?
- [ ] **TC-033 [Long Item Name]:** 20글자 이상의 아이템 이름이 UI 밖으로 삐져나가는가?
- [ ] **TC-034 [Heart Gauge Visual]:** 심장 게이지 100% 초과 충전 시 시각적 오류가 있는가?

### 3.3 Window/Resolution
- [ ] **TC-035 [Window Resize]:** 게임 창 크기를 급격히 조절할 때 UI 요소가 사라지거나 겹치는가?
- [ ] **TC-036 [Minimize Game]:** 보스전 중 게임 최소화 후 복귀 시 게임이 멈춰있는가? (정상: 일시정지)
- [ ] **TC-037 [Alt+Tab]:** Alt+Tab으로 포커스 이동 후 키 입력이 씹히는가?

---

## 4. Performance (성능) - 8 Cases

### 4.1 Memory & FPS
- [ ] **TC-038 [Enemy Spawn Stress]:** 적이 20마리 이상 한 화면에 있을 때 FPS가 30 이하로 떨어지는가?
- [ ] **TC-039 [Room Transition Leak]:** 방을 50번 이상 이동했을 때 메모리 사용량이 증가하는가?
- [ ] **TC-040 [Effect Spam]:** 슬래시 이펙트, 파티클을 100개 이상 동시 생성 시 프레임 드랍이 있는가?
- [ ] **TC-041 [BGM Loop]:** BGM이 2시간 이상 반복 재생될 때 메모리 누수가 있는가?

### 4.2 Loading & Initialization
- [ ] **TC-042 [Cold Start]:** 게임 첫 실행 시 로딩 시간이 10초를 초과하는가?
- [ ] **TC-043 [Floor Load]:** 다음 층으로 이동 시 로딩 중 화면이 검게 멈추는가?
- [ ] **TC-044 [Asset Cache]:** 같은 보스를 2번째 싸울 때 스프라이트 로딩이 캐시되는가?
- [ ] **TC-045 [Garbage Collection]:** 챕터 클리어 후 GC Pause가 100ms를 초과하는가?

---

## 5. Flame Engine Collision Bugs (충돌 시스템) - 10 Cases

### 5.1 Hitbox Registration
- [ ] **TC-046 [Late Hitbox]:** 적이 스폰된 직후(0.1초 이내) 공격 시 히트 판정이 안 되는가?
- [ ] **TC-047 [Removed Hitbox]:** 적 사망 후 사라지기 전에 해당 위치에 히트박스가 남아있는가?
- [ ] **TC-048 [Passive Collision]:** StoryObject의 CircleHitbox(passive)가 플레이어 공격에 반응하는가? (정상: 안 함)

### 5.2 Component Priority
- [ ] **TC-049 [Render Order]:** 방 전환 후 플레이어가 바닥 아래로 렌더링되는가? (이전 수정됨 - 재검증)
- [ ] **TC-050 [Z-Order Boss]:** 보스 사망 이펙트가 플레이어 위에 렌더링되는가?
- [ ] **TC-051 [Item Z-Index]:** DroppedItem이 적 뒤에 가려지는가? (priority 70 검증)

### 5.3 Movement & Physics
- [ ] **TC-052 [Diagonal Speed]:** 대각선 이동 시 속도가 √2배로 빨라지는가? (정상: 정규화 필요)
- [ ] **TC-053 [Knockback Clip]:** 넉백으로 벽에 부딪힐 때 벽 속으로 끼는가?
- [ ] **TC-054 [Teleport Glitch]:** 방 전환 시 플레이어가 잘못된 좌표에 스폰되는가?
- [ ] **TC-055 [AI Stuck]:** 적 AI가 장애물 뒤에서 무한 루프에 빠지는가?

---

## 6. Story & Progression (스토리/진행) - 10 Cases

### 6.1 Chapter Flow
- [ ] **TC-056 [Chapter Skip]:** 챕터 1을 클리어하지 않고 챕터 2로 갈 수 있는가? (정상: 불가)
- [ ] **TC-057 [Boss Re-entry]:** 클리어한 보스방에 다시 들어갈 수 있는가?
- [ ] **TC-058 [NPC Respawn]:** 챕터 시작 NPC가 방을 나갔다 들어오면 다시 등장하는가?

### 6.2 Dialogue Triggers
- [ ] **TC-059 [Story Item Dialogue]:** 부서진 나뭇잎 펜던트 획득 시 `ch1_item_pendant` 대화가 자동 시작되는가?
- [ ] **TC-060 [Env Object Trigger]:** 환경 오브젝트(벽화/비문) 접근 시 대화가 정확히 1번만 트리거되는가?
- [ ] **TC-061 [Duplicate Pickup]:** 이미 플래그가 설정된 스토리 아이템을 다시 획득할 수 있는가?

### 6.3 Ending Branch
- [ ] **TC-062 [Normal Ending Path]:** 플래그 미충족 시 ch6_normal_ending_choice로 분기되는가?
- [ ] **TC-063 [True Ending Path]:** 3개 플래그 충족 시 ch6_true_ending_option으로 분기되는가?
- [ ] **TC-064 [Ending Replay]:** 엔딩 후 타이틀로 돌아가 새 게임 시작 시 플래그가 초기화되는가?
- [ ] **TC-065 [Credits Skip]:** 엔딩 크레딧 중 스킵이 가능한가?

---

## 7. Edge Cases & Stress Test (극한 시나리오) - 5 Cases

- [ ] **TC-066 [Long Play]:** 3시간 연속 플레이 후 성능 저하나 메모리 누수가 있는가?
- [ ] **TC-067 [Rapid Room Switch]:** 방 출입구를 1초에 5번 왔다 갔다 할 때 크래시가 나는가?
- [ ] **TC-068 [Multiple Save Load]:** 저장→로드→저장→로드를 10회 반복 시 데이터 무결성이 유지되는가?
- [ ] **TC-069 [All Bosses No Damage]:** 전 챕터 보스를 무피해로 클리어 시 특수 처리가 있는가?
- [ ] **TC-070 [Inventory Stress]:** 인벤토리를 빠르게 열고 닫기(20회/초) 시 UI가 버벅거리는가?

---

## Test Summary

| Category | Total | Passed | Failed | Blocked |
|----------|-------|--------|--------|---------|
| Combat | 15 | - | - | - |
| Data | 12 | - | - | - |
| UI/UX | 10 | - | - | - |
| Performance | 8 | - | - | - |
| Collision | 10 | - | - | - |
| Story | 10 | - | - | - |
| Edge Cases | 5 | - | - | - |
| **Total** | **70** | **-** | **-** | **-** |

---

## Critical Bugs Found (테스트 후 기록)

| ID | Severity | Description | Steps to Reproduce | Status |
|----|----------|-------------|-------------------|--------|
| - | - | - | - | - |

---

## Notes

1. **우선순위**: TC-009(동시 사망), TC-046(히트박스), TC-016(저장 손상)은 반드시 먼저 테스트
2. **자동화 가능**: TC-038~TC-045 성능 테스트는 프로파일러 도구 사용 권장
3. **회귀 테스트**: TC-049(렌더 순서)는 이전 수정 건이므로 재검증 필수

---

## Bug Fixes Applied (2026-02-05)

### Critical Fixes
- **TC-016 (저장 손상)**: 원자적 쓰기 패턴 적용, 백업/복구 시스템 추가
- **Room Clear Bug**: 적 처치 시 `notifyEnemyKilled()` 호출 추가 → 스테이지 이동 활성화

### High Priority Fixes
- **TC-028 (대화 스킵)**: 150ms 디바운스 적용

### Medium Priority Fixes
- **TC-003/BUG-003 (음수 HP)**: 체력바 비율 클램프 적용
- **TC-009/BUG-004 (동시 사망)**: 플레이어 사망 시 보스 처치 무시
- **Y-소팅 버그**: Player, NPC, Enemy에 Y좌표 기반 동적 priority 적용

### Files Modified
- `lib/data/services/save_manager.dart`
- `lib/game/managers/dialogue_manager.dart`
- `lib/game/managers/dungeon_manager.dart`
- `lib/game/enemies/base_enemy.dart`
- `lib/game/enemies/dummy_enemy.dart`
- `lib/game/characters/player.dart`
- `lib/game/characters/npc_component.dart`
- `lib/game/arcana_game.dart`

---

*Generated by Lead QA Engineer AI*
*Last Updated: 2026-02-05*
