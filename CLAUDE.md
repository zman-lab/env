# Claude AI를 위한 env 레포지토리 가이드

> **이 파일은 Claude AI가 읽는 문서입니다.**

## 이 레포지토리의 목적

새 Mac에서 개발 환경을 설정하는 도구 모음입니다.
사용자가 `/install-devenv` 스킬을 실행하면 대화형으로 설치를 진행합니다.

## 핵심 흐름

```
1. bootstrap.sh → Xcode, Homebrew, Node, Claude Code 설치
2. 사용자가 claude 실행 후 /install-devenv
3. Claude가 웹 페이지 열기 (setup.html)
4. 사용자가 웹에서 선택 → JSON 다운로드
5. 사용자가 "진행해줘" 하면
6. Claude가 ~/Downloads/env-setup-config.json 읽고 설치 진행
```

## /install-devenv 스킬 실행 시

### 1단계: 설정 페이지 열기

```bash
open ~/env/web/setup.html
```

사용자에게 안내:
```
설정 페이지를 열었어요! 🎉

웹 페이지에서:
1. 설치할 항목 체크
2. 필요한 정보 입력 (Git 이름, 이메일 등)
3. "설치 시작" 버튼 클릭

완료되면 "진행해줘"라고 말해주세요.
```

**여기서 멈추고 사용자 응답 대기**

### 2단계: 사용자가 "진행해줘" 하면

```bash
cat ~/Downloads/env-setup-config.json
```

### 3단계: JSON 파싱 후 설치

config.json 구조:
```json
{
  "items": {
    "java": true,
    "node": true,
    "python": false,
    ...
  },
  "settings": {
    "git": { "name": "...", "email": "..." },
    "dooray": { "apiKey": "..." }
  }
}
```

items에서 true인 것만 순서대로 설치.

## 설치 명령어 레퍼런스

### 아키텍처 감지 (필수)
```bash
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi
```

### java
```bash
curl -s "https://get.sdkman.io?rcupdate=false" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17.0.13-zulu
```

### node
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install 20
nvm alias default 20
```

### python
```bash
brew install pyenv pyenv-virtualenv openssl readline sqlite3 xz zlib tcl-tk
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv install 3.12.0
pyenv global 3.12.0
```

### uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### git
```bash
git config --global user.name "이름"
git config --global user.email "이메일"
```

### ssh
```bash
ssh-keygen -t ed25519 -C "이메일" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```
공개키 출력 후 GitHub 등록 안내

### mcp (Dooray MCP)
```bash
# init 레포 클론
[ ! -d ~/init ] && git clone https://github.com/zman-lab/init.git ~/init

# 의존성 설치
cd ~/init/mcp/dooray-mcp && uv sync

# Claude 설정
mkdir -p ~/.claude
```

~/.claude/settings.json에 MCP 서버 설정 추가:
```json
{
  "mcpServers": {
    "dooray-mcp": {
      "command": "~/init/mcp/dooray-mcp/.venv/bin/python",
      "args": ["~/init/mcp/dooray-mcp/main.py"],
      "env": {
        "DOORAY_API_KEY": "API키"
      }
    }
  }
}
```

### skills (Claude 스킬)
```bash
[ ! -d ~/init ] && git clone https://github.com/zman-lab/init.git ~/init
```

~/.claude/settings.json에 commands 경로 추가

### tools
```bash
brew install bat fzf ripgrep jq tree lsd
```
lsd 실패 시 `brew install eza`로 대체

## 에러 처리

1. 에러 발생 시 사용자에게 알림
2. 자동 해결 시도 (권한, 의존성 등)
3. 해결 안 되면 수동 방법 안내

## 진행 상황 표시

각 항목 설치 시:
```
[1/5] Java 17 설치 중...
[2/5] Node.js 20 설치 중...
...
```

## 파일 구조

```
~/env/
├── bootstrap.sh              # 최소 부트스트랩
├── web/
│   └── setup.html            # 설정 웹 UI
├── claude/
│   └── commands/
│       └── install-devenv.md # 이 스킬
└── docs/
    └── troubleshooting.md
```
