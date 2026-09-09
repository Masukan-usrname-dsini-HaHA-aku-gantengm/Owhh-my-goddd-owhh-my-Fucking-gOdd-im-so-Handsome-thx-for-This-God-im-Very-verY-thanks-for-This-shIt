#!/data/data/com.termux/files/usr/bin/bash

# Created By : Adrianzz [ NO NO NO AI 💦 ]

set +e

RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
BLUE='\033[1;94m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
RESET='\033[0m'

info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

ok() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

err() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

if command -v pkg >/dev/null 2>&1; then
    TERMUX=true
else
    TERMUX=false
fi

if command -v python >/dev/null 2>&1; then
    PYTHON="python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON="python3"
else
    err "Python tidak ditemukan."
    exit 1
fi

PIP="$PYTHON -m pip"
clear
echo
echo -e "${BLUE}============================================${RESET}"
echo -e "${WHITE}   AUTO CHECK & FIX PYTHON DEPENDENCY${RESET}"
echo -e "${BLUE}============================================${RESET}"
echo

check_cffi_backend() {
    "$PYTHON" -c 'import _cffi_backend' >/dev/null 2>&1
}

check_cryptography() {
    "$PYTHON" -c 'import cryptography' >/dev/null 2>&1
}

install_termux_build_deps() {
    if [ "$TERMUX" != true ]; then
        warn "Bukan Termux, melewati pkg install."
        return
    fi

    info "Menyiapkan dependency build Termux..."

    pkg update -y

    pkg install -y \
        python \
        clang \
        make \
        pkg-config \
        libffi \
        openssl \
        rust

    if [ $? -eq 0 ]; then
        ok "Dependency Termux berhasil disiapkan."
    else
        warn "Sebagian dependency Termux gagal dipasang."
    fi
}

fix_cffi() {

    echo
    echo -e "${BLUE}--- CHECK _cffi_backend ---${RESET}"

    if check_cffi_backend; then
        ok "_cffi_backend sudah tersedia."
        return 0
    fi

    warn "ModuleNotFoundError: _cffi_backend"
    info "Menjalankan perintah utama:"
    echo
    echo -e "${YELLOW}$PIP -vvv install --upgrade --force-reinstall cffi${RESET}"
    echo

    $PIP -vvv install --upgrade --force-reinstall cffi

    if check_cffi_backend; then
        ok "_cffi_backend berhasil diperbaiki."
        return 0
    fi

    warn "Percobaan pip pertama gagal."
    info "Mencoba jalur alternatif..."

    install_termux_build_deps

    info "Upgrade pip / setuptools / wheel..."
    $PIP install --upgrade pip setuptools wheel

    $PIP cache purge

    info "Mencoba install ulang cffi..."
    $PIP install --no-cache-dir --force-reinstall cffi

    if check_cffi_backend; then
        ok "_cffi_backend berhasil setelah percobaan kedua."
        return 0
    fi

    warn "Masih gagal. Mencoba build cffi dari source..."

    $PIP install \
        --no-cache-dir \
        --force-reinstall \
        --no-binary :all: \
        cffi

    if check_cffi_backend; then
        ok "_cffi_backend berhasil setelah build source."
        return 0
    fi

    err "Gagal memperbaiki _cffi_backend."
    return 1
}

fix_cryptography() {

    echo
    echo -e "${BLUE}--- CHECK cryptography ---${RESET}"

    if check_cryptography; then
        ok "cryptography sudah tersedia."
        return 0
    fi

    warn "ModuleNotFoundError: cryptography"
    info "Menjalankan:"
    echo
    echo -e "${YELLOW}$PIP install cryptography${RESET}"
    echo

    $PIP install cryptography

    if check_cryptography; then
        ok "cryptography berhasil di-install."
        return 0
    fi

    warn "pip install cryptography gagal."
    info "Mencoba jalur alternatif..."

    install_termux_build_deps

    info "Upgrade pip / setuptools / wheel..."
    $PIP install --upgrade pip setuptools wheel

    $PIP cache purge

    info "Percobaan reinstall tanpa cache..."
    $PIP install --no-cache-dir --force-reinstall cryptography

    if check_cryptography; then
        ok "cryptography berhasil setelah reinstall."
        return 0
    fi

    warn "Masih gagal. Mencoba compile cryptography dari source..."

    $PIP install \
        --no-cache-dir \
        --force-reinstall \
        --no-binary cryptography \
        cryptography

    if check_cryptography; then
        ok "cryptography berhasil setelah build source."
        return 0
    fi

    err "Gagal memperbaiki cryptography."
    return 1
}


CFFI_STATUS=0
CRYPTO_STATUS=0

fix_cffi
CFFI_STATUS=$?

fix_cryptography
CRYPTO_STATUS=$?

echo
echo -e "${BLUE}============================================${RESET}"
echo -e "${WHITE}                HASIL AKHIR${RESET}"
echo -e "${BLUE}============================================${RESET}"

if check_cffi_backend; then
    echo -e "${GREEN}[✓] _cffi_backend : OK${RESET}"
else
    echo -e "${RED}[✗] _cffi_backend : FAILED${RESET}"
fi

if check_cryptography; then
    echo -e "${GREEN}[✓] cryptography  : OK${RESET}"
else
    echo -e "${RED}[✗] cryptography  : FAILED${RESET}"
fi

echo

if check_cffi_backend && check_cryptography; then
    ok "Semua module berhasil diperbaiki."
    exit 0
else
    err "Masih ada module yang belum berhasil diperbaiki."
    exit 1
fi

clear

PKGS=(
    "python"
    "git"
    "curl"
    "xxd"
    "jq"
    "make"
    "python-cryptography"
)

PIPS=(
    "requests"
    "colorama"
    "phonenumbers"
    "modules"
    "mpv"
    "selenium"
)

C_RESET='\033[0m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_CYAN='\033[1;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

TIMEOUT_SEC=30
BAR_WIDTH=28

clear

printf "${C_GREEN}[?] MENGECEK UPDATE..!!${C_RESET}\n"
auto_update() {
    if [ ! -d ".git" ]; then
        printf "${C_WHITE}[✓] Bukan repository Git, update dilewati. Santai aja.${C_RESET}\n"
        return 0
    fi

    printf "${C_CYAN}[!] Cek update Git dulu, siapa tau ada oleh-oleh baru..${C_RESET}\n"

    local old_commit
    local new_commit

    old_commit=$(git rev-parse HEAD 2>/dev/null)

    if [ -z "$old_commit" ]; then
        printf "${C_RED}[✗] Gagal membaca commit Git.${C_RESET}\n"
        return 0
    fi

    export GIT_TERMINAL_PROMPT=0
    export GIT_EDITOR=true

    if ! timeout "$TIMEOUT_SEC" git pull --ff-only --quiet >/dev/null 2>&1; then
        printf "${C_RED}[✗] Git pull gagal atau timeout, update dilewati.${C_RESET}\n"
        return 0
    fi

    new_commit=$(git rev-parse HEAD 2>/dev/null)

    if [ -z "$new_commit" ]; then
        printf "${C_RED}[✗] Gagal membaca commit Git setelah update.${C_RESET}\n"
        return 0
    fi

    if [ "$old_commit" != "$new_commit" ]; then
        printf "${C_GREEN}[✓] Update baru ditemukan.${C_RESET}\n"
        printf "${C_YELLOW}[!] Restart agar versi terbaru aktif..${C_RESET}\n"

        sleep 1

        exec bash "$0" "$@"
    else
        printf "${C_GREEN}[✓] Sudah versi terbaru. Tidak perlu restart.${C_RESET}\n"
    fi
}

auto_update "$@"
clear

printf "${C_CYAN}[!] ${C_WHITE}NYIAPIN PACKAGE & PIP YANG DIPERLUKAN..!!${C_RESET}\n"
sleep 0.8
clear

draw_bar() {
    local percent="$1"
    local filled=$((percent * BAR_WIDTH / 100))
    local empty=$((BAR_WIDTH - filled))

    printf "\r${C_CYAN}[${C_WHITE}"
    printf "%${filled}s" | tr ' ' '#'
    printf "${C_GRAY}"
    printf "%${empty}s" | tr ' ' '-'
    printf "${C_CYAN}] ${C_WHITE}%3d%%${C_RESET}" "$percent"
}

loading() {
    local text="$1"
    local duration="${2:-1.5}"
    local start_ns end_ns now elapsed percent

    start_ns=$(date +%s%N)
    end_ns=$((start_ns + ${duration%.*}000000000))

    while :; do
        now=$(date +%s%N)

        if (( now >= end_ns )); then
            percent=100
        else
            elapsed=$((now - start_ns))
            percent=$((elapsed * 100 / (end_ns - start_ns)))
        fi

        (( percent > 100 )) && percent=100

        printf "\r${C_BLUE}[*] ${C_WHITE}%-32s ${C_RESET}" "$text"
        draw_bar "$percent"

        (( percent >= 100 )) && break
        sleep 0.06
    done

    printf "\n"
}

run_with_timeout() {
    timeout "$TIMEOUT_SEC" "$@" >/dev/null 2>&1
}

check_pkg() {
    local pkg="$1"

    if command -v "$pkg" >/dev/null 2>&1; then
        printf "${C_GREEN}[✓] ${C_WHITE}%s ${C_GRAY}sudah ada${C_RESET}\n" "$pkg"
        return 0
    fi

    if pkg list-installed 2>/dev/null | grep -q "^${pkg}/"; then
        printf "${C_GREEN}[✓] ${C_WHITE}%s ${C_GRAY}sudah terisntall${C_RESET}\n" "$pkg"
        return 0
    fi

    printf "${C_YELLOW}[!] ${C_WHITE}%s ${C_GRAY}belum ada, lagi dipanggil..${C_RESET}\n" "$pkg"

    loading "Installing $pkg" 0.8

    if run_with_timeout pkg install "$pkg" -y --quiet; then
        printf "${C_GREEN}[✓] ${C_WHITE}%s ${C_GRAY}berhasil dipasang.${C_RESET}\n" "$pkg"
    else
        printf "${C_RED}[✗] ${C_WHITE}%s ${C_GRAY}gagal/stuck, KONTOL GAPAPA KOK GA ERROR${C_RESET}\n" "$pkg"
    fi

    sleep 0.23
}

check_pip() {
    local pip="$1"

    if python -m pip show "$pip" >/dev/null 2>&1; then
        printf "${C_GREEN}[✓] ${C_WHITE}%s ${C_GRAY}sudah ada${C_RESET}\n" "$pip"
        return 0
    fi

    printf "${C_YELLOW}[!] ${C_WHITE}%s ${C_GRAY}belum ada, lagi dipasang..${C_RESET}\n" "$pip"

    loading "Installing pip:$pip" 0.8

    if run_with_timeout python -m pip install "$pip" -q; then
        printf "${C_GREEN}[✓] ${C_WHITE}%s ${C_GRAY}berhasil dipasang${C_RESET}\n" "$pip"
    else
        printf "${C_RED}[✗] ${C_WHITE}%s ${C_GRAY}gagal/stuck, skip dulu..${C_RESET}\n" "$pip"
    fi

    sleep 0.23
}

printf "${C_CYAN}╭──────────────────────────────────────────────╮${C_RESET}\n"
printf "${C_CYAN}│               CHECKING PACKAGE               │${C_RESET}\n"
printf "${C_CYAN}╰──────────────────────────────────────────────╯${C_RESET}\n"

for pkg in "${PKGS[@]}"; do
    check_pkg "$pkg"
done

printf "\n"

printf "${C_CYAN}╭──────────────────────────────────────────────╮${C_RESET}\n"
printf "${C_CYAN}│                 CHECKING PIP                 │${C_RESET}\n"
printf "${C_CYAN}╰──────────────────────────────────────────────╯${C_RESET}\n"

for pip in "${PIPS[@]}"; do
    check_pip "$pip"
done

printf "\n"

loading "Mempersiapkan run.py" 1.0

clear

printf "${C_GREEN}[✓] ${C_WHITE}Semua dependency sudah diproses. Aman.${C_RESET}\n"
printf "${C_CYAN}[>] ${C_WHITE}Menjalankan ${C_YELLOW}python run.py${C_RESET}\n\n"

exec python run.py
