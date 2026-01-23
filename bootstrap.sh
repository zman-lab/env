#!/bin/bash
#
# Mac 개발 환경 부트스트랩
# 새 맥북에서 터미널 열고 이것만 실행하면 됩니다.
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/zman-lab/env/main/bootstrap.sh | bash
#

set -e

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Mac 개발 환경 설정 시작"
echo "=========================================="
echo ""

# ============================================================
# 1단계: Xcode Command Line Tools 설치
# ============================================================
echo -e "${BLUE}[1/4]${NC} Xcode Command Line Tools 확인 중..."

if xcode-select -p &>/dev/null; then
    echo -e "${GREEN}✓${NC} 이미 설치됨"
else
    echo -e "${YELLOW}→${NC} 설치가 필요합니다. 팝업 창에서 '설치' 버튼을 클릭해주세요."
    xcode-select --install

    echo ""
    echo "============================================"
    echo "  팝업 창에서 '설치' 버튼을 클릭하세요!"
    echo "  설치가 완료되면 Enter를 눌러주세요."
    echo "============================================"
    echo ""
    read -r

    # 설치 확인
    if ! xcode-select -p &>/dev/null; then
        echo -e "${RED}✗${NC} Xcode CLI 설치가 완료되지 않았습니다."
        echo "  다시 시도해주세요: xcode-select --install"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} 설치 완료"
fi

# ============================================================
# 2단계: 레포지토리 다운로드
# ============================================================
echo ""
echo -e "${BLUE}[2/4]${NC} 설정 파일 다운로드 중..."

ENV_DIR="$HOME/env"

if [ -d "$ENV_DIR" ]; then
    echo -e "${YELLOW}→${NC} 기존 ~/env 폴더가 있습니다. 업데이트 중..."
    cd "$ENV_DIR"
    git pull origin main 2>/dev/null || true
else
    # HTTPS로 클론 (인증 불필요)
    git clone https://github.com/zman-lab/env.git "$ENV_DIR"
fi

echo -e "${GREEN}✓${NC} 다운로드 완료: ~/env"

# ============================================================
# 3단계: 설치 스크립트 실행
# ============================================================
echo ""
echo -e "${BLUE}[3/4]${NC} 설치 스크립트 실행 중..."

cd "$ENV_DIR"
chmod +x setup.sh
./setup.sh

# ============================================================
# 4단계: 완료
# ============================================================
echo ""
echo -e "${BLUE}[4/4]${NC} 부트스트랩 완료!"
echo ""
