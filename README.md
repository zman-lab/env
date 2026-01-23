# Mac 개발 환경 설정

새 Mac에서 개발 환경을 자동으로 설정합니다.

## 지원 환경

- ✅ Apple Silicon (M1/M2/M3/M4)
- ✅ Intel Mac

## 설정 방법 (3단계)

### 1. 터미널 열기
Spotlight (⌘ + Space) → "Terminal" 입력 → Enter

### 2. 이 저장소 클론
```bash
git clone git@github.com:zman-lab/env.git ~/env
```

> SSH 키가 없으면 HTTPS 사용:
> ```bash
> git clone https://github.com/zman-lab/env.git ~/env
> ```

### 3. 설치 스크립트 실행
```bash
cd ~/env && chmod +x setup.sh && ./setup.sh
```

## 설치되는 것들

| 카테고리 | 도구 |
|---------|------|
| 패키지 관리 | Homebrew |
| 기본 도구 | git, zsh, bat, fzf, ripgrep, jq, tree, wget, curl |
| 터미널 | lsd (또는 eza) |
| Java | SDKMAN |
| Node.js | nvm |
| Python | pyenv, uv |

## 설치 후 수동 작업

스크립트 완료 후 아래 작업이 필요합니다:

1. **새 터미널 열기** (설정 적용)
2. **개발 도구 버전 설치**
   ```bash
   sdk install java 17.0.9-zulu
   nvm install 20
   pyenv install 3.12.0
   ```
3. **Git 설정** (`~/.gitconfig`에서 name, email 수정)
4. **GitHub SSH 키 등록** (docs/manual-steps.md 참조)

## 문제 해결

자세한 내용은 [docs/troubleshooting.md](docs/troubleshooting.md) 참조

## 파일 구조

```
env/
├── setup.sh           # 메인 설치 스크립트
├── configs/           # 설정 파일 템플릿
│   ├── shell/         # .zshrc, .zprofile
│   ├── git/           # .gitconfig
│   └── ssh/           # SSH 설정
├── docs/              # 문서
└── CLAUDE.md          # Claude AI용 가이드
```
