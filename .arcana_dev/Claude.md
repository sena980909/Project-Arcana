# 🤖 Project Arcana: Claude Agent Protocol

이 문서는 'Project Arcana' 개발을 담당하는 AI(Claude)가 따라야 할 **절대적인 행동 수칙(Protocol)**입니다.

우리의 목표는 "빠른 개발"이 아닌 **"신중하고, 추적 가능하며, 버그 없는 개발"**입니다.

---

## 1. 핵심 철학 (Core Philosophy)

- **Think Before Code:** 코드를 작성하기 전에 반드시 설계와 로직을 먼저 텍스트로 정리한다.
- **Logs are Life:** 모든 작업 내역은 파일로 기록되어야 한다. 로그가 없으면 작업은 수행되지 않은 것이다.
- **Sub-Agent Simulation:** 혼자 모든 것을 처리하려 하지 말고, 내부적으로 역할을 나누어(Architect → Coder → Tester → Critic) 시뮬레이션한다.
- **Test-Driven Mindset:** 코드를 짰으면 반드시 검증 로직(Test Code)이나 검증 시나리오를 함께 제안한다.

---

## 2. 작업 디렉토리 구조 (Workspace Structure)

AI는 프로젝트 루트에 다음과 같은 메타 데이터 폴더를 생성하고 관리해야 한다.

```
.arcana_dev/
├── logs/                  # 개발 로그 저장소
├── plans/                 # 기능 구현 전 설계 문서
├── tests/                 # 기능 단위 테스트 시나리오
└── reviews/               # ⭐ 가상 테스터 리뷰 리포트
    └── review_01_alpha_graphic.md
```

---

## 3. 개발 루틴 (Development Loop)

AI는 하나의 기능을 구현할 때 반드시 다음 루틴을 순서대로 수행해야 한다.

### 🔄 Step 1: 작업 분석 및 계획 (Architect Agent)
- **행동:** 구현 목표, 클래스 설계, 사이드 이펙트 분석 후 `plans/` 작성.

### 🔄 Step 2: 코드 구현 (Coder Agent)
- **행동:** PRD 준수, 한글 주석 필수, Atomic Commit 지향.

### 🔄 Step 3: 자체 코드 리뷰 (Reviewer Agent)
- **체크리스트:** `dynamic` 금지, 예외 처리, 리소스 해제 확인.

### 🔄 Step 4: 테스트 및 디버깅 (Tester Agent)
- **행동:** 기능 작동 여부 검증 (Unit Test).

### 🔄 ⭐ Step 4.5: 가상 크리틱 (Critic Agent) - 핵심!
- **트리거 조건:** UI, 그래픽, 맵, 게임 로직 변경 시 **무조건 실행**.
- **행동:** 가상의 **'독설가 게이머'**가 되어 현재 결과물을 비판한다.
- **평가 기준:**
  - **Visual:** "네모 박스(Placeholder)가 보이는가?" → 0점 처리.
  - **Feel:** "타격감/이펙트가 밋밋한가?" → 수정 요구.
  - **Flow:** "게임의 목적(기승전결)이 없는가?" → 레벨 디자인 요구.
- **산출물:** `reviews/critical_review_{id}.md` (개선 제안서 포함).

### 🔄 Step 5: 로그 기록 (Scribe Agent)
- **행동:** `logs/` 폴더에 최종 리포트 저장.

---

## 4. 파일 템플릿 (File Templates)

### 📄 계획 문서 (Plan Template)
파일명: `.arcana_dev/plans/plan_{번호}_{기능명}.md`

```markdown
# Plan: [기능명]

## 목표
- 구현할 기능 설명

## 설계
- 클래스/함수 구조
- 데이터 흐름

## 사이드 이펙트
- 영향받는 기존 코드

## 체크리스트
- [ ] 항목 1
- [ ] 항목 2
```

### 📝 개발 로그 (Log Template)
파일명: `.arcana_dev/logs/{날짜}_{작업명}_log.md`

```markdown
# Development Log: [작업명]

**날짜:** YYYY-MM-DD
**상태:** 완료/진행중

## 작업 내용
- 구현한 내용

## 변경 파일
- 파일 목록

## 이슈/해결
- 발생한 문제와 해결 방법
```

### 🔍 가상 리뷰 리포트 (Review Template)
파일명: `.arcana_dev/reviews/review_{번호}_{대상}.md`

```markdown
# 🧐 Critical Review: [대상 기능/버전]

## 1. 가상 테스터 프로필
* **페르소나:** 20년차 하드코어 레트로 게이머 (매우 까칠함)
* **평가 점수:** ⭐☆☆☆☆ ~ ⭐⭐⭐⭐⭐

## 2. 적나라한 비판 (The Bad)
* "구체적인 비판 내용"

## 3. 칭찬할 점 (The Good)
* "잘된 부분"

## 4. 개선 요구사항 (Action Items)
1. **카테고리:** 구체적인 개선 방안
```

---

## 5. 비상 대처 수칙 (Safety Protocol)

### ⚠️ 빌드 실패 시
1. 에러 메시지 전문 확인
2. 최근 변경사항 롤백 검토
3. `flutter clean && flutter pub get` 실행

### ⚠️ 런타임 크래시 시
1. 스택 트레이스 분석
2. null safety 관련 이슈 우선 확인
3. late 초기화 문제 점검

### ⚠️ 성능 이슈 시
1. DevTools 프로파일링
2. 불필요한 rebuild 확인
3. 이미지/에셋 최적화 검토

---

## 6. 금지 사항 (Don'ts)

- ❌ `dynamic` 타입 사용 금지
- ❌ 테스트 없이 복잡한 로직 머지 금지
- ❌ 로그 없이 대규모 변경 금지
- ❌ Placeholder(네모 박스) 상태로 "완료" 선언 금지
- ❌ 사운드/이펙트 없이 액션 게임 "완성" 선언 금지

---

*Last Updated: 2026-02-03*
*Protocol Version: 2.0 (Critic Agent 추가)*
