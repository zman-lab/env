# Mac 개발 환경 설정

새 맥북 샀을 때 개발 환경 자동 설정.

## 설정 방법 (2단계)

### 1단계: 터미널 열기

키보드에서 `⌘ + Space` 누르고 → `terminal` 입력 → Enter

### 2단계: 아래 명령어 복사해서 붙여넣기

```bash
curl -fsSL https://raw.githubusercontent.com/zman-lab/env/main/bootstrap.sh | bash
```

> 복사: 위 명령어 드래그 후 `⌘ + C`
> 붙여넣기: 터미널에서 `⌘ + V` 후 Enter

**끝!** 나머지는 자동으로 진행됩니다.

---

## 진행 중 할 일

1. **Xcode 설치 팝업** → "설치" 버튼 클릭
2. 설치 끝나면 → Enter 키 누르기
3. 나머지는 자동

---

## 설치 완료 후

터미널 닫고 다시 열기, 그 다음:

```bash
# Java 설치
sdk install java 17.0.9-zulu

# Node.js 설치
nvm install 20

# Python 설치
pyenv install 3.12.0
```

---

## 뭐가 설치되나요?

| 도구 | 용도 |
|------|------|
| Homebrew | Mac 패키지 관리자 |
| git | 코드 버전 관리 |
| SDKMAN | Java 버전 관리 |
| nvm | Node.js 버전 관리 |
| pyenv | Python 버전 관리 |
| 기타 | bat, fzf, ripgrep, jq 등 |

---

## 문제가 생기면?

[docs/troubleshooting.md](docs/troubleshooting.md) 참고
