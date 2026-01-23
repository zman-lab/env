# Mac 개발 환경 설정

새 맥북에서 개발 환경 **원클릭** 자동 설정.

## 설정 방법

### 1. 터미널 열기

`⌘ + Space` → `terminal` 입력 → Enter

### 2. 아래 명령어 복사해서 붙여넣기

```bash
curl -fsSL https://raw.githubusercontent.com/zman-lab/env/main/bootstrap.sh | bash
```

### 3. Claude 실행

```bash
claude
```

### 4. Claude에게 말하기

```
/install-devenv
```

### 5. 웹에서 선택하면 끝!

Claude가 웹 페이지를 열어줍니다. 원하는 항목 체크하고 "설치 시작" 누르면 자동 설치!

---

## 부트스트랩에서 설치되는 것

| 도구 | 용도 |
|------|------|
| Xcode CLI | 기본 개발 도구 |
| Homebrew | 패키지 관리자 |
| Node.js | Claude Code 실행용 |
| Claude Code | AI 개발 도우미 |

## /install-devenv에서 선택 가능한 것

| 항목 | 설명 |
|------|------|
| Java 17 | SDKMAN + Zulu JDK |
| Node.js 20 | nvm + LTS |
| Python 3.12 | pyenv |
| Git 설정 | 이름, 이메일 |
| SSH 키 | GitHub 연동 |
| Dooray MCP | 두레이 API 연동 |
| Claude 스킬 | /do, /wiki 등 |
| 기타 도구 | bat, fzf, ripgrep 등 |

---

## 문제가 생기면?

Claude에게 물어보세요. 에러가 나도 Claude가 해결해줍니다.

또는 [docs/troubleshooting.md](docs/troubleshooting.md) 참고
