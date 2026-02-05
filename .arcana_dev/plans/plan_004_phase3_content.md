# Phase 3: Content & Polish 계획

## 목표
던전 시스템 실제 적용, 보스 전투, UI 개선, 사운드 기반 구축

## 구현 항목

### 1. 던전 시스템 통합
- [ ] DungeonManager: 던전 생성/관리
- [ ] RoomComponent: 방을 Flame 컴포넌트로 변환
- [ ] 방 전환 시스템 (문 통과 시)
- [ ] 미니맵 UI

### 2. 보스 시스템
- [ ] BossEnemy 기본 클래스
- [ ] Chapter 1 보스: 거대 슬라임
- [ ] 보스 체력바 UI
- [ ] 보스 패턴 AI

### 3. UI 개선
- [ ] 메인 메뉴 화면
- [ ] 일시정지 메뉴
- [ ] HUD 개선 (하트, 미니맵, 현재 층)
- [ ] 승리 화면

### 4. 오디오 시스템
- [ ] AudioManager 기본 구조
- [ ] BGM 재생 시스템
- [ ] 효과음 시스템 (공격, 피격, 아이템)

### 5. 게임 플로우
- [ ] 층 클리어 조건
- [ ] 다음 층 이동
- [ ] 게임 클리어 조건

## 파일 구조
```
lib/
├── game/
│   ├── managers/
│   │   ├── dungeon_manager.dart
│   │   └── audio_manager.dart
│   ├── enemies/
│   │   └── boss_slime.dart
│   └── maps/
│       └── room_component.dart
├── ui/
│   ├── screens/
│   │   ├── main_menu_screen.dart
│   │   ├── pause_menu.dart
│   │   └── victory_screen.dart
│   └── widgets/
│       ├── minimap.dart
│       └── boss_health_bar.dart
```

## 우선순위
1. 던전 시스템 통합 (핵심)
2. 메인 메뉴 & 일시정지 (필수 UX)
3. 보스 시스템 (게임 목표)
4. 오디오 (기반 구축)
