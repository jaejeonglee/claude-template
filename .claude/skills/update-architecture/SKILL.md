---
trigger: manual
description: 프로젝트 구조를 스캔하여 architecture.md를 프로젝트 유형에 맞게 생성/갱신
---

# /update-architecture

사용법: `/update-architecture`

프로젝트를 스캔해 `.claude/docs/architecture.md`를 생성하거나 갱신한다.
**프로젝트 유형에 따라 적절한 섹션을 동적으로 구성**한다. (백엔드/프론트엔드/모바일/ML/CLI 등 무관)

## 실행 절차 (Claude가 수행)

### Step 1. 프로젝트 유형 감지

| 단서 | 추정 유형 |
|---|---|
| `package.json` + `next.config.*` | Next.js 프론트엔드 |
| `package.json` + `react-native` | React Native 모바일 |
| `package.json` + `@nestjs/*` / `fastify` / `express` | Node.js 백엔드 |
| `pubspec.yaml` | Flutter 모바일 |
| `requirements.txt` + `torch` / `tensorflow` | Python ML |
| `requirements.txt` + `fastapi` / `django` / `flask` | Python 백엔드 |
| `go.mod` + `cobra` / `urfave/cli` | Go CLI |
| `go.mod` + `gin` / `echo` / `fiber` | Go 백엔드 |
| `Cargo.toml` | Rust |
| `.github/workflows/`만 있고 앱 코드 없음 | DevOps/Infra |

여러 유형 혼재 (모노레포 등)면 각각의 섹션을 모두 포함.

### Step 2. 유형별 섹션 구성 (백엔드 가정하지 않기)

**백엔드:**
- 기술 스택 (Runtime, Framework, DB)
- API 라우팅 / 엔드포인트
- 서비스/도메인 모듈
- DB 스키마
- 외부 API 의존성
- 데이터 흐름

**프론트엔드:**
- 기술 스택 (Framework, Bundler, State)
- 라우팅 구조
- 상태 관리 전략
- 컴포넌트/디자인 시스템
- API 통신 계층
- 빌드/배포 타겟

**모바일:**
- 기술 스택 + 타겟 플랫폼 (iOS/Android)
- 화면 구조 / 네비게이션
- 네이티브 모듈 의존성
- 권한 / 설정
- 빌드 타겟

**ML/데이터:**
- 기술 스택 (Framework, Tracking)
- 데이터 파이프라인
- 모델 아키텍처
- 실험 관리
- 학습/추론 인프라

**CLI/도구:**
- 기술 스택
- 커맨드 구조
- 설정 파일 형식
- 빌드 타겟

**DevOps/Infra:**
- IaC 도구 (Terraform/CDK/Pulumi)
- 인프라 토폴로지
- CI/CD 파이프라인
- 시크릿 관리

### Step 3. 실제 코드 기반으로 내용 채움

섹션만 만들지 말고 **실제 파일 스캔 결과**로 채운다:

```bash
# 의존성
cat package.json go.mod requirements.txt Cargo.toml pubspec.yaml 2>/dev/null

# 디렉토리 구조
find . -maxdepth 2 -type d -not -path "*/\.*" -not -path "*/node_modules*"

# 주요 설정
ls *.config.* .env.example tsconfig.json 2>/dev/null

# 스키마 파일
find . -name "schema.prisma" -o -name "*.sql" -o -name "*.proto" | head -5

# 라우트/엔드포인트 (있으면)
grep -rE "(router|route|@Get|@Post|app\.)" src/ 2>/dev/null | head -10
```

#### 코드 맵 (프로젝트 유형 무관, 필수 섹션)

"무엇을 찾을 때 어디를 보나"를 **디렉토리(모듈) 수준**으로 정리한다. 파일 단위는 금방 낡으므로 쓰지 않는다 — 디렉토리까지 안내하면 그 안은 `ls`/`grep`으로 찾는다.

```markdown
## 코드 맵

| 찾는 것 | 위치 | 비고 |
|---|---|---|
| 인증/세션 | `src/middleware/auth/` | JWT 검증 |
| 결제 도메인 | `src/services/payment/` | PG 연동 포함 |
| DB 접근 | `src/repositories/` | 도메인별 1파일 |

### 배치 규칙 (새 코드는 어디에)

- 새 도메인 모듈 → `src/services/<도메인>/`
- 공용 유틸 → `src/lib/`
- 새 엔드포인트 → 해당 도메인의 `routes.ts`
```

배치 규칙은 기존 코드의 실제 패턴에서 도출한다 (희망사항 금지). 프로젝트가 크면서 새 모듈이 생기면 이 표에 행이 추가되는 구조다.

### Step 4. 기존 내용과 비교

architecture.md에 이미 내용이 있으면:
1. 기존 섹션과 새로 감지한 내용 diff
2. 사용자에게 변경사항 요약
3. 확정 후 갱신

처음이면 바로 작성.

### Step 5. conventions.md 정합성 스캔

주간 감사의 일부로 `conventions.md`도 훑는다:

- **중복** — 같은 취지의 규칙이 두 번 이상 (예: 날짜만 다른 동일 규칙)
- **모순** — 서로 충돌하는 규칙 (예: "camelCase 사용" vs "snake_case 사용")
- **죽은 규칙** — 참조하는 파일·도구·라이브러리가 코드에서 사라짐

발견하면 **정리안을 사용자에게 제안**한다. 자동 삭제 금지 — 규칙 제거는 사람이 결정한다.

### Step 6. 감사 타이머 갱신

변경 유무와 무관하게 실행 (변경 없음도 유효한 감사 결과):

```bash
touch .claude/.last-arch-audit
```

SessionStart 훅이 이 파일의 시각으로 주간 감사 기한을 판단한다.

### Step 7. 보고

```
architecture.md [생성/갱신/변경 없음] — 감사 완료

감지된 프로젝트 유형: [유형]
주요 변경:
- 추가: ...
- 갱신: ...
conventions 정합성: [문제 없음 / 정리 제안 N건]
```

## 주의사항

- **추측 금지** — 파일에서 확인되지 않는 것은 "확인 필요" 표시
- **프로젝트 유형에 안 맞는 섹션 넣지 않기** — 예: 프론트에 "DB 스키마" 섹션 X
- **최소주의** — 의미 없는 섹션 생략
- **다이어그램은 텍스트로** — ASCII 또는 mermaid
