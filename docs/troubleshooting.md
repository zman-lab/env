# 문제 해결 가이드

## 아키텍처별 문제

### Apple Silicon (M1/M2/M3/M4)

#### Rosetta 2 필요한 앱
일부 앱이 Intel 전용인 경우:
```bash
softwareupdate --install-rosetta
```

#### Intel 모드로 명령어 실행
```bash
arch -x86_64 /bin/bash
```

### Intel Mac

#### lsd 설치 실패
glibc 호환성 문제로 lsd가 설치되지 않을 수 있습니다.

**해결책**: eza 사용 (자동으로 대체됨)
```bash
brew install eza
```

.zshrc에서 자동으로 eza 사용

#### Homebrew 경로
Intel Mac의 Homebrew 경로는 `/usr/local`입니다.
```bash
# 확인
brew --prefix
# /usr/local 이어야 함
```

## 공통 문제

### Xcode Command Line Tools

#### 설치 팝업이 안 뜸
```bash
xcode-select --install
```

#### 이미 설치되었는데 오류
```bash
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

### Homebrew

#### 권한 문제
```bash
sudo chown -R $(whoami) $(brew --prefix)/*
```

#### 업데이트 실패
```bash
brew update-reset
```

### SDKMAN

#### curl/zip 없음
```bash
brew install curl zip unzip
```

#### 설치 스크립트 실패
수동 설치:
```bash
curl -s "https://get.sdkman.io" | bash
```

### Git

#### SSH 연결 실패
```bash
# SSH 키 확인
ls -la ~/.ssh/

# SSH 에이전트 시작
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# GitHub 연결 테스트
ssh -T git@github.com
```

### Python (pyenv)

#### 빌드 실패
빌드 의존성 설치:
```bash
brew install openssl readline sqlite3 xz zlib tcl-tk
```

환경 변수 설정:
```bash
export LDFLAGS="-L$(brew --prefix openssl)/lib"
export CPPFLAGS="-I$(brew --prefix openssl)/include"
```

### Node.js (nvm)

#### nvm 명령어 없음
새 터미널 열거나:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

## 로그 확인

설치 로그는 `~/env/setup.log`에 기록됩니다:
```bash
cat ~/env/setup.log
```

## 설정 백업 복원

setup.sh는 기존 설정 파일을 백업합니다:
```bash
# 백업 파일 확인
ls -la ~/.zshrc.backup.*
ls -la ~/.zprofile.backup.*

# 복원 (예시)
cp ~/.zshrc.backup.20260123120000 ~/.zshrc
```
