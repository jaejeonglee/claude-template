# Journal

> 작업이 끝날 때마다 시점과 함께 기록하는 append-only 일지.
> 최신 항목이 아래에 붙는다. 과거 항목은 수정·삭제하지 않는다.
> 기록 전 `date +"%Y-%m-%d %H:%M"` 실행으로 실제 시각을 확인한다.

---

## 2026-07-22 18:22
- (이관) 2026-04 ~ 2026-07 이력 요약 — 상세는 git log 참조
  - 템플릿 초기 구축: 3-에이전트 오케스트레이션 + .ai/ 문서 체계
  - .ai/ → .claude/docs/ 통합, 문서 간소화, 훅 정비 (SessionStart/Stop/PostToolUse)
  - permissions.deny 민감 파일 차단, Karpathy 4원칙 Part 1 흡수
  - 스킬 5종: /new-spec /update-task /add-rule /update-architecture /migrate-from-ai
  - 표준 문서 택소노미 (api/ contracts/ runbooks/ decisions/ reference/)
  - Opus 4.8 출시 후 멀티에이전트 오케스트레이션 제거 (네이티브 Task + Dynamic Workflows로 잉여화)
  - 리포 rename: claude-orchestration-template → claude-template
- PROGRESS.md 폐지, JOURNAL.md(append-only 작업 일지) 도입

## 2026-07-22 18:24
- PROGRESS.md 폐지 → JOURNAL.md 도입 구현 완료
  - 템플릿/init.sh/훅(SessionStart tail·Stop 저널 검증)/스킬 3종 갱신
  - 레거시 마이그레이션 (PROGRESS 내용 → JOURNAL 이관 + CLAUDE.md 규칙 교체)
  - 검증 통과: 신규 / 레거시 / 멱등성

## 2026-07-22 18:29
- /add-hook 스킬 추가 — 자연어 자동화 요청을 훅 설정으로 변환
  - 커스텀 훅은 settings.local.json에 기록 (init.sh 덮어쓰기에서 생존)
  - CLAUDE.md: 규칙(/add-rule) vs 자동화(/add-hook) 라우팅 구분 추가
  - 검증 통과: 신규 / 레거시 행 삽입 / 멱등성

## 2026-07-23 09:51
- 주간 아키텍처 감사 도입 (문서-코드 드리프트 방지)
  - .last-arch-audit 마커 + SessionStart 훅 신호 (7일 경과 && 커밋 존재 시)
  - /update-architecture가 감사 후 마커 갱신 (변경 없음도 유효한 감사)
  - CLAUDE.md: 신호 보이면 해당 세션 내 실행 규칙
  - 검증: 신규/신호발생/조용한기간/레거시병합/멱등 통과
