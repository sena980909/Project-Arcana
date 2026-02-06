# Development Log: 프로젝트 재구축

**날짜:** 2026-02-06
**상태:** 진행중

## 작업 내용
- 기존 lib 폴더 전체 삭제 후 재구축
- 키보드 입력 문제 해결 (ServicesBinding.instance.keyboard 사용)
- GDD 및 Protocol 문서 기반으로 새로 구현

## 구현 목표 (Phase 1 Prototype)
1. 플레이어 이동 (WASD)
2. 기본 공격 (J / 마우스)
3. 대시 (Space)
4. 기본 적 (허수아비)
5. 데미지 표시
6. HP/마나 HUD
7. 상점 시스템 (E/F4)

## 사용 에셋
- `assets/images/itchio/0x72_DungeonTilesetII_v1.7/` - 던전 타일셋
- `assets/images/itchio/knights.png` - 기사 스프라이트
- `assets/images/itchio/pumpkin_dude.png` - 적 스프라이트

## 변경 파일
- lib/main.dart (새로 생성)
- lib/game/ (전체 구조)
- lib/ui/ (HUD, 오버레이)
- pubspec.yaml (간소화)

## 이슈/해결
- 키보드 입력: Focus 위젯이 GameWidget에 포커스 빼앗김 → ServicesBinding.instance.keyboard 사용으로 해결
