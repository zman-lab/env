#!/bin/bash
#
# Mac 개발 환경 부트스트랩 (최소 버전)
# Claude Code 설치까지만 - 나머지는 Claude가 진행
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/zman-lab/env/main/bootstrap.sh | bash
#

set -e

# 색상
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Mac 개발 환경 부트스트랩"
echo "=========================================="
echo ""

# ============================================================
# 1. Xcode Command Line Tools
# ============================================================
echo -e "${BLUE}[1/4]${NC} Xcode Command Line Tools 확인 중..."

if xcode-select -p &>/dev/null; then
    echo -e "${GREEN}✓${NC} 이미 설치됨"
else
    echo -e "${YELLOW}→${NC} 설치가 필요합니다."
    xcode-select --install

    echo ""
    echo "============================================"
    echo "  팝업 창에서 '설치' 버튼을 클릭하세요!"
    echo "  설치가 완료되면 Enter를 눌러주세요."
    echo "============================================"
    echo ""
    read -r

    if ! xcode-select -p &>/dev/null; then
        echo "Xcode CLI 설치가 완료되지 않았습니다. 다시 시도해주세요."
        exit 1
    fi
    echo -e "${GREEN}✓${NC} 설치 완료"
fi

# ============================================================
# 2. Homebrew
# ============================================================
echo ""
echo -e "${BLUE}[2/4]${NC} Homebrew 확인 중..."

# 아키텍처 감지
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

if command -v brew &>/dev/null; then
    echo -e "${GREEN}✓${NC} 이미 설치됨"
else
    echo -e "${YELLOW}→${NC} Homebrew 설치 중..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # PATH 설정
    eval "$($BREW_PREFIX/bin/brew shellenv)"
    echo -e "${GREEN}✓${NC} 설치 완료"
fi

# 현재 세션에서 brew 사용
eval "$($BREW_PREFIX/bin/brew shellenv)"

# ============================================================
# 3. Node.js (Claude Code 설치용)
# ============================================================
echo ""
echo -e "${BLUE}[3/4]${NC} Node.js 확인 중..."

if command -v node &>/dev/null; then
    echo -e "${GREEN}✓${NC} 이미 설치됨: $(node -v)"
else
    echo -e "${YELLOW}→${NC} Node.js 설치 중..."
    brew install node
    echo -e "${GREEN}✓${NC} 설치 완료"
fi

# ============================================================
# 4. Claude Code
# ============================================================
echo ""
echo -e "${BLUE}[4/4]${NC} Claude Code 확인 중..."

if command -v claude &>/dev/null; then
    echo -e "${GREEN}✓${NC} 이미 설치됨"
else
    echo -e "${YELLOW}→${NC} Claude Code 설치 중..."
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓${NC} 설치 완료"
fi

# ============================================================
# 5. env 레포 다운로드
# ============================================================
echo ""
echo -e "${BLUE}[+]${NC} 설정 파일 다운로드 중..."

ENV_DIR="$HOME/env"
if [ -d "$ENV_DIR" ]; then
    cd "$ENV_DIR" && git pull origin main 2>/dev/null || true
else
    git clone https://github.com/zman-lab/env.git "$ENV_DIR"
fi
echo -e "${GREEN}✓${NC} 완료: ~/env"

# ============================================================
# 완료!
# ============================================================
echo ""
echo "=========================================="
echo -e "${GREEN}  부트스트랩 완료!${NC}"
echo "=========================================="
echo ""
echo "다음 단계:"
echo ""
echo "  1. 터미널에서 아래 명령어 실행:"
echo ""
echo "     claude"
echo ""
echo "  2. Claude에게 말하기:"
echo ""
echo "     /install-devenv"
echo ""
echo "  3. Claude가 웹 페이지를 열어줄 거예요."
echo "     거기서 원하는 항목 선택하면 끝!"
echo ""
