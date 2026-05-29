# Current Task

_마지막 업데이트: 2026-04-23_

---

## 현재 작업

완료

## 완료된 것

- [x] GitHub URL 수정 (ljjunh → jaejeonglee)
- [x] 마이그레이션 폴더 제거
- [x] .ai/ → .claude/docs/ 통합
- [x] 문서 간소화 (10개 → 2개)
- [x] init.sh 질문 제거 + 로컬/원격 분기 수정
- [x] SessionStart 훅: 모든 세션으로 확장
- [x] settings.json 항상 덮어쓰기로 변경
- [x] analyze.sh 삭제
- [x] Stop 훅 개선 (코드 변경 없으면 즉시 통과)
- [x] CLAUDE.md 첫 실행 시 행동 지시 추가
- [x] permissions.deny 추가 (.env, *.pem, *.key, credentials, secret)
- [x] README 전면 개편 (전문적 톤 + 구조 간소화)
- [x] gemini-researcher 조건부 분기 (GEMINI_API_KEY 없으면 WebSearch 폴백)
- [x] codex-reasoner 조건부 분기 (codex CLI 없으면 Claude 자체 추론)
- [x] /add-rule 스킬 추가 (프로젝트 규칙을 conventions.md에 기록)
- [x] CLAUDE.md에 규칙 자동 감지 지시 추가
- [x] 기존 사용자용 멱등적 CLAUDE.md 병합 (init.sh 재실행 지원)
- [x] codex-reasoner를 CLI 방식 → OPENAI_API_KEY 방식으로 전환 (Gemini와 대칭)
- [x] README 쉽게 다시 작성 (대화체, 비유 사용)
- [x] v1.0.0 태그 + GitHub push 완료
- [x] architecture.md 프로젝트 타입 무관하게 재설계 (빈 템플릿)
- [x] /update-architecture 스킬 추가 (6가지 프로젝트 유형 자동 감지)
- [x] CLAUDE.md에 "아키텍처 변경 감지 시" 트리거 조건 추가
- [x] Karpathy 4원칙(Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution)을 CLAUDE.md Part 1으로 흡수
- [x] init.sh 멱등 병합에 Karpathy 섹션 자동 추가 로직 추가 (기존 사용자 자동 업그레이드)
- [x] 표준 문서 카테고리 디렉토리 도입 (api/, contracts/, runbooks/, decisions/, reference/)
- [x] CLAUDE.md에 "문서 찾기" 섹션 추가 (정적 가이드)
- [x] SessionStart 훅에 .claude/docs/ 디렉토리 트리 동적 출력 추가
- [x] /migrate-from-ai 스킬 추가 (구버전 .ai/ → 새 구조 분류·통합·이동)
- [x] init.sh 멱등 병합 확장 (문서 찾기 섹션 + /migrate-from-ai Skills 행)
- [x] 멀티에이전트 오케스트레이션 제거 (Opus 4.8 + 네이티브 서브에이전트 + Dynamic Workflows로 잉여화)
  - codex-reasoner / gemini-researcher 에이전트 삭제
  - call-codex.sh / call-gemini.sh 삭제
  - CLAUDE.md 라우팅 테이블 제거, 워크플로우 재작성
  - README 재포지셔닝 (코딩 자세 + 프로젝트 메모리 + 워크플로우 규율)
  - init.sh에서 agents/scripts 생성·복사 제거

## 남은 것

(없음)
