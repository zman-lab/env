# Mac 개발 환경 설정

새 맥북 샀을 때 개발 환경 **원클릭** 자동 설정.

## 설정 방법

### 1단계: 터미널 열기

키보드에서 `⌘ + Space` 누르고 → `terminal` 입력 → Enter

### 2단계: 아래 명령어 복사해서 붙여넣기

```bash
curl -fsSL https://raw.githubusercontent.com/zman-lab/env/main/bootstrap.sh | bash
```

**끝!** Java, Node.js, Python까지 전부 자동으로 설치됩니다.

---

## 진행 중 할 일

1. **Xcode 설치 팝업** → "설치" 버튼 클릭
2. 설치 끝나면 → Enter 키 누르기
3. 나머지는 **전부 자동** (10~20분 소요)

---

## 자동으로 설치되는 것

| 도구 | 버전 | 용도 |
|------|------|------|
| Homebrew | 최신 | Mac 패키지 관리자 |
| Java | 17 (Zulu) | JVM 개발 |
| Node.js | 20 LTS | JavaScript 런타임 |
| Python | 3.12 | Python 개발 |
| 기타 | - | git, bat, fzf, ripgrep, jq 등 |

---

## 설치 완료 후 (수동)

터미널 닫고 다시 연 뒤:

### 1. Git 사용자 정보 설정
```bash
git config --global user.name "내 이름"
git config --global user.email "my@email.com"
```

### 2. GitHub SSH 키 등록 (선택)
```bash
ssh-keygen -t ed25519 -C "my@email.com"
cat ~/.ssh/id_ed25519.pub | pbcopy
```
→ https://github.com/settings/keys 에서 등록

---

## 문제가 생기면?

[docs/troubleshooting.md](docs/troubleshooting.md) 참고
