---
trigger: manual
description: 구버전 .ai/ 디렉토리를 분석하여 .claude/ 새 구조로 분류·통합·이동
---

# /migrate-from-ai

사용법: `/migrate-from-ai`

기존 프로젝트에 `.ai/` 디렉토리가 있으면, 내용을 분석해서 새 `.claude/` 구조에 맞게 분류·통합·이동한다.

## 핵심 원칙

1. **흡수 가능한 내용** → `architecture.md` / `conventions.md`에 통합 후 원본 삭제
2. **흡수 불가능한 큰 레퍼런스** → 카테고리 디렉토리에 그대로 이동 (`api/`, `contracts/`, `runbooks/`, `decisions/`, `reference/`)
3. **이미 다른 곳에 있는 중복 내용** → 그냥 삭제
4. **구버전 템플릿 파일** → 삭제

## 표준 카테고리 디렉토리

| 디렉토리 | 들어갈 내용 |
|---|---|
| `.claude/docs/api/` | API 스펙, OpenAPI 문서, REST/GraphQL 계약 |
| `.claude/docs/contracts/` | 스마트 컨트랙트(*.sol), DB 스키마(ddl.sql, schema.prisma), proto, ERD |
| `.claude/docs/runbooks/` | 운영 가이드, 모니터링, 알림, 보안 플레이북, 인시던트 대응 |
| `.claude/docs/decisions/` | ADR (Architecture Decision Records) |
| `.claude/docs/specs/` | 진행 중인 기획 초안 (`*.draft.md`) |
| `.claude/docs/reference/` | 큰 설계 문서, 도메인 가이드, 기타 참조 |

## 실행 절차 (Claude가 수행)

### Step 1. 백업

```bash
cp -r .ai .ai-backup-$(date +%Y%m%d)
```

원본 보존. 마이그레이션 검증 후 사용자가 직접 삭제 가능.

### Step 2. 전수 스캔

`.ai/` 하위 모든 파일을 읽고 내용을 파악한다.

### Step 3. 파일별 분류

각 파일을 다음 4가지 중 하나로 분류:

| 분류 | 처리 |
|---|---|
| **흡수 — architecture** | 시스템 구조 설명을 `architecture.md`에 통합 후 원본 삭제 |
| **흡수 — conventions** | 코딩/도메인/보안 규칙을 `conventions.md`에 통합 후 원본 삭제 |
| **이동 — 카테고리 디렉토리** | 표준 디렉토리 중 적절한 곳으로 이동 (내용 변경 없음) |
| **삭제** | 구버전 템플릿 파일이거나 이미 다른 곳에 정리된 중복 내용 |

#### 분류 휴리스틱

- 작고 구조 설명 위주 (시스템 개요, 모듈 흐름, 데이터 흐름) → 흡수 architecture
- 작고 규칙 위주 (코딩 룰, 도메인 정책, 보안 원칙) → 흡수 conventions
- 큼 (5K+) 또는 레퍼런스 성격 → 카테고리 이동
- 코드 아티팩트 (*.sol, *.sql, *.proto, *.html) → `contracts/`
- 운영/보안 문서 → `runbooks/`
- ADR로 시작하거나 의사결정 기록 → `decisions/`
- `*.draft.md` → `specs/`
- 큰 설계/도메인 문서 → `reference/`
- `.ai/README.md`, `.ai/agents.md`, `.ai/context-reset.md` → 삭제 (구버전 템플릿)

### Step 4. 분류 리포트 작성 + 사용자 확인

```
🔍 마이그레이션 분류 결과

[흡수 → architecture.md] (N개)
- .ai/architecture.md (7.5K)
- .ai/docs/ARCHITECTURE.md (5.3K)
- .ai/docs/EVENT_FINALITY_ARCHITECTURE.md
- .ai/docs/SERVER_FLOW.md (요약 흡수)

[흡수 → conventions.md] (N개)
- .ai/conventions.md (4.2K)
- .ai/docs/security/SECURITY_THREAT_MODEL.md (정책 부분)

[이동 → .claude/docs/api/]
- .ai/docs/API_DOCS.md → api-reference.md (104K, 그대로)

[이동 → .claude/docs/contracts/]
- .ai/docs/contracts/*.sol
- .ai/docs/ddl.sql
- .ai/docs/erd.html

[이동 → .claude/docs/runbooks/]
- .ai/docs/ALERTING.md
- .ai/docs/monitoring.md
- .ai/docs/RDS_MANAGEMENT.md
- .ai/docs/security/DETECTION_PLAYBOOK.md
- .ai/docs/security/INCIDENT_CATALOG.md
- ...

[이동 → .claude/docs/decisions/]
- .ai/docs/ADR_ETL_MSA_PROJECTION.md

[이동 → .claude/docs/reference/]
- .ai/docs/ID_DESIGN.md
- .ai/docs/USER_SYSTEM_CURRENT.md
- ...

[이동 → .claude/docs/specs/]
- .ai/docs/specs/oracle-plugin-design.draft.md

[삭제] (구버전 템플릿 + 중복)
- .ai/README.md
- .ai/agents.md
- .ai/context-reset.md
- .ai/docs/PROJECT.md (architecture.md/conventions.md로 분산 흡수됨)

이대로 진행? [y/N/특정 파일 재분류]
```

**모호한 케이스는 사용자에게 질문:**
> "RDS_MANAGEMENT.md는 운영 절차(runbooks)로 볼지, 인프라 구조(architecture 흡수)로 볼지 모호합니다. 어디로 분류할까요?"

### Step 5. 실행

사용자 확정 후:

1. 표준 디렉토리 생성 (`mkdir -p .claude/docs/{api,contracts,runbooks,decisions,reference}`)
2. **흡수 작업** — 내용을 분석해서 `architecture.md` / `conventions.md`의 적절한 섹션에 통합
3. **이동 작업** — 큰 레퍼런스를 카테고리 디렉토리로 그대로 이동
4. **삭제 작업** — 흡수된 원본 + 구버전 템플릿
5. 빈 `.ai/` 디렉토리 정리

### Step 6. 후처리

- CLAUDE.md / CURRENT_TASK.md 안의 `.ai/` 경로 일괄 치환 (`sed`)
- `.gitignore`에서 `.ai` 항목 제거 (있으면)

### Step 7. 마이그레이션 로그

`.claude/docs/MIGRATION_LOG.md` 생성:

```markdown
# Migration Log

_YYYY-MM-DD_

## 흡수된 파일 (원본 삭제됨)
- `.ai/architecture.md` → `architecture.md` 시스템 개요/모듈 섹션
- `.ai/docs/SERVER_FLOW.md` → `architecture.md` 데이터 흐름 섹션
- ...

## 이동된 파일
- `.ai/docs/API_DOCS.md` → `.claude/docs/api/api-reference.md`
- `.ai/docs/contracts/*.sol` → `.claude/docs/contracts/`
- ...

## 삭제된 파일
- `.ai/README.md` (구버전 템플릿)
- `.ai/agents.md` (CLAUDE.md로 흡수됨)
- ...

## 백업 위치
`.ai-backup-YYYYMMDD/` (검증 후 직접 삭제 가능)
```

### Step 8. 보고

```
✅ 마이그레이션 완료

흡수: N개 (architecture.md / conventions.md로 통합)
이동: M개 (카테고리 디렉토리로 분류)
삭제: K개 (구버전 + 중복)

architecture.md: X줄 → Y줄 (Z 섹션 추가)
conventions.md: X줄 → Y줄 (Z 섹션 추가)

상세: .claude/docs/MIGRATION_LOG.md
백업: .ai-backup-YYYYMMDD/
```

## 안전장치

- **dry-run 우선**: 실제 변경 전 분류 리포트 + 사용자 확정
- **백업 필수**: `.ai-backup-YYYYMMDD/`로 원본 보존
- **Git 커밋 권장**: 마이그레이션 전 작업 커밋 권유 ("진행 전 git commit 권장")
- **단일 파일 단위 진행**: 흡수 시 한 번에 하나씩, 중간 중단 가능
- **분류 근거 명시**: "이 파일은 OOO이라 [카테고리]로 분류"
- **모호 케이스 질문**: 자체 판단 어려우면 사용자에게 질문

## 주의사항

- 원본 `.ai/`는 백업 후에만 변경
- 흡수 시 **중복 내용 제거** (같은 정보가 여러 파일에 있으면 한 번만)
- 흡수 시 **일관성 유지** (용어, 형식 통일)
- 큰 파일은 절대 흡수하지 말고 카테고리 이동 (architecture.md 비대화 방지)
- API_DOCS, *.sol, ddl.sql 같이 코드/스펙 성격이면 무조건 카테고리 이동
