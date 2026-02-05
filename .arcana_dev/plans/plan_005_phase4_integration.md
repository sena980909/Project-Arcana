# Phase 4: Integration & Flow 계획

## 목표
모든 시스템 통합, 완전한 게임 플로우 구현, 세이브/로드

## 구현 항목

### 1. 메인 앱 통합
- [x] AppRouter: 화면 전환 관리
- [x] GameController: 게임 전체 상태 관리
- [x] main.dart 업데이트

### 2. 게임 화면 통합
- [x] game_screen.dart 업데이트 (HUD, 일시정지, 보스바 통합)
- [x] 동적 보스 이름 표시
- [x] 인벤토리 연결

### 3. 세이브/로드 시스템
- [x] SaveData 모델
- [x] SaveManager: 로컬 저장소 연동
- [x] hasSaveData 연동
- [x] 자동 저장 (방/층 클리어 시)
- [x] 실제 로드 플로우 연결
- [x] Provider loadFromSave 메서드

### 4. 게임 플로우
- [x] 메인메뉴 → 게임 시작
- [x] 게임 중 일시정지
- [x] 게임 오버 → 재시작/메인메뉴
- [x] 승리 → 메인메뉴

### 5. 엔딩 시스템 (추가)
- [x] EndingType 열거형 (normal, true)
- [x] 승리 화면 분기 (노멀/트루)
- [x] 엔딩별 색상/텍스트/아이콘
- [x] 엔딩 트리거 연결 (onVictory 콜백)
- [x] 보스 시작 콜백 (onBossStart)

### 6. 대화 시스템 통합 (완료)
- [x] DialogueOverlay 위젯 구현
- [x] Flutter 오버레이로 게임에 통합
- [x] 대화 시작/종료 콜백 연결
- [x] 대화 노드 변경 콜백 연결
- [x] 대화 진행/선택 메서드 구현

## 파일 구조
```
lib/
├── app/
│   ├── arcana_app.dart (완료)
│   └── game_controller.dart (완료)
├── data/
│   └── services/
│       └── save_manager.dart (완료)
├── ui/
│   ├── screens/
│   │   └── victory_screen.dart (완료 - 엔딩 분기)
│   └── overlays/
│       └── dialogue_overlay.dart (완료)
└── main.dart (완료)
```

## 완료 날짜
2026-02-04 (1차 통합)
