---
trigger: manual
description: CURRENT_TASK.md 갱신 + 완료 항목을 JOURNAL.md로 이관
---

# /update-task

사용법: `/update-task`

현재 작업 상태를 파악하고 `.claude/CURRENT_TASK.md`를 최신 상태로 갱신한다.
완료된 항목은 `.claude/JOURNAL.md`에 시점과 함께 기록하고 CURRENT_TASK에서 제거한다.

## 실행 절차 (Claude가 수행)

### Step 1. 현황 파악

```bash
git branch --show-current
git log --oneline -5
git status
date +"%Y-%m-%d %H:%M"
```

### Step 2. 완료 항목 → JOURNAL.md 이관

이번에 완료된 작업이 있으면 `.claude/JOURNAL.md` **맨 아래에 append**:

```markdown
## 2026-06-15 14:32
- [완료된 작업 한 줄 요약]
- [또 다른 완료 작업]
```

- 시각은 반드시 Step 1의 `date` 결과 사용 (추측 금지)
- 과거 항목은 수정·삭제하지 않는다 (append-only)

### Step 3. CURRENT_TASK.md 갱신

`.claude/CURRENT_TASK.md`를 "지금 + 다음"만 남기고 갱신:

- **현재 작업** — 지금 진행 중인 작업 목표 (없으면 "(없음)")
- **다음 할 것** — 남은 항목, 새로 식별된 항목
- **막힌 부분** — 현재 블로커, 없으면 "(현재 없음)"
- **완료 항목은 이 파일에서 제거** (Step 2에서 저널로 이관됐으므로)

### Step 4. 날짜 갱신

`_마지막 업데이트: YYYY-MM-DD_` → 오늘 날짜로 업데이트

## 주의사항

- 완료 여부가 불확실한 항목은 저널로 보내지 않는다 (구현 완료 ≠ 검증 완료)
- CURRENT_TASK.md는 AI 간 핸드오프 문서 — 다음 세션 AI가 읽었을 때 맥락이 명확해야 한다
- CURRENT_TASK.md가 길어지고 있다면 잘못 쓰고 있는 것 (이력은 저널과 git log의 몫)
