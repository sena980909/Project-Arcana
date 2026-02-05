# 📋 Plan: Phase 0 - Project Setup

## 1. 개요
* **목표:** Flutter 프로젝트 초기 설정 및 개발 환경 구축
* **관련 PRD 섹션:** 7. 상세 개발 마일스톤 - Phase 0: The Setup

## 2. 작업 목록

### 2.1 Flutter 프로젝트 생성
- [ ] `flutter create` 명령으로 프로젝트 생성
- [ ] 프로젝트명: `arcana_the_three_hearts`
- [ ] 플랫폼: Windows, Web

### 2.2 린트(Lint) 규칙 설정
- [ ] `flutter_lints` 패키지 확인 (기본 포함)
- [ ] `analysis_options.yaml` 커스텀 규칙 추가
  - `dynamic` 타입 사용 경고
  - strict 모드 활성화

### 2.3 프로젝트 구조 설정
- [ ] PRD에 명시된 디렉토리 구조 생성:
  ```
  lib/
  ├── main.dart
  ├── config/
  │   ├── assets.dart
  │   └── constants.dart
  ├── data/
  │   ├── model/
  │   ├── repository/
  │   └── service/
  ├── game/
  │   ├── behaviors/
  │   ├── characters/
  │   ├── decorations/
  │   ├── interface/
  │   └── maps/
  ├── providers/
  └── ui/
      ├── components/
      └── screens/
  ```

### 2.4 의존성(Dependencies) 설정
- [ ] `pubspec.yaml`에 핵심 패키지 추가:
  - `bonfire: ^3.0.0`
  - `flame: ^1.16.0`
  - `flame_audio`
  - `flutter_riverpod`
  - `riverpod_annotation`
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
  - `shared_preferences`

### 2.5 Assets 폴더 구조
- [ ] `assets/` 폴더 생성:
  ```
  assets/
  ├── images/
  │   ├── characters/
  │   ├── enemies/
  │   ├── tiles/
  │   └── ui/
  ├── audio/
  │   ├── bgm/
  │   └── sfx/
  └── fonts/
  ```
- [ ] 픽셀 폰트(DungGeunMo 등) 적용 준비

### 2.6 Git 초기화
- [ ] Git 저장소 초기화
- [ ] `.gitignore` 설정
- [ ] 초기 커밋

## 3. 설계 상세

### 새로 생성할 파일:
* `lib/main.dart` - 앱 진입점
* `lib/config/assets.dart` - 에셋 경로 상수
* `lib/config/constants.dart` - 게임 물리 상수
* `analysis_options.yaml` - 린트 규칙 (수정)
* `pubspec.yaml` - 의존성 (수정)

### 수정할 파일:
* 없음 (신규 프로젝트)

## 4. 예상 리스크
* Flutter SDK 버전 호환성 (3.19.0 이상 필요)
* Bonfire 3.x와 Flame 1.16.x 버전 호환성 확인 필요
* Firebase 설정은 별도 단계에서 진행 (Dev/Prod 환경 분리)

## 5. 완료 조건
- [ ] `flutter run -d windows` 또는 `flutter run -d chrome`으로 빈 앱 실행 성공
- [ ] 린트 에러 0개
- [ ] 모든 디렉토리 구조 생성 완료
