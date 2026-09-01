#!/usr/bin/env bash

set -uo pipefail

# Created by : Adrianzz ;)
# ⚠️ SCRIPT INI DIBUAT TANPA AI APAPUN..!! MAKLUM KALO ERROR, WAJARLAH MANUSIA BUKAN NABI BOY 🤧✌️

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[97m"
BOLD="\033[1m"
RESET="\033[0m"

C_MAIN='\033[1;36m'
C_DARK='\033[2;37m'
C_TEXT='\033[1;37m'
C_RESET='\033[0m'

OS="unknown"
PKG=""
PYTHON_CMD=""
PIP_CMD=""

LOG_FILE="${TMPDIR:-/tmp}/xvalez_installer.log"

touch "$LOG_FILE" 2>/dev/null || true



clear_screen() {
    clear 2>/dev/null || printf '\033c'
}

msg_ok() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

msg_warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

msg_info() {
    echo -e "${BLUE}[•]${RESET} $1"
}

msg_err() {
    echo -e "${RED}[x]${RESET} $1"
}



bar_animation() {
    local text="${1:-Loading}"
    local duration="${2:-2.0}"

    local total_blocks=20
    local start_time
    local now
    local elapsed
    local progress
    local percent
    local filled
    local empty
    local bar
    local plain
    local last_len=0
    local padding

    start_time=$(date +%s.%N)

    printf '\033[?25l'

    while true; do

        now=$(date +%s.%N)

        elapsed=$(awk \
            -v now="$now" \
            -v start="$start_time" '
            BEGIN {
                print now - start
            }
        ')

        progress=$(awk \
            -v elapsed="$elapsed" \
            -v duration="$duration" '
            BEGIN {
                p = elapsed / duration

                if (p < 0)
                    p = 0

                if (p > 1)
                    p = 1

                printf "%.6f", p
            }
        ')

        percent=$(awk \
            -v p="$progress" '
            BEGIN {
                if (p >= 1)
                    print 100
                else
                    print int(p * 100)
            }
        ')

        filled=$(awk \
            -v p="$progress" \
            -v total="$total_blocks" '
            BEGIN {
                if (p >= 1)
                    print total
                else
                    print int(p * total)
            }
        ')

        empty=$((total_blocks - filled))

        bar="${C_MAIN}"

        if (( filled > 0 )); then
            bar+="$(printf '█%.0s' $(seq 1 "$filled"))"
        fi

        bar+="${C_DARK}"

        if (( empty > 0 )); then
            bar+="$(printf '░%.0s' $(seq 1 "$empty"))"
        fi

        bar+="${C_RESET}"

        plain="[$(printf '█%.0s' $(seq 1 "$filled"))$(printf '░%.0s' $(seq 1 "$empty"))] $text $(printf '%3d' "$percent")%"

        padding=$((last_len - ${#plain}))

        if (( padding < 0 )); then
            padding=0
        fi

        printf '\r[%s] %s%s %3d%%%s' \
            "$bar" \
            "${C_TEXT}" \
            "$text" \
            "$percent" \
            "${C_RESET}"

        if (( padding > 0 )); then
            printf '%*s' "$padding" ''
        fi

        last_len=${#plain}

        if awk \
            -v p="$progress" '
            BEGIN {
                exit !(p >= 1.0)
            }
        '; then
            break
        fi

        sleep 0.05
    done

    local final_bar="${C_MAIN}"
    final_bar+="$(printf '█%.0s' $(seq 1 "$total_blocks"))"
    final_bar+="${C_RESET}"

    printf '\r[%s] %s%s 100%%%s' \
        "$final_bar" \
        "${C_TEXT}" \
        "$text" \
        "${C_RESET}"

    sleep 0.10

    printf '\r%*s\r' "$((last_len + 30))" ''

    printf '\033[?25h'
}



run_cmd() {
    local title="$1"
    shift

    echo
    msg_info "$title"

    : > "$LOG_FILE"

    (
        "$@"
    ) >"$LOG_FILE" 2>&1 &

    local pid=$!
    local delay="0.10"
    local spin='|/-\'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r [%c] " "${spin:$i:1}"
        i=$(( (i + 1) % 4 ))
        sleep "$delay"
    done

    printf "\r     \r"

    wait "$pid"
    local code=$?

    if [ "$code" -eq 0 ]; then
        msg_ok "$title selesai."
        return 0
    fi

    msg_err "$title gagal. Exit code: $code"

    echo
    echo -e "${YELLOW}----- ERROR TERAKHIR -----${RESET}"

    if [ -s "$LOG_FILE" ]; then
        tail -n 25 "$LOG_FILE"
    else
        echo "(Tidak ada output error.)"
    fi

    echo -e "${YELLOW}--------------------------${RESET}"
    echo

    return "$code"
}



detect_os() {

    if [ -n "${TERMUX_VERSION:-}" ] ||
       [ -d "/data/data/com.termux" ]; then

        OS="termux"
        PKG="pkg"
        return
    fi

    if [ -f "/etc/os-release" ]; then

        . /etc/os-release

        case "${ID:-}" in
            kali|debian|ubuntu|parrot|linuxmint)
                OS="linux"
                PKG="apt"
                return
                ;;
        esac
    fi

    if command -v apt >/dev/null 2>&1; then
        OS="linux"
        PKG="apt"
        return
    fi

    OS="unknown"
}



run_apt() {

    if [ "$(id -u)" -eq 0 ]; then
        apt "$@"
        return $?
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo apt "$@"
        return $?
    fi

    msg_err "sudo tidak ditemukan dan script bukan root."
    return 1
}



install_base() {

    if [ "$OS" = "termux" ]; then

        clear_screen
        echo -e "${CYAN}${BOLD}MENGUPDATE REPOSITORY TERMUX...${RESET}"
        bar_animation "UPDATING REPOSITORY..." 1.5
        run_cmd "Update repository Termux" pkg update -y
        clear_screen

        echo -e "${CYAN}${BOLD}MENG-UPGRADE PACKAGE TERMUX...${RESET}"
        bar_animation "UPGRADING PACKAGES..." 1.5
        run_cmd "Upgrade package Termux" pkg upgrade -y
        clear_screen

    elif [ "$OS" = "linux" ]; then

        clear_screen
        echo -e "${CYAN}${BOLD}MENGUPDATE REPOSITORY LINUX...${RESET}"
        bar_animation "UPDATING REPOSITORY..." 1.5
        run_cmd "Update repository Linux" run_apt update
        clear_screen

        echo -e "${CYAN}${BOLD}MENG-UPGRADE PACKAGE LINUX...${RESET}"
        bar_animation "UPGRADING PACKAGES..." 1.5
        run_cmd "Upgrade package Linux" run_apt upgrade -y
        clear_screen

    else

        msg_err "OS tidak dikenali."
        exit 1

    fi
}



install_termux_package() {

    local package="$1"

    clear_screen

    echo -e "${CYAN}${BOLD}"
    echo "MENGECEK PACKAGE"
    echo -e "${RESET}"
    echo -e "${GREEN}Package : ${WHITE}${package}${RESET}"
    echo

    if dpkg -s "$package" >/dev/null 2>&1; then
        msg_ok "$package sudah terinstall."
        sleep 0.3
        clear_screen
        return 0
    fi

    msg_info "Mendownload / menginstall: ${package}"
    echo

    bar_animation "INSTALLING $package..." 1.2

    if run_cmd "Install $package" \
        pkg install "$package" -y; then

        msg_ok "$package berhasil diinstall."
        sleep 0.3
        clear_screen
        return 0
    fi

    msg_warn "Gagal install package: $package"
    sleep 0.5
    clear_screen

    return 1
}


install_linux_package() {

    local package="$1"

    clear_screen

    echo -e "${CYAN}${BOLD}"
    echo "MENGECEK PACKAGE"
    echo -e "${RESET}"
    echo -e "${GREEN}Package : ${WHITE}${package}${RESET}"
    echo

    if dpkg -s "$package" >/dev/null 2>&1; then
        msg_ok "$package sudah terinstall."
        sleep 0.3
        clear_screen
        return 0
    fi

    msg_info "Mendownload / menginstall: ${package}"
    echo

    bar_animation "INSTALLING $package..." 1.2

    if run_cmd "Install $package" \
        run_apt install "$package" -y; then

        msg_ok "$package berhasil diinstall."
        sleep 0.3
        clear_screen
        return 0
    fi

    msg_warn "Gagal install package: $package"
    sleep 0.5
    clear_screen

    return 1
}



detect_python() {

    PYTHON_CMD=""

    if command -v python >/dev/null 2>&1; then
        PYTHON_CMD="python"

    elif command -v python3 >/dev/null 2>&1; then
        PYTHON_CMD="python3"
    fi

    if [ -z "$PYTHON_CMD" ]; then
        msg_err "Python tidak ditemukan."
        return 1
    fi

    local version
    version="$("$PYTHON_CMD" --version 2>&1)"

    msg_ok "Python terdeteksi: $PYTHON_CMD ($version)"

    return 0
}


detect_pip() {

    PIP_CMD=""

    if [ -n "$PYTHON_CMD" ] &&
       "$PYTHON_CMD" -m pip --version >/dev/null 2>&1; then

        PIP_CMD="$PYTHON_CMD -m pip"

        msg_ok "PIP terdeteksi melalui $PYTHON_CMD -m pip"
        return 0
    fi

    if command -v pip >/dev/null 2>&1; then
        PIP_CMD="pip"
        msg_ok "PIP terdeteksi: pip"
        return 0
    fi

    if command -v pip3 >/dev/null 2>&1; then
        PIP_CMD="pip3"
        msg_ok "PIP terdeteksi: pip3"
        return 0
    fi

    return 1
}



install_python() {

    clear_screen

    echo -e "${CYAN}${BOLD}MEMPERSIAPKAN PYTHON...${RESET}"
    echo

    if [ "$OS" = "termux" ]; then

        install_termux_package "python" || true
        install_termux_package "python-pip" || true

    elif [ "$OS" = "linux" ]; then

        install_linux_package "python3" || true
        install_linux_package "python3-pip" || true
    fi

    clear_screen

    if ! detect_python; then
        msg_err "Python gagal dipersiapkan."
        return 1
    fi

    if ! detect_pip; then

        clear_screen

        msg_info "PIP belum aktif."
        echo
        echo -e "${GREEN}Mendownload / menginstall Python PIP...${RESET}"
        echo

        if [ "$OS" = "termux" ]; then
            install_termux_package "python-pip" || true
        else
            install_linux_package "python3-pip" || true
        fi
    fi

    clear_screen

    if ! detect_pip; then
        msg_err "PIP tetap tidak ditemukan."
        return 1
    fi

    clear_screen
    return 0
}



pip_package_installed() {

    local package="$1"

    "$PYTHON_CMD" -m pip show "$package" \
        >/dev/null 2>&1
}


install_pip_package() {

    local package="$1"

    clear_screen

    echo -e "${CYAN}${BOLD}"
    echo "MENGECEK PYTHON PACKAGE"
    echo -e "${RESET}"
    echo -e "${GREEN}Package : ${WHITE}${package}${RESET}"
    echo

    if pip_package_installed "$package"; then

        msg_ok "Python package '$package' sudah terinstall."
        sleep 0.3
        clear_screen

        return 0
    fi

    msg_info "Mendownload / menginstall Python package: ${package}"
    echo

    bar_animation "INSTALLING $package..." 1.2

    if "$PYTHON_CMD" -m pip install \
        "$package" >"$LOG_FILE" 2>&1; then

        msg_ok "Python package '$package' berhasil diinstall."
        sleep 0.3
        clear_screen

        return 0
    fi

    msg_warn "Install normal gagal."
    msg_warn "Mencoba --break-system-packages..."

    if "$PYTHON_CMD" -m pip install \
        --break-system-packages \
        "$package" >"$LOG_FILE" 2>&1; then

        msg_ok "Python package '$package' berhasil diinstall."
        sleep 0.3
        clear_screen

        return 0
    fi

    msg_err "Python package '$package' gagal diinstall."

    echo
    tail -n 20 "$LOG_FILE" 2>/dev/null || true
    echo

    sleep 0.5
    clear_screen

    return 1
}



install_required_packages() {

    local package
    local failed=0

    if [ "$OS" = "termux" ]; then

        TERMUX_PKGS=(
            git
            bash
            curl
            openssl
            openssh
            wget
            ffmpeg
            jq
            xxd
        )

        for package in "${TERMUX_PKGS[@]}"; do

            if ! install_termux_package "$package"; then
                failed=$((failed + 1))
            fi

        done

    elif [ "$OS" = "linux" ]; then

        LINUX_PKGS=(
            git
            bash
            curl
            openssl
            openssh-client
            wget
            ffmpeg
            jq
            xxd
        )

        for package in "${LINUX_PKGS[@]}"; do

            if ! install_linux_package "$package"; then
                failed=$((failed + 1))
            fi

        done
    fi

    clear_screen

    if [ "$failed" -gt 0 ]; then
        msg_warn "$failed package gagal diinstall."
        msg_warn "Script tetap dilanjutkan."
    else
        msg_ok "Semua system package utama tersedia."
    fi

    sleep 0.5
    clear_screen
}



install_python_packages() {

    local package
    local failed=0

    PYTHON_PKGS=(
        requests
        colorama
        phonenumbers
        scrapy
        python-dotenv
    )

    for package in "${PYTHON_PKGS[@]}"; do

        if ! install_pip_package "$package"; then
            failed=$((failed + 1))
        fi

    done

    clear_screen

    if [ "$failed" -gt 0 ]; then
        msg_warn "$failed Python package gagal."
        msg_warn "Cek $LOG_FILE jika diperlukan."
    else
        msg_ok "Semua Python dependencies tersedia."
    fi

    sleep 0.5
    clear_screen
}



install_mpv_optional() {

    clear_screen

    echo -e "${CYAN}${BOLD}MENGECEK MPV...${RESET}"
    echo

    if command -v mpv >/dev/null 2>&1; then
        msg_ok "mpv sudah tersedia."
    else
        msg_warn "mpv tidak ditemukan."
        msg_warn "MPV dilewati karena optional."
    fi

    sleep 0.5
    clear_screen
}



run_program() {

    if [ ! -f "run.py" ]; then

        clear_screen

        msg_err "run.py tidak ditemukan."

        echo
        echo "Folder sekarang:"
        pwd

        echo
        echo "Isi folder:"
        ls -la

        echo

        exit 1
    fi

    if [ -z "$PYTHON_CMD" ]; then

        if ! detect_python; then
            msg_err "Tidak ada Python untuk menjalankan run.py."
            exit 1
        fi
    fi

    clear_screen

    echo -e "${CYAN}${BOLD}"
    echo "MENJALANKAN RUN.PY"
    echo -e "${RESET}"

    echo -e "${GREEN}Python : ${PYTHON_CMD}${RESET}"
    echo -e "${GREEN}File   : $(pwd)/run.py${RESET}"
    echo

    exec "$PYTHON_CMD" run.py
}



main() {

    clear_screen

    echo -e "${CYAN}${BOLD}XVALEZ INSTALLER${RESET}"
    echo
    msg_info "Mendeteksi environment..."

    detect_os

    case "$OS" in

        termux)
            msg_ok "Terdeteksi: TERMUX 📱"
            ;;

        linux)
            msg_ok "Terdeteksi: Linux 💻"
            ;;

        *)
            msg_err "OS tidak didukung."
            msg_err "Support: Termux / Kali / Debian / Ubuntu / Parrot / Linux Mint."
            exit 1
            ;;
    esac

    sleep 0.5


    install_base


    install_python


    install_required_packages


    install_python_packages


    install_mpv_optional


    clear_screen

    echo -e "${GREEN}${BOLD}"
    echo "=============================================="
    echo "        INSTALLATION STEP SELESAI"
    echo "=============================================="
    echo -e "${RESET}"

    msg_info "Log terakhir: $LOG_FILE"

    sleep 1

    clear_screen

    echo -e "${BLUE}${BOLD}"
    echo "BENTAR BANG! DIKIT LAGI 🗿"
    echo -e "${RESET}"

    sleep 1

    run_program
}

main "$@"