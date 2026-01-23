# Claude AI를 위한 env 레포지토리 가이드

> **이 파일은 Claude AI가 읽는 문서입니다. 사용자가 새 Mac 설정을 요청하면 이 가이드를 따르세요.**

## 이 레포지토리의 목적

새 Mac에서 개발 환경을 자동으로 설정하는 스크립트와 설정 파일 모음입니다.

## 핵심 규칙 (절대 준수)

### 1. 아키텍처 자동 감지
```bash
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi
```
- **arm64**: Apple Silicon (M1/M2/M3/M4) → Homebrew: `/opt/homebrew`
- **x86_64**: Intel Mac → Homebrew: `/usr/local`
- **절대 하드코딩 금지**: 항상 `$BREW_PREFIX` 변수 사용

### 2. 설치 순서 (순서 변경 금지)
1. Xcode Command Line Tools
2. Homebrew
3. 기본 패키지 (git, zsh 등)
4. 개발 도구 (sdkman, nvm, pyenv 등)
5. 설정 파일 복사

### 3. 에러 처리
- 각 단계에서 실패하면 **즉시 중단**
- 사용자에게 에러 내용 알리고 수동 해결 요청
- 자동으로 우회하거나 무시하지 말 것

## 파일 구조

```
env/
├── CLAUDE.md              # ← 지금 읽고 있는 파일
├── README.md              # 사람용 가이드 (2단계)
├── bootstrap.sh           # ★ 새 맥북용 시작점 (curl로 실행)
├── setup.sh               # 메인 설치 스크립트
├── configs/
│   ├── shell/
│   │   ├── zshrc.template     # {{BREW_PREFIX}} 포함
│   │   └── zprofile.template
│   ├── git/
│   │   └── gitconfig.template
│   └── ssh/
│       └── config.template
├── mcp/
│   └── .mcp.json.template # MCP 서버 설정 템플릿
└── docs/
    ├── troubleshooting.md # 문제 해결 가이드
    └── manual-steps.md    # 자동화 불가능한 단계
```

## setup.sh 동작 방식

### 자동으로 하는 것
- [x] Xcode CLI 설치 확인/설치
- [x] Homebrew 설치
- [x] 기본 패키지 설치 (git, zsh, lsd, bat, fzf, ripgrep 등)
- [x] SDKMAN 설치 (Java 관리)
- [x] nvm 설치 (Node.js 관리)
- [x] pyenv 설치 (Python 관리)
- [x] uv 설치 (Python 패키지 관리)
- [x] 설정 파일 복사 (백업 후)

### 자동화 불가능 (수동 필요)
- [ ] GitHub SSH 키 등록
- [ ] Dooray API 키 발급 및 설정
- [ ] IDE 설치 (IntelliJ, VS Code)
- [ ] 회사 VPN 설정

## 사용자가 "새 Mac 설정해줘"라고 하면

### 중요: 새 맥북에는 git이 없음!

새 맥북은 터미널만 있고 git, brew 등 아무것도 없습니다.
**절대 `git clone`부터 시작하지 마세요.**

### 안내할 명령어 (이것만 복사해서 주세요)

```bash
curl -fsSL https://raw.githubusercontent.com/zman-lab/env/main/bootstrap.sh | bash
```

### 사용자에게 안내할 단계

1. **터미널 열기**: `⌘ + Space` → "terminal" 입력 → Enter
2. **위 명령어 복사해서 붙여넣기** 후 Enter
3. **Xcode 설치 팝업 뜨면** → "설치" 버튼 클릭
4. **설치 완료되면** → Enter 키 누르기
5. **나머지는 자동**

### bootstrap.sh가 하는 일

1. Xcode Command Line Tools 설치 (git 포함)
2. 이 레포지토리 clone (HTTPS, 인증 불필요)
3. setup.sh 실행

### 설치 완료 후 수동 단계

docs/manual-steps.md 참조:
- Java/Node/Python 버전 설치
- Git 사용자 정보 설정
- SSH 키 생성 및 GitHub 등록

## 트러블슈팅

### Intel Mac 특이사항
- `lsd`가 glibc 문제로 설치 실패할 수 있음 → `exa` 또는 `eza`로 대체
- Homebrew 경로가 `/usr/local`임을 확인

### Apple Silicon 특이사항
- Rosetta 2 필요한 앱 있을 수 있음
- `arch -x86_64` 명령어로 Intel 모드 실행 가능

### 공통 문제
- **Xcode 설치 안됨**: `xcode-select --install` 수동 실행
- **Homebrew 권한 문제**: `sudo chown -R $(whoami) $BREW_PREFIX`
- **SDKMAN 설치 실패**: curl/zip 먼저 설치 확인

## 설정 파일 템플릿 규칙

### 변수 치환
템플릿 파일의 `{{변수명}}`은 setup.sh에서 실제 값으로 치환됩니다:

| 변수 | 값 (Apple Silicon) | 값 (Intel) |
|------|-------------------|------------|
| `{{BREW_PREFIX}}` | `/opt/homebrew` | `/usr/local` |
| `{{USER}}` | 실행 사용자명 | 실행 사용자명 |
| `{{HOME}}` | 사용자 홈 디렉토리 | 사용자 홈 디렉토리 |

### 예시
```bash
# 템플릿 (zshrc.template)
export PATH="{{BREW_PREFIX}}/bin:$PATH"

# 치환 후 (.zshrc) - Apple Silicon
export PATH="/opt/homebrew/bin:$PATH"
```

## 주의사항

1. **기존 설정 백업**: 덮어쓰기 전 반드시 `.backup` 파일 생성
2. **idempotent**: 스크립트는 여러 번 실행해도 안전해야 함
3. **에러 로깅**: 모든 에러는 `~/env/setup.log`에 기록
4. **대화형 입력 최소화**: 가능하면 기본값 사용, 불가피한 경우만 묻기

## 관련 레포지토리

- **init** (기존): https://github.com/zman-lab/init
  - 더 많은 설정과 스킬 포함
  - 이 env 레포는 init의 핵심만 추출한 것

- **dooray-mcp**: init/mcp/dooray-mcp
  - 두레이 API MCP 서버
