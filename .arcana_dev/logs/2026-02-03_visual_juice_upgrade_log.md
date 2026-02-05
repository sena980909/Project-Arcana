# Development Log: Visual & Juice 업그레이드

**날짜:** 2026-02-03
**상태:** 완료

## 작업 내용

Critical Review (review_001_alpha_state.md)에서 지적된 비주얼/타격감 문제 해결

### 1. 캐릭터 비주얼 개선
- 파란색 네모 → 픽셀아트 스타일 캐릭터로 변경
- 머리(눈, 머리카락), 몸통, 팔, 다리 개별 렌더링
- 방향별 다른 모습 구현 (좌/우/상/하)
- 이동 시 걷기 애니메이션 (walkBob, legSwing)
- 그림자 효과 추가

### 2. 적 비주얼 개선
- 슬라임: 기존 젤리 형태 유지 (이미 양호)
- 고블린: 완전 리디자인
  - 뾰족 귀, 피부색, 의상 추가
  - 곤봉 무기 휘두르기 애니메이션
  - 사악한 눈과 미소 표현

### 3. 맵 환경 개선
- 단일 색상 바닥 → 3가지 타일 타입 (풀/흙/돌)
- Perlin-like 노이즈로 자연스러운 배치
- 타일 디테일 추가 (패치, 균열, 벽돌 패턴)
- 장식 오브젝트 추가:
  - 작은 풀, 긴 풀
  - 꽃 (노란색/빨간색)
  - 버섯
  - 돌멩이
- 장애물 추가:
  - 바위 (소형/대형)
  - 나무 (기둥 충돌, 잎 표시)

### 4. 이펙트 시스템 구축 (lib/game/effects/)
- **particle_system.dart**: 파티클 기반 이펙트
  - 폭발 이펙트 (적 사망)
  - 피격 스파크 (데미지 받을 때)
  - 슬라임 스플래시 (슬라임 사망)
  - 연기 이펙트 (고블린 사망)

- **slash_effect.dart**: 공격 이펙트
  - SlashEffect: 검기/베기 궤적
  - ImpactEffect: 충격파 링

- **screen_effects.dart**: 화면 이펙트
  - ScreenShakeManager: 화면 흔들림 관리
  - HitFlashEffect: 피격 시 흰색 플래시

### 5. 타격감 강화
- 공격 시 슬래시 이펙트 발생
- 약한 화면 흔들림 (lightShake)
- 적 피격 시:
  - 흰색 플래시 오버레이
  - 스파크 파티클
  - 임팩트 이펙트
- 적 사망 시:
  - 종류별 사망 이펙트 (슬라임: 액체 튀김, 고블린: 연기)
  - 중간 강도 화면 흔들림

## 변경 파일

### 신규 생성
- lib/game/effects/particle_system.dart
- lib/game/effects/slash_effect.dart
- lib/game/effects/screen_effects.dart
- lib/game/effects/effects.dart (barrel file)

### 수정
- lib/game/characters/player.dart (픽셀아트 캐릭터, 이펙트 연동)
- lib/game/enemies/base_enemy.dart (피격/사망 이펙트)
- lib/game/enemies/slime_enemy.dart (사망 이펙트, 고블린 리디자인)
- lib/game/maps/game_map.dart (타일 다양화, 장식, 장애물)

## 이슈/해결

1. **PositionComponent.size 충돌**
   - 문제: SlashEffect, ImpactEffect, RockObstacle에서 `size` 필드가 부모 클래스와 충돌
   - 해결: `effectSize`, `rockSize`로 이름 변경

2. **const 생성자 오류**
   - 문제: `Rect.fromCenter`는 const 생성자가 아님
   - 해결: `const Rect.fromCenter(...)` → `Rect.fromCenter(center: const Offset(...))`

3. **maxLifetime 초기화**
   - 문제: Particle 클래스의 maxLifetime 미초기화
   - 해결: 생성자에서 initializer list로 `maxLifetime = lifetime` 추가

## 테스트 결과
- 빌드 성공 (에러 0개, info 9개)
- Windows 실행 성공

## 다음 단계 (Critic Review 예정)
- [ ] 새로운 비주얼 상태에서 Critical Review 수행
- [ ] 사운드 추가 (BGM, 효과음)
- [ ] 던전 진행 시스템 완성

---
*Log by: Claude Agent (Scribe Role)*
