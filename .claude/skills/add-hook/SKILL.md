---
trigger: manual
description: 자연어 요청을 Claude Code 훅으로 변환해 settings.local.json에 등록
---

# /add-hook

사용법: `/add-hook <자동화 설명>`

예시:
```
/add-hook 파이썬 파일 저장하면 black 실행
/add-hook 세션 시작할 때 npm outdated 결과 보여줘
/add-hook 작업 끝날 때 테스트 안 돌렸으면 경고
```

자연어로 설명한 자동화를 Claude Code 훅 설정으로 변환해서 등록한다.

## 핵심 원칙

**반드시 `.claude/settings.local.json`에 쓴다. `settings.json`은 절대 수정하지 않는다.**

- `settings.json` — 템플릿 관리 영역. init.sh 재실행 시 항상 덮어써짐.
- `settings.local.json` — 사용자 커스텀 영역. init.sh가 건드리지 않으므로 업그레이드에도 유지됨.
- Claude Code는 두 파일의 훅을 **병합해서 모두 실행**한다.

## 실행 절차 (Claude가 수행)

### Step 1. 의도 → 훅 이벤트 매핑

| 요청 패턴 | 이벤트 | matcher |
|---|---|---|
| "파일 저장/수정하면 ~" | `PostToolUse` | `Edit\|Write` |
| "파일 수정 전에 검사/차단" | `PreToolUse` | `Edit\|Write` |
| "명령/테스트 실행 후 ~" | `PostToolUse` | `Bash` |
| "작업/응답 끝날 때 ~" | `Stop` | (없음) |
| "세션 시작할 때 ~" | `SessionStart` | (없음) |
| "메시지 보낼 때마다 ~" | `UserPromptSubmit` | (없음) |

### Step 2. 훅 타입 선택

| 타입 | 용도 |
|---|---|
| `command` | 쉘 명령 실행 (린트, 포맷터, 알림, 정보 출력) |
| `prompt` | Claude 자기 검증 (조건 확인 후 `{"ok": true/false}` 응답) |

**훅 입력 계약**: 이벤트 JSON은 **stdin**으로 전달되고, 도구 인자는 `.tool_input.*`에 중첩되어 있다 (환경변수 아님). 특정 파일만 대상이면:

```bash
FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null); if [ -n "$FILE" ] && echo "$FILE" | grep -qE '\.py$'; then black "$FILE" 2>/dev/null; fi; exit 0
```

- Bash 명령 검사는 `.tool_input.command`
- 프로젝트 상대 경로를 쓰는 명령은 `cd "${CLAUDE_PROJECT_DIR:-.}"`로 앵커링 (하위 폴더에서 `claude` 실행해도 동작)
- PreToolUse에서 `exit 2` + stderr = 해당 도구 호출 차단

### Step 3. 설정 초안 작성 + 사용자 확인

훅은 쉘 명령을 실행하므로 **쓰기 전에 반드시 사용자에게 보여주고 확인받는다**:

```
다음 훅을 .claude/settings.local.json에 추가합니다:

이벤트: PostToolUse (Edit|Write)
동작: .py 파일 수정 시 black 자동 실행

{
  "type": "command",
  "command": "FILE=$(echo \"$CLAUDE_TOOL_INPUT\" | jq -r '.file_path // empty'); ..."
}

진행할까요?
```

### Step 4. settings.local.json에 병합

1. 파일이 없으면 `{"hooks": {}}` 로 생성
2. 기존 내용을 읽고 해당 이벤트 배열에 **추가** (기존 훅 보존)
3. 쓰기 후 JSON 유효성 검증:

```bash
jq empty .claude/settings.local.json && echo "JSON OK"
```

검증 실패 시 즉시 원복 (fail-close).

### Step 5. 보고 + 저널 기록

```
훅을 등록했습니다.
- 이벤트: [이벤트]
- 동작: [한 줄 설명]
- 위치: .claude/settings.local.json
- 적용: 다음 세션부터 (또는 즉시 — 이벤트에 따라)
```

`.claude/JOURNAL.md`에 시점과 함께 기록.

## 주의사항

- **위험한 명령 거부** — `rm -rf`, 원격 업로드, 시크릿 읽기가 포함된 훅은 만들지 않는다
- **timeout 설정** — 오래 걸릴 수 있는 명령은 `"timeout": 30` 추가
- **exit 0 보장** — command 훅이 작업을 막지 않아야 하면 명령 끝에 `; exit 0`
- **중복 확인** — 같은 동작의 훅이 이미 있으면(settings.json 포함) 추가하지 않고 알림
