#!/bin/bash
#
# Mac 개발 환경 설정 스크립트
# Apple Silicon / Intel Mac 자동 감지
# Java, Node.js, Python까지 전부 자동 설치
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
        echo ""
        echo "============================================"
        echo "  팝업 창에서 '설치' 버튼을 클릭하세요!"
        echo "  설치가 완료되면 Enter를 눌러주세요."
        echo "============================================"
        echo ""
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
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # PATH에 추가 (현재 세션)
        eval "$($BREW_PREFIX/bin/brew shellenv)"

        if command -v brew &>/dev/null; then
            log_success "Homebrew 설치 완료"
        else
            log_error "Homebrew 설치 실패"
            exit 1
        fi
    fi

    # 현재 세션에서 brew 사용 가능하게
    eval "$($BREW_PREFIX/bin/brew shellenv)"
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

    for pkg in "${PACKAGES[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            log_info "  $pkg: 이미 설치됨"
        else
            log_info "  $pkg: 설치 중..."
            if brew install "$pkg" 2>/dev/null; then
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
            brew install eza 2>/dev/null || log_warn "  eza도 설치 실패"
        fi
    else
        log_info "  lsd: 이미 설치됨"
    fi

    log_success "기본 패키지 설치 완료"
}

# ============================================================
# SDKMAN + Java 설치
# ============================================================
install_sdkman_and_java() {
    log_info "SDKMAN 확인 중..."

    export SDKMAN_DIR="$HOME/.sdkman"

    if [ -d "$SDKMAN_DIR" ]; then
        log_success "SDKMAN 이미 설치됨"
    else
        log_info "SDKMAN 설치 중..."
        curl -s "https://get.sdkman.io?rcupdate=false" | bash

        if [ ! -d "$SDKMAN_DIR" ]; then
            log_error "SDKMAN 설치 실패"
            return 1
        fi
        log_success "SDKMAN 설치 완료"
    fi

    # SDKMAN 로드
    if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
    fi

    # Java 17 설치
    log_info "Java 17 설치 중... (시간이 좀 걸립니다)"
    if sdk list java 2>/dev/null | grep -q "17.0.*-zulu.*installed"; then
        log_success "Java 17 이미 설치됨"
    else
        # 자동으로 yes 입력
        echo "Y" | sdk install java 17.0.13-zulu 2>/dev/null || sdk install java 17.0.13-zulu
        log_success "Java 17 설치 완료"
    fi
}

# ============================================================
# nvm + Node.js 설치
# ============================================================
install_nvm_and_node() {
    log_info "nvm 확인 중..."

    export NVM_DIR="$HOME/.nvm"

    if [ -d "$NVM_DIR" ]; then
        log_success "nvm 이미 설치됨"
    else
        log_info "nvm 설치 중..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

        if [ ! -d "$NVM_DIR" ]; then
            log_error "nvm 설치 실패"
            return 1
        fi
        log_success "nvm 설치 완료"
    fi

    # nvm 로드
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    # Node.js 20 LTS 설치
    log_info "Node.js 20 LTS 설치 중..."
    if nvm list 2>/dev/null | grep -q "v20"; then
        log_success "Node.js 20 이미 설치됨"
    else
        nvm install 20
        nvm alias default 20
        log_success "Node.js 20 설치 완료"
    fi
}

# ============================================================
# pyenv + Python 설치
# ============================================================
install_pyenv_and_python() {
    log_info "pyenv 확인 중..."

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    if brew list pyenv &>/dev/null || [ -d "$PYENV_ROOT" ]; then
        log_success "pyenv 이미 설치됨"
    else
        log_info "pyenv 설치 중..."
        brew install pyenv pyenv-virtualenv

        if ! brew list pyenv &>/dev/null; then
            log_error "pyenv 설치 실패"
            return 1
        fi
        log_success "pyenv 설치 완료"
    fi

    # pyenv 로드
    eval "$(pyenv init -)" 2>/dev/null || true

    # Python 3.12 설치
    log_info "Python 3.12 설치 중... (빌드에 시간이 좀 걸립니다)"
    if pyenv versions 2>/dev/null | grep -q "3.12"; then
        log_success "Python 3.12 이미 설치됨"
    else
        # 빌드 의존성 설치
        brew install openssl readline sqlite3 xz zlib tcl-tk 2>/dev/null || true

        pyenv install 3.12.0
        pyenv global 3.12.0
        log_success "Python 3.12 설치 완료"
    fi
}

# ============================================================
# uv 설치 (Python 패키지 관리)
# ============================================================
install_uv() {
    log_info "uv 확인 중..."

    if command -v uv &>/dev/null; then
        log_success "uv 이미 설치됨"
    else
        log_info "uv 설치 중..."
        curl -LsSf https://astral.sh/uv/install.sh | sh

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
    echo "  (Java, Node.js, Python 자동 설치)"
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

    install_sdkman_and_java
    echo ""

    install_nvm_and_node
    echo ""

    install_pyenv_and_python
    echo ""

    install_uv
    echo ""

    install_configs
    echo ""

    echo "=========================================="
    echo -e "${GREEN}  설정 완료!${NC}"
    echo "=========================================="
    echo ""
    echo "설치된 버전:"
    echo "  - Java: $(java -version 2>&1 | head -1 || echo '새 터미널에서 확인')"
    echo "  - Node: $(node -v 2>/dev/null || echo '새 터미널에서 확인')"
    echo "  - Python: $(python --version 2>/dev/null || echo '새 터미널에서 확인')"
    echo ""
    echo "남은 작업 (수동):"
    echo "  1. 터미널 닫고 다시 열기"
    echo "  2. ~/.gitconfig에서 name, email 수정"
    echo "  3. GitHub SSH 키 등록 (docs/manual-steps.md 참조)"
    echo ""
    echo "로그 파일: $LOG_FILE"
    echo ""
}

main "$@"
