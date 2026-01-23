# 수동 설정 단계

setup.sh로 자동화할 수 없는 작업들입니다.

## 1. 새 터미널 열기

설정 적용을 위해 **반드시** 새 터미널을 열어야 합니다.

또는:
```bash
source ~/.zshrc
```

## 2. 개발 도구 버전 설치

### Java (SDKMAN)
```bash
# 사용 가능한 버전 확인
sdk list java

# Java 17 설치 (권장)
sdk install java 17.0.9-zulu

# Java 11 설치 (필요한 경우)
sdk install java 11.0.21-zulu

# 기본 버전 설정
sdk default java 17.0.9-zulu
```

### Node.js (nvm)
```bash
# 사용 가능한 버전 확인
nvm ls-remote --lts

# Node.js 20 LTS 설치
nvm install 20

# 기본 버전 설정
nvm alias default 20
```

### Python (pyenv)
```bash
# 사용 가능한 버전 확인
pyenv install --list | grep "3.12"

# Python 3.12 설치
pyenv install 3.12.0

# 전역 버전 설정
pyenv global 3.12.0
```

## 3. Git 설정

`~/.gitconfig` 파일에서 사용자 정보 수정:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 4. SSH 키 생성 및 GitHub 등록

### SSH 키 생성
```bash
# Ed25519 키 생성 (권장)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Enter 3번 (기본 경로, 비밀번호 없음)
```

### SSH 에이전트에 키 추가
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### GitHub에 공개키 등록
```bash
# 공개키 복사
cat ~/.ssh/id_ed25519.pub | pbcopy
```

1. https://github.com/settings/keys 접속
2. "New SSH key" 클릭
3. Title: "My Mac" (또는 원하는 이름)
4. Key: 붙여넣기 (⌘+V)
5. "Add SSH key" 클릭

### 연결 테스트
```bash
ssh -T git@github.com
# "Hi username! You've successfully authenticated..." 메시지 확인
```

## 5. IDE 설치

### IntelliJ IDEA
```bash
brew install --cask intellij-idea
```

### Visual Studio Code
```bash
brew install --cask visual-studio-code
```

### 또는 JetBrains Toolbox (권장)
```bash
brew install --cask jetbrains-toolbox
```

## 6. 회사 관련 설정 (해당 시)

### VPN 설정
회사 IT 부서 가이드 참조

### 사내 레포지토리 접근
- 사내 Git 서버 SSH 키 등록
- 방화벽/프록시 설정

### Dooray MCP (두레이 사용자)
1. Dooray API 키 발급: https://nhnent.dooray.com → 설정 → API 키 관리
2. `~/.claude/settings.json`에 API 키 설정

## 7. 작업 디렉토리 구성

```bash
mkdir -p ~/work
cd ~/work

# 필요한 레포지토리 클론
git clone git@github.com:your-org/your-project.git
```
