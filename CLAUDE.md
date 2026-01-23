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
2. 필요한 정보 입력 (Git 이름, 이메일, MCP 접속 정보 등)
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
    "anthropic-skills": true,
    "mcp-dooray": true,
    "mcp-es-alpha": true,
    "mcp-mysql-alpha": true,
    ...
  },
  "settings": {
    "git": { "name": "...", "email": "..." },
    "dooray": { "apiKey": "..." },
    "es-alpha": { "host": "..." },
    "es-real": { "host": "...", "username": "...", "password": "..." },
    "mysql-alpha": { "host": "...", "port": "...", "user": "...", "password": "...", "database": "..." },
    "mysql-dev": { ... },
    "mysql-real": { ... }
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
**Java 11 + 17 둘 다 필요** (hangame-poker-server는 11, GIA/betting_base는 17)

```bash
curl -s "https://get.sdkman.io?rcupdate=false" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Eclipse Temurin (무료, 상용 가능)
sdk install java 11.0.25-tem
sdk install java 17.0.13-tem
sdk default java 17.0.13-tem
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

### tools
```bash
brew install bat fzf ripgrep jq tree lsd
```
lsd 실패 시 `brew install eza`로 대체

---

## 스킬 설치 구조

**핵심 구조:**
```
~/.claude/commands/ → ~/init/claude/commands/ (심볼릭 링크)

~/init/claude/commands/
├── do.md, wiki.md, build-*.md  (커스텀 스킬 - git 관리)
├── docx.md → ~/anthropic-skills/skills/docx/SKILL.md (Anthropic 스킬 링크)
└── ...
```

**장점:**
- `~/init` push/pull → 커스텀 스킬 동기화
- `~/anthropic-skills` pull → Anthropic 스킬 업데이트

---

## Anthropic 스킬 설치 (anthropic-skills)

**강력 권장 항목** - GitHub에서 최신 버전 설치:

```bash
# Anthropic 스킬 레포 클론/업데이트
if [ -d ~/anthropic-skills ]; then
    cd ~/anthropic-skills && git pull origin main
else
    git clone https://github.com/anthropics/skills.git ~/anthropic-skills
fi
```

그 다음 ~/init/claude/commands/에 심볼릭 링크 생성:
```bash
cd ~/init/claude/commands

# Anthropic 스킬 심볼릭 링크 생성
for skill in docx xlsx pptx pdf canvas-design frontend-design algorithmic-art \
             brand-guidelines theme-factory mcp-builder webapp-testing \
             skill-creator web-artifacts-builder internal-comms doc-coauthoring slack-gif-creator; do
    [ -f "$skill.md" ] || ln -s ~/anthropic-skills/skills/$skill/SKILL.md $skill.md
done
```

포함 스킬: /docx, /xlsx, /pptx, /pdf, /canvas-design, /frontend-design, /algorithmic-art, /brand-guidelines, /theme-factory, /mcp-builder, /webapp-testing, /skill-creator, /web-artifacts-builder, /internal-comms, /doc-coauthoring, /slack-gif-creator

---

## 커스텀 스킬 설치

```bash
# init 레포 클론 (커스텀 스킬 + MCP 포함)
[ ! -d ~/init ] && git clone https://github.com/zman-lab/init.git ~/init

# ~/.claude/commands를 ~/init/claude/commands로 심볼릭 링크
mkdir -p ~/.claude
[ -L ~/.claude/commands ] || ln -s ~/init/claude/commands ~/.claude/commands
```

```

---

## MCP 서버 설치

### 설정 불필요 (자동 설치)

#### mcp-context7
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

#### mcp-pptx
```json
{
  "mcpServers": {
    "pptx": {
      "command": "uvx",
      "args": ["--from", "office-powerpoint-mcp-server", "ppt_mcp_server"]
    }
  }
}
```

#### mcp-thinking
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

### 설정 필요

#### mcp-dooray (Dooray MCP)
```bash
# init 레포 클론
[ ! -d ~/init ] && git clone https://github.com/zman-lab/init.git ~/init

# 의존성 설치
cd ~/init/mcp/dooray-mcp && uv sync
```

settings.json:
```json
{
  "mcpServers": {
    "dooray-mcp": {
      "command": "~/init/mcp/dooray-mcp/.venv/bin/python",
      "args": ["~/init/mcp/dooray-mcp/main.py"],
      "env": {
        "DOORAY_API_KEY": "{settings.dooray.apiKey}",
        "DOORAY_BASE_URL": "https://api.dooray.com"
      }
    }
  }
}
```

#### mcp-es-alpha (Elasticsearch Alpha)
```bash
# elasticsearch-mcp-server 설치
uv tool install elasticsearch-mcp-server
```

settings.json:
```json
{
  "mcpServers": {
    "elasticsearch-alpha": {
      "command": "~/.local/bin/elasticsearch-mcp-server",
      "args": [],
      "env": {
        "ELASTICSEARCH_HOST": "{settings.es-alpha.host}"
      }
    }
  }
}
```

#### mcp-es-real (Elasticsearch Real)
```bash
uv tool install elasticsearch-mcp-server
```

settings.json:
```json
{
  "mcpServers": {
    "elasticsearch-real": {
      "command": "~/.local/bin/elasticsearch-mcp-server",
      "args": [],
      "env": {
        "ELASTICSEARCH_HOST": "{settings.es-real.host}",
        "ELASTICSEARCH_USERNAME": "{settings.es-real.username}",
        "ELASTICSEARCH_PASSWORD": "{settings.es-real.password}"
      }
    }
  }
}
```

#### mcp-mysql-* (MySQL)
```bash
# mysql-mcp-server 설치
uv tool install mysql-mcp-server
```

settings.json (mysql-alpha 예시):
```json
{
  "mcpServers": {
    "mysql-alpha-game": {
      "command": "~/.local/bin/mysql_mcp_server",
      "args": [],
      "env": {
        "MYSQL_HOST": "{settings.mysql-alpha.host}",
        "MYSQL_PORT": "{settings.mysql-alpha.port}",
        "MYSQL_USER": "{settings.mysql-alpha.user}",
        "MYSQL_PASSWORD": "{settings.mysql-alpha.password}",
        "MYSQL_DATABASE": "{settings.mysql-alpha.database}"
      }
    }
  }
}
```

mysql-dev, mysql-real도 동일한 방식으로 설정 (settings에서 값 참조)

---

## settings.json 병합 전략

기존 ~/.claude/settings.json이 있으면:
1. 기존 파일 읽기
2. mcpServers, commands 배열에 새 항목 추가 (중복 방지)
3. 기존 설정 유지

없으면 새로 생성.

---

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
