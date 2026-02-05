# 🪵 Dev Log: Phase 1 - Prototype

## 1. 작업 요약
* **상태:** 완료
* **작업 일시:** 2026-02-03
* **PRD 섹션:** 7. 상세 개발 마일스톤 - Phase 1: Prototype

## 2. 완료된 작업

### 2.1 게임 엔진 전환
- [x] Bonfire 제거 (Flame과의 호환성 문제)
- [x] 순수 Flame 1.18.0 기반으로 재구현
- [x] FlameGame 클래스 기반 ArcanaGame 구현

### 2.2 Player 캐릭터 구현
- [x] 8방향 이동 (WASD / 방향키)
- [x] 조이스틱 입력 지원
- [x] 방향 표시 인디케이터
- [x] 공격 시스템 (스페이스바 / 터치 버튼)
- [x] 히트박스 설정
- [x] PRD 4.2 하트 시스템 기반 색상 변화

### 2.3 조이스틱 컨트롤
- [x] Flame JoystickComponent 연동
- [x] 공격 버튼 (HudButtonComponent)
- [x] 카메라 뷰포트에 HUD 요소 배치

### 2.4 타일맵 구현
- [x] 코드 기반 20x15 타일맵 생성
- [x] 벽/바닥 구분
- [x] 벽 충돌 히트박스

### 2.5 허수아비 적 구현
- [x] DummyEnemy 클래스 구현
- [x] 피격 시 흔들림 효과 (shake)
- [x] 데미지 숫자 팝업 (위로 떠오르며 페이드 아웃)
- [x] 히트스톱 효과 (0.05초)
- [x] 체력바 표시
- [x] 사망 시 제거

### 2.6 전투 시스템 기초
- [x] PRD 4.1 데미지 공식 적용 (ATK * Random(0.9~1.1) - DEF * 0.5)
- [x] 최소 데미지 1 보장
- [x] 공격 쿨다운 (0.4초)

## 3. 생성된 파일

| 파일 | 설명 |
|------|------|
| `lib/game/arcana_game.dart` | 메인 게임 클래스 (FlameGame) |
| `lib/game/characters/player.dart` | 플레이어 캐릭터 |
| `lib/game/enemies/dummy_enemy.dart` | 허수아비 적 |
| `lib/game/maps/game_map.dart` | 코드 기반 타일맵 |
| `lib/game/interface/game_hud.dart` | 인게임 HUD |
| `lib/ui/screens/game_screen.dart` | 게임 화면 위젯 |

## 4. 수정된 파일

| 파일 | 변경 내용 |
|------|-----------|
| `lib/main.dart` | 게임 화면 라우팅 추가 |
| `pubspec.yaml` | Bonfire 제거, 순수 Flame 사용 |

## 5. 트러블슈팅 (Debugging)

### 문제 1: Bonfire + Flame 버전 호환성
* **문제:** Bonfire 3.6.2와 Flame 1.18~1.30 간 API 호환성 문제
* **원인:** Bonfire가 사용하는 Flame API(SpriteWidget.srcPosition 등)가 최신 Flame에서 제거됨
* **해결:** Bonfire 제거 후 순수 Flame으로 재구현

### 문제 2: Dart SDK 버전 제약
* **문제:** Bonfire 최신 버전(3.16+)은 Dart 3.8+ 필요
* **원인:** 현재 환경은 Dart 3.6.2
* **해결:** Flame 1.18.0 (Dart 3.6 호환) 사용

## 6. 검증 결과

### 린트 분석
```
flutter analyze
-> 2 info (error 0, warning 0)
```

### 테스트 실행
```
flutter test
-> 00:00 +1: All tests passed!
```

## 7. 다음 단계 (Phase 2: Core Loop)
- [ ] 적 AI (State Machine): 배회 -> 추적 -> 공격
- [ ] 던전 생성 알고리즘: 프리팹 방 랜덤 연결
- [ ] 인벤토리 시스템: 아이템 획득 시 UI 반영
- [ ] 게임 오버 및 재시작 프로세스

## 8. 기술 노트

### 사용 버전
- Flutter SDK: 3.27.4
- Dart SDK: 3.6.2
- Flame: 1.18.0
- flame_audio: 2.10.2

### 게임 조작법
- **이동**: WASD / 방향키 / 조이스틱
- **공격**: 스페이스바 / 빨간 버튼
- **종료**: X 버튼 -> 확인 다이얼로그

### 구현 특징
- 스프라이트 없이 코드 기반 렌더링 (색상 박스)
- 카메라 플레이어 추적
- 충돌 감지 시스템 활성화
