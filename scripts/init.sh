#!/bin/bash
# claude-template init script
# 사용법: bash <(curl -s https://raw.githubusercontent.com/jaejeonglee/claude-template/main/scripts/init.sh)
# 또는 클론 후: bash scripts/init.sh

set -e

TEMPLATE_REPO="https://raw.githubusercontent.com/jaejeonglee/claude-template/main"
TARGET_DIR="${1:-$(pwd)}"
TODAY=$(date +%Y-%m-%d)
PROJECT_NAME=$(basename "$TARGET_DIR")

# 로컬 템플릿 경로 (클론 후 실행 시에만 유효)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_LOCAL="$(dirname "$SCRIPT_DIR")"

# 로컬 템플릿이 유효한지 확인 (CLAUDE.md.template 존재 여부로 판단)
if [ ! -f "$TEMPLATE_LOCAL/CLAUDE.md.template" ]; then
  TEMPLATE_LOCAL=""
fi

# 색상
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "Claude Template 설치"
echo "────────────────────────────────────────"
echo "대상: $TARGET_DIR"
echo ""

# 파일 복사 또는 다운로드
copy_file() {
  local src="$1"
  local dest="$2"

  if [ -n "$TEMPLATE_LOCAL" ] && [ -f "$TEMPLATE_LOCAL/$src" ]; then
    cp "$TEMPLATE_LOCAL/$src" "$dest"
  else
    curl -sf "$TEMPLATE_REPO/$src" -o "$dest" || {
      echo -e "${RED}[오류] $src 다운로드 실패${NC}"
      exit 1
    }
  fi
}

# 이미 있으면 건너뜀
copy_if_not_exists() {
  local src="$1"
  local dest="$2"

  if [ -f "$dest" ]; then
    echo "  건너뜀: $(echo $dest | sed "s|$TARGET_DIR/||")"
    return
  fi

  copy_file "$src" "$dest"
  echo "  생성: $(echo $dest | sed "s|$TARGET_DIR/||")"
}

# [1/4] 디렉토리
echo -e "${GREEN}[1/4] 디렉토리 생성...${NC}"
mkdir -p "$TARGET_DIR/.claude/skills/new-spec"
mkdir -p "$TARGET_DIR/.claude/skills/update-task"
mkdir -p "$TARGET_DIR/.claude/skills/add-rule"
mkdir -p "$TARGET_DIR/.claude/skills/update-architecture"
mkdir -p "$TARGET_DIR/.claude/skills/migrate-from-ai"

# 표준 문서 카테고리 디렉토리 (이미 있으면 그대로 유지)
mkdir -p "$TARGET_DIR/.claude/docs/api"
mkdir -p "$TARGET_DIR/.claude/docs/contracts"
mkdir -p "$TARGET_DIR/.claude/docs/runbooks"
mkdir -p "$TARGET_DIR/.claude/docs/decisions"
mkdir -p "$TARGET_DIR/.claude/docs/reference"
mkdir -p "$TARGET_DIR/.claude/docs/specs"

# [2/4] 스킬 + 설정 (항상 최신으로 덮어씀)
echo -e "${GREEN}[2/4] 스킬·설정 복사...${NC}"
copy_file ".claude/skills/new-spec/SKILL.md" "$TARGET_DIR/.claude/skills/new-spec/SKILL.md"
copy_file ".claude/skills/update-task/SKILL.md" "$TARGET_DIR/.claude/skills/update-task/SKILL.md"
copy_file ".claude/skills/add-rule/SKILL.md" "$TARGET_DIR/.claude/skills/add-rule/SKILL.md"
copy_file ".claude/skills/update-architecture/SKILL.md" "$TARGET_DIR/.claude/skills/update-architecture/SKILL.md"
copy_file ".claude/skills/migrate-from-ai/SKILL.md" "$TARGET_DIR/.claude/skills/migrate-from-ai/SKILL.md"
copy_file ".claude/settings.json" "$TARGET_DIR/.claude/settings.json"

# [3/4] 문서 (이미 있으면 건너뜀)
echo -e "${GREEN}[3/4] 문서 생성...${NC}"
copy_if_not_exists ".claude/docs/architecture.md" "$TARGET_DIR/.claude/docs/architecture.md"
copy_if_not_exists ".claude/docs/conventions.md" "$TARGET_DIR/.claude/docs/conventions.md"

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  # 기존 CLAUDE.md가 있으면 누락된 섹션만 추가 (멱등적 병합)
  APPENDED=0

  # 0. Karpathy 4원칙 추가 (없으면 맨 앞 헤더 뒤에 삽입)
  if ! grep -q "# Part 1. 코딩 자세" "$TARGET_DIR/CLAUDE.md"; then
    KARPATHY_TMP=$(mktemp)
    if [ -n "$TEMPLATE_LOCAL" ]; then
      awk '/^# Part 1\./,/^# Part 2\./' "$TEMPLATE_LOCAL/CLAUDE.md.template" \
        | sed '$d' > "$KARPATHY_TMP"
    else
      curl -sf "$TEMPLATE_REPO/CLAUDE.md.template" \
        | awk '/^# Part 1\./,/^# Part 2\./' \
        | sed '$d' > "$KARPATHY_TMP"
    fi

    if [ -s "$KARPATHY_TMP" ]; then
      # 첫 줄(헤더) + 구분선 + Karpathy 섹션 + 나머지
      {
        head -n 1 "$TARGET_DIR/CLAUDE.md"
        echo ""
        echo "---"
        echo ""
        cat "$KARPATHY_TMP"
        tail -n +2 "$TARGET_DIR/CLAUDE.md"
      } > "$TARGET_DIR/CLAUDE.md.tmp" && \
        mv "$TARGET_DIR/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md"
      APPENDED=1
    fi
    rm -f "$KARPATHY_TMP"
  fi

  # 1. Skills 테이블에 /add-rule 추가 (섹션 추가 전에 먼저 — 중복 매칭 방지)
  if ! grep -qE '^\|.*\/add-rule' "$TARGET_DIR/CLAUDE.md"; then
    if grep -q "/update-task" "$TARGET_DIR/CLAUDE.md"; then
      awk '
        /\/update-task.*CURRENT_TASK/ {
          print;
          print "| `/add-rule <규칙>` | 프로젝트 규칙을 `conventions.md`에 추가 |";
          next
        }
        { print }
      ' "$TARGET_DIR/CLAUDE.md" > "$TARGET_DIR/CLAUDE.md.tmp" && \
        mv "$TARGET_DIR/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md"
      APPENDED=1
    fi
  fi

  # 1-b. Skills 테이블에 /update-architecture 추가
  if ! grep -qE '^\|.*\/update-architecture' "$TARGET_DIR/CLAUDE.md"; then
    if grep -q "/add-rule" "$TARGET_DIR/CLAUDE.md"; then
      awk '
        /\/add-rule.*conventions/ {
          print;
          print "| `/update-architecture` | `architecture.md`를 현재 코드 기준으로 생성/갱신 |";
          next
        }
        { print }
      ' "$TARGET_DIR/CLAUDE.md" > "$TARGET_DIR/CLAUDE.md.tmp" && \
        mv "$TARGET_DIR/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md"
      APPENDED=1
    fi
  fi

  # 1-c. Skills 테이블에 /migrate-from-ai 추가
  if ! grep -qE '^\|.*\/migrate-from-ai' "$TARGET_DIR/CLAUDE.md"; then
    if grep -q "/update-architecture" "$TARGET_DIR/CLAUDE.md"; then
      awk '
        /\/update-architecture.*architecture/ {
          print;
          print "| `/migrate-from-ai` | 구버전 `.ai/` 디렉토리를 새 구조로 분류·이동 |";
          next
        }
        { print }
      ' "$TARGET_DIR/CLAUDE.md" > "$TARGET_DIR/CLAUDE.md.tmp" && \
        mv "$TARGET_DIR/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md"
      APPENDED=1
    fi
  fi

  # 1-d. "문서 찾기" 섹션 추가 (없으면 "## 세션 시작 시" 섹션 뒤에 삽입)
  if ! grep -q "## 문서 찾기" "$TARGET_DIR/CLAUDE.md"; then
    DOCFINDER_TMP=$(mktemp)
    cat > "$DOCFINDER_TMP" << 'DOC_FINDER'

---

## 문서 찾기

특정 정보가 필요하면 아래 위치를 우선 탐색한다. 카테고리는 디렉토리 단위로 안정적이고, 디렉토리 안의 실제 파일은 `ls`로 동적 확인.

| 무엇을 찾을 때 | 위치 | 로드 방식 |
|---|---|---|
| 시스템 구조, 모듈 | `.claude/docs/architecture.md` | 항상 로드 (작게 유지) |
| 코딩 규칙, 정책 | `.claude/docs/conventions.md` | 항상 로드 (작게 유지) |
| API 스펙 / OpenAPI | `.claude/docs/api/` | 필요 시 grep |
| 스마트 컨트랙트, DB 스키마, proto, ddl | `.claude/docs/contracts/` | 필요 시 |
| 운영 가이드, 보안 플레이북, 인시던트 | `.claude/docs/runbooks/` | 필요 시 |
| 의사결정 기록 (ADR) | `.claude/docs/decisions/` | 필요 시 |
| 기획 초안 (작업 중) | `.claude/docs/specs/` | 작업 시 |
| 기타 큰 참조 자료 | `.claude/docs/reference/` | 필요 시 |

**원칙:**
- `architecture.md`, `conventions.md`는 **작고 핵심만** — 항상 컨텍스트에 로드되니까.
- 큰 레퍼런스(API 100K+, 보안 플레이북, ADR 등)는 카테고리 디렉토리에 배치 — 필요할 때만 읽기.
- 새 카테고리가 생기면 SessionStart 훅의 디렉토리 트리에 자동 반영됨.
DOC_FINDER

    # "## 세션 시작 시" 섹션 끝나는 지점 또는 파일 끝에 삽입
    if grep -q "## 세션 시작 시" "$TARGET_DIR/CLAUDE.md"; then
      # 첫 번째 "---" 구분선 뒤에 삽입
      awk -v doc_finder_file="$DOCFINDER_TMP" '
        BEGIN { inserted = 0 }
        /^## 세션 시작 시/ { in_session = 1 }
        in_session && /^---$/ && !inserted {
          while ((getline line < doc_finder_file) > 0) print line
          close(doc_finder_file)
          inserted = 1
          next
        }
        { print }
        END {
          if (!inserted) {
            while ((getline line < doc_finder_file) > 0) print line
            close(doc_finder_file)
          }
        }
      ' "$TARGET_DIR/CLAUDE.md" > "$TARGET_DIR/CLAUDE.md.tmp" && \
        mv "$TARGET_DIR/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md"
    else
      cat "$DOCFINDER_TMP" >> "$TARGET_DIR/CLAUDE.md"
    fi
    rm -f "$DOCFINDER_TMP"
    APPENDED=1
  fi

  # 2-a. "아키텍처 변경 감지 시" 섹션 추가
  if ! grep -q "## 아키텍처 변경 감지 시" "$TARGET_DIR/CLAUDE.md"; then
    cat >> "$TARGET_DIR/CLAUDE.md" << 'ARCH_SECTION'

---

## 아키텍처 변경 감지 시

다음 중 하나라도 발생하면 `/update-architecture`를 실행해 `architecture.md`를 갱신한다:

- 의존성 매니페스트 변경 (`package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pubspec.yaml` 등)
- 새 top-level 디렉토리 생성 (src/, app/, pkg/ 등의 바로 아래)
- 주요 설정 파일 추가/변경 (`tsconfig`, `*.config.*`, `Dockerfile` 등)
- 데이터 스키마 변경 (migration, `schema.prisma`, `*.proto`, `*.sql` 등)
- 외부 API / 서비스 통합 추가·제거

버그 수정, 리팩터링, 로직 변경만으로는 갱신하지 않는다.
ARCH_SECTION
    APPENDED=1
  fi

  # 2. "새 규칙 발견 시" 섹션 추가
  if ! grep -q "## 새 규칙 발견 시" "$TARGET_DIR/CLAUDE.md"; then
    cat >> "$TARGET_DIR/CLAUDE.md" << 'RULE_SECTION'

---

## 새 규칙 발견 시

사용자 지시나 프로젝트 분석에서 아래 패턴을 감지하면 **즉시 `/add-rule`을 실행**해 `conventions.md`에 기록한다:

| 감지 패턴 | 예시 |
|---|---|
| "앞으로 ~해줘" / "항상 ~하게" | "앞으로 에러 메시지는 한글로" |
| "이 프로젝트는 ~를 지킨다" | "모든 API에 rate limit 필수" |
| "절대 ~하지 마" / "~ 금지" | "console.log 금지, 항상 logger 사용" |
| 기획 확정 과정에서 도출된 정책 | "결제는 idempotency key 필수" |

기록 후 `규칙을 conventions.md에 기록했습니다` 로 1줄 보고.
RULE_SECTION
    APPENDED=1
  fi

  if [ $APPENDED -eq 1 ]; then
    echo "  업데이트: CLAUDE.md (누락 섹션 추가)"
  else
    echo "  건너뜀: CLAUDE.md (최신 상태)"
  fi
else
  if [ -n "$TEMPLATE_LOCAL" ]; then
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
      "$TEMPLATE_LOCAL/CLAUDE.md.template" > "$TARGET_DIR/CLAUDE.md"
  else
    curl -sf "$TEMPLATE_REPO/CLAUDE.md.template" | \
      sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" > "$TARGET_DIR/CLAUDE.md"
  fi
  echo "  생성: CLAUDE.md"
fi

if [ -f "$TARGET_DIR/.claude/CURRENT_TASK.md" ]; then
  echo "  건너뜀: .claude/CURRENT_TASK.md"
else
  if [ -n "$TEMPLATE_LOCAL" ]; then
    sed "s/{{DATE}}/$TODAY/g" \
      "$TEMPLATE_LOCAL/CURRENT_TASK.md.template" > "$TARGET_DIR/.claude/CURRENT_TASK.md"
  else
    curl -sf "$TEMPLATE_REPO/CURRENT_TASK.md.template" | \
      sed "s/{{DATE}}/$TODAY/g" > "$TARGET_DIR/.claude/CURRENT_TASK.md"
  fi
  echo "  생성: .claude/CURRENT_TASK.md"
fi

if [ -f "$TARGET_DIR/.claude/PROGRESS.md" ]; then
  echo "  건너뜀: .claude/PROGRESS.md"
else
  if [ -n "$TEMPLATE_LOCAL" ]; then
    cp "$TEMPLATE_LOCAL/PROGRESS.md.template" "$TARGET_DIR/.claude/PROGRESS.md"
  else
    curl -sf "$TEMPLATE_REPO/PROGRESS.md.template" -o "$TARGET_DIR/.claude/PROGRESS.md"
  fi
  echo "  생성: .claude/PROGRESS.md"
fi

# [4/4] .gitignore
echo -e "${GREEN}[4/4] .gitignore 업데이트...${NC}"
GITIGNORE="$TARGET_DIR/.gitignore"
for entry in ".claude" "CLAUDE.md"; do
  if [ -f "$GITIGNORE" ] && grep -qxF "$entry" "$GITIGNORE"; then
    echo "  이미 있음: $entry"
  else
    echo "$entry" >> "$GITIGNORE"
    echo "  추가: $entry"
  fi
done

# 완료
echo ""
echo "────────────────────────────────────────"
echo -e "${GREEN}설치 완료!${NC}"
echo ""
echo -e "${YELLOW}다음:${NC} claude 실행"
echo ""
