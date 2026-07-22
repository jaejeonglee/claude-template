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
