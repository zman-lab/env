#!/bin/bash
#
# Mac 개발 환경 설정 스크립트
# Apple Silicon / Intel Mac 자동 감지
#
# 사용법: ./setup.sh
#

set -e  # 에러 발생 시 즉시 중단

# ============================================================
# 색상 정의
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# 로깅 함수
# ============================================================
LOG_FILE="$HOME/env/setup.log"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

# ============================================================
# 아키텍처 감지
# ============================================================
detect_architecture() {
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        BREW_PREFIX="/opt/homebrew"
        ARCH_NAME="Apple Silicon"
    elif [ "$ARCH" = "x86_64" ]; then
        BREW_PREFIX="/usr/local"
        ARCH_NAME="Intel"
    else
        log_error "지원하지 않는 아키텍처: $ARCH"
        exit 1
    fi

    log_info "아키텍처 감지: $ARCH_NAME ($ARCH)"
    log_info "Homebrew 경로: $BREW_PREFIX"
}

# ============================================================
# Xcode Command Line Tools 설치
# ============================================================
install_xcode_cli() {
    log_info "Xcode Command Line Tools 확인 중..."

    if xcode-select -p &>/dev/null; then
        log_success "Xcode CLI 이미 설치됨"
    else
        log_info "Xcode CLI 설치 중... (팝업에서 '설치' 클릭)"
        xcode-select --install

        # 설치 완료 대기
        echo "설치가 완료되면 Enter를 눌러주세요..."
        read -r

        if xcode-select -p &>/dev/null; then
            log_success "Xcode CLI 설치 완료"
        else
            log_error "Xcode CLI 설치 실패. 수동으로 설치해주세요."
            exit 1
        fi
    fi
}

# ============================================================
# Homebrew 설치
# ============================================================
install_homebrew() {
    log_info "Homebrew 확인 중..."

    if command -v brew &>/dev/null; then
        log_success "Homebrew 이미 설치됨: $(brew --version | head -1)"
    else
        log_info "Homebrew 설치 중..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # PATH에 추가 (현재 세션)
        eval "$($BREW_PREFIX/bin/brew shellenv)"

        if command -v brew &>/dev/null; then
            log_success "Homebrew 설치 완료"
        else
            log_error "Homebrew 설치 실패"
            exit 1
        fi
    fi
}

# ============================================================
# 기본 패키지 설치
# ============================================================
install_base_packages() {
    log_info "기본 패키지 설치 중..."

    # 필수 패키지 목록
    PACKAGES=(
        git
        zsh
        bat
        fzf
        ripgrep
        jq
        tree
        wget
        curl
        zip
        unzip
    )

    # lsd는 Intel Mac에서 문제될 수 있어서 별도 처리
    for pkg in "${PACKAGES[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            log_info "  $pkg: 이미 설치됨"
        else
            log_info "  $pkg: 설치 중..."
            if brew install "$pkg"; then
                log_success "  $pkg: 설치 완료"
            else
                log_warn "  $pkg: 설치 실패 (계속 진행)"
            fi
        fi
    done

    # lsd 설치 시도 (실패하면 eza로 대체)
    if ! brew list lsd &>/dev/null; then
        log_info "  lsd: 설치 시도 중..."
        if brew install lsd 2>/dev/null; then
            log_success "  lsd: 설치 완료"
        else
            log_warn "  lsd: 설치 실패, eza로 대체 설치"
            brew install eza || log_warn "  eza도 설치 실패"
        fi
    else
        log_info "  lsd: 이미 설치됨"
    fi

    log_success "기본 패키지 설치 완료"
}

# ============================================================
# SDKMAN 설치 (Java 버전 관리)
# ============================================================
install_sdkman() {
    log_info "SDKMAN 확인 중..."

    if [ -d "$HOME/.sdkman" ]; then
        log_success "SDKMAN 이미 설치됨"
    else
        log_info "SDKMAN 설치 중..."
        curl -s "https://get.sdkman.io" | bash

        if [ -d "$HOME/.sdkman" ]; then
            log_success "SDKMAN 설치 완료"
            log_info "Java 설치는 새 터미널에서: sdk install java 17.0.9-zulu"
        else
            log_error "SDKMAN 설치 실패"
        fi
    fi
}

# ============================================================
# nvm 설치 (Node.js 버전 관리)
# ============================================================
install_nvm() {
    log_info "nvm 확인 중..."

    if [ -d "$HOME/.nvm" ]; then
        log_success "nvm 이미 설치됨"
    else
        log_info "nvm 설치 중..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

        if [ -d "$HOME/.nvm" ]; then
            log_success "nvm 설치 완료"
            log_info "Node.js 설치는 새 터미널에서: nvm install 20"
        else
            log_error "nvm 설치 실패"
        fi
    fi
}

# ============================================================
# pyenv 설치 (Python 버전 관리)
# ============================================================
install_pyenv() {
    log_info "pyenv 확인 중..."

    if command -v pyenv &>/dev/null || [ -d "$HOME/.pyenv" ]; then
        log_success "pyenv 이미 설치됨"
    else
        log_info "pyenv 설치 중..."
        brew install pyenv pyenv-virtualenv

        if brew list pyenv &>/dev/null; then
            log_success "pyenv 설치 완료"
            log_info "Python 설치는 새 터미널에서: pyenv install 3.12.0"
        else
            log_error "pyenv 설치 실패"
        fi
    fi
}

# ============================================================
# uv 설치 (Python 패키지 관리 - pip 대체)
# ============================================================
install_uv() {
    log_info "uv 확인 중..."

    if command -v uv &>/dev/null; then
        log_success "uv 이미 설치됨"
    else
        log_info "uv 설치 중..."
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # PATH 업데이트
        export PATH="$HOME/.local/bin:$PATH"

        if command -v uv &>/dev/null; then
            log_success "uv 설치 완료"
        else
            log_warn "uv 설치 실패 (pip 사용 가능)"
        fi
    fi
}

# ============================================================
# 템플릿 파일 처리
# ============================================================
process_template() {
    local template="$1"
    local target="$2"

    if [ ! -f "$template" ]; then
        log_warn "템플릿 없음: $template"
        return 1
    fi

    # 기존 파일 백업
    if [ -f "$target" ]; then
        cp "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
        log_info "기존 파일 백업: ${target}.backup.*"
    fi

    # 변수 치환
    sed -e "s|{{BREW_PREFIX}}|$BREW_PREFIX|g" \
        -e "s|{{USER}}|$USER|g" \
        -e "s|{{HOME}}|$HOME|g" \
        "$template" > "$target"

    log_success "설정 파일 생성: $target"
}

# ============================================================
# 설정 파일 설치
# ============================================================
install_configs() {
    log_info "설정 파일 설치 중..."

    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    # .zshrc
    if [ -f "$SCRIPT_DIR/configs/shell/zshrc.template" ]; then
        process_template "$SCRIPT_DIR/configs/shell/zshrc.template" "$HOME/.zshrc"
    fi

    # .zprofile
    if [ -f "$SCRIPT_DIR/configs/shell/zprofile.template" ]; then
        process_template "$SCRIPT_DIR/configs/shell/zprofile.template" "$HOME/.zprofile"
    fi

    # .gitconfig
    if [ -f "$SCRIPT_DIR/configs/git/gitconfig.template" ]; then
        process_template "$SCRIPT_DIR/configs/git/gitconfig.template" "$HOME/.gitconfig"
    fi

    log_success "설정 파일 설치 완료"
}

# ============================================================
# 메인 실행
# ============================================================
main() {
    echo ""
    echo "=========================================="
    echo "  Mac 개발 환경 설정 스크립트"
    echo "=========================================="
    echo ""

    # 로그 파일 초기화
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== 설정 시작: $(date) ===" >> "$LOG_FILE"

    detect_architecture
    echo ""

    install_xcode_cli
    echo ""

    install_homebrew
    echo ""

    install_base_packages
    echo ""

    install_sdkman
    echo ""

    install_nvm
    echo ""

    install_pyenv
    echo ""

    install_uv
    echo ""

    install_configs
    echo ""

    echo "=========================================="
    echo -e "${GREEN}  설정 완료!${NC}"
    echo "=========================================="
    echo ""
    echo "다음 단계 (수동):"
    echo "  1. 새 터미널 열기 (설정 적용)"
    echo "  2. Java 설치: sdk install java 17.0.9-zulu"
    echo "  3. Node.js 설치: nvm install 20"
    echo "  4. Python 설치: pyenv install 3.12.0"
    echo "  5. GitHub SSH 키 등록"
    echo "  6. docs/manual-steps.md 참조"
    echo ""
    echo "로그 파일: $LOG_FILE"
    echo ""
}

main "$@"
