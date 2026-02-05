# 📋 Plan: Phase 1 - Prototype

## 1. 개요
* **목표:** Bonfire 기반 게임 코어 프로토타입 구현
* **관련 PRD 섹션:** 7. 상세 개발 마일스톤 - Phase 1: Prototype (2~3주차)

## 2. 작업 목록

### 2.1 게임 화면 기본 구조
- [ ] BonfireGame 위젯 생성
- [ ] 메인 메뉴에서 게임 화면으로 전환
- [ ] 게임 HUD 기본 틀 (체력바 표시 영역)

### 2.2 Player 캐릭터 구현
- [ ] SimplePlayer 클래스 상속한 Player 구현
- [ ] 8방향 이동 애니메이션 (임시 스프라이트)
- [ ] 기본 공격 액션 구현
- [ ] 히트박스(Hitbox) 설정

### 2.3 조이스틱 컨트롤
- [ ] Bonfire Joystick 컴포넌트 연동
- [ ] 공격 버튼 추가
- [ ] 입력 딜레이 0.1초 미만 검증

### 2.4 타일맵 구현
- [ ] 16x16 타일 기반 간단한 맵 생성
- [ ] WorldMapByTiled 또는 직접 구현
- [ ] 벽/장애물 충돌 처리

### 2.5 허수아비 적 구현
- [ ] SimpleEnemy 클래스 상속한 Dummy 구현
- [ ] 피격 시 흔들림 효과 (shake)
- [ ] 데미지 숫자 팝업 표시
- [ ] 기본 AI 없음 (가만히 서있음)

### 2.6 전투 시스템 기초
- [ ] PRD 데미지 공식 적용
- [ ] 히트스톱 효과 (0.05초)
- [ ] 화면 흔들림 효과

## 3. 설계 상세

### 새로 생성할 파일:
```
lib/
├── game/
│   ├── arcana_game.dart           # 메인 게임 클래스
│   ├── characters/
│   │   ├── player.dart            # 플레이어 캐릭터
│   │   └── player_sprite.dart     # 플레이어 스프라이트 정의
│   ├── enemies/
│   │   └── dummy_enemy.dart       # 허수아비 적
│   ├── interface/
│   │   ├── game_hud.dart          # 인게임 HUD
│   │   └── damage_text.dart       # 데미지 숫자 표시
│   └── maps/
│       └── test_map.dart          # 테스트용 맵
└── ui/
    └── screens/
        └── game_screen.dart       # 게임 화면 위젯
```

### 수정할 파일:
* `lib/main.dart` - 게임 화면 라우팅 추가
* `lib/config/assets.dart` - 임시 스프라이트 경로 추가

### 사용할 Bonfire 클래스:
* `BonfireGame` - 메인 게임 위젯
* `SimplePlayer` - 플레이어 베이스
* `SimpleEnemy` - 적 베이스
* `Joystick` - 조이스틱 컨트롤
* `TextDamageComponent` - 데미지 표시

## 4. 예상 리스크
* Bonfire 3.x API 변경사항 확인 필요
* 임시 스프라이트 없이 테스트 시 에러 가능 -> 컬러 박스로 대체
* 타일맵 로드 시 경로 문제 가능

## 5. 완료 조건
- [ ] 플레이어가 조이스틱으로 8방향 이동 가능
- [ ] 공격 버튼 누르면 공격 애니메이션 재생
- [ ] 허수아비 때리면 데미지 숫자 표시 + 흔들림
- [ ] 벽에 부딪히면 이동 불가
- [ ] 입력 반응 0.1초 미만
