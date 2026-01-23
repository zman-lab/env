# 개발 환경 설치 스킬

Mac 개발 환경을 대화형으로 설치합니다.

## 실행 흐름

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

### 2단계: 사용자가 "진행해줘" 하면

설정 파일 읽기:
```bash
cat ~/Downloads/env-setup-config.json
```

### 3단계: JSON 파싱 후 선택된 항목 설치

config.items에서 true인 항목만 순서대로 설치:

#### java (SDKMAN + Java 17)
```bash
# SDKMAN 설치
curl -s "https://get.sdkman.io?rcupdate=false" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Java 17 설치
sdk install java 17.0.13-zulu
```

#### node (nvm + Node.js 20)
```bash
# nvm 설치
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

# Node.js 20 설치
nvm install 20
nvm alias default 20
```

#### python (pyenv + Python 3.12)
```bash
# pyenv 설치
brew install pyenv pyenv-virtualenv

# Python 빌드 의존성
brew install openssl readline sqlite3 xz zlib tcl-tk

# pyenv 초기화
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Python 3.12 설치
pyenv install 3.12.0
pyenv global 3.12.0
```

#### uv (Python 패키지 관리자)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### git (Git 설정)
config.settings.git에서 name, email 읽어서:
```bash
git config --global user.name "이름"
git config --global user.email "이메일"
```

#### ssh (SSH 키 생성)
```bash
ssh-keygen -t ed25519 -C "이메일" -f ~/.ssh/id_ed25519 -N ""
```
생성 후 공개키 출력하고 GitHub 등록 안내

#### mcp (Dooray MCP)
```bash
# init 레포 클론 (없으면)
if [ ! -d ~/init ]; then
    git clone https://github.com/zman-lab/init.git ~/init
fi

# dooray-mcp 의존성 설치
cd ~/init/mcp/dooray-mcp
uv sync

# Claude 설정 디렉토리
mkdir -p ~/.claude

# settings.json 생성/업데이트
```

config.settings.dooray.apiKey로 API 키 설정

#### skills (Claude 스킬)
```bash
# init 레포 클론 (없으면)
if [ ! -d ~/init ]; then
    git clone https://github.com/zman-lab/init.git ~/init
fi

# 스킬 심볼릭 링크 또는 복사
```

#### tools (기타 도구)
```bash
brew install bat fzf ripgrep jq tree lsd
```

### 4단계: 완료 안내

```
✅ 설치 완료!

설치된 항목:
- Java 17 (SDKMAN)
- Node.js 20 (nvm)
- ...

터미널을 닫고 다시 열면 모든 설정이 적용됩니다.
```

## 에러 처리

설치 중 에러 발생 시:
1. 에러 내용 사용자에게 알림
2. 자동 해결 시도 (권한 문제, 의존성 등)
3. 해결 안 되면 수동 해결 방법 안내

## 주의사항

- 각 단계마다 진행 상황 알려주기
- 시간 오래 걸리는 작업 (Python 빌드 등) 미리 안내
- 이미 설치된 항목은 건너뛰기
