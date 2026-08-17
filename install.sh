#!/usr/bin/env bash

set -uo pipefail

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

spinner() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r [%c] " "${spin:$i:1}"
        sleep "$delay"
    done
    printf "\r      \r"
}
clear
banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat <<'EOF'
██╗  ██╗       ██╗   ██╗ █████╗ ██╗     ███████╗███████╗
╚██╗██╔╝       ██║   ██║██╔══██╗██║     ██╔════╝╚══███╔╝
 ╚███╔╝ █████╗ ██║   ██║███████║██║     █████╗    ███╔╝ 
 ██╔██╗ ╚════╝ ╚██╗ ██╔╝██╔══██║██║     ██╔══╝   ███╔╝  
██╔╝ ██╗        ╚████╔╝ ██║  ██║███████╗███████╗███████╗
╚═╝  ╚═╝         ╚═══╝  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
EOF
    echo -e "${RESET}"
    echo -e "${WHITE}Terdeteksi: Termux / Kali Linux${RESET}"
    echo
}

msg_ok()    { echo -e "${GREEN}[✓]${RESET} $1"; }
msg_warn()  { echo -e "${YELLOW}[!]${RESET} $1"; }
msg_info()  { echo -e "${BLUE}[•]${RESET} $1"; }
msg_err()   { echo -e "${RED}[x]${RESET} $1"; }

run_cmd_silent() {
    local title="$1"
    shift
    msg_info "$title"
    "$@" >/tmp/xvalez_last.log 2>&1 &
    local pid=$!
    spinner "$pid"
    if wait "$pid"; then
        msg_ok "$title selesai."
        return 0
    else
        msg_warn "$title gagal (lihat /tmp/xvalez_last.log)."
        return 1
    fi
}

run_cmd_fg() {
    local title="$1"
    shift
    msg_info "$title"
    if "$@"; then
        msg_ok "$title selesai."
        return 0
    else
        msg_warn "$title gagal (exit code $?), lanjut ke step berikutnya..."
        return 1
    fi
}

detect_os() {
    if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
        OS="termux"
        PKG="pkg"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        case "${ID:-}" in
            kali|debian|ubuntu|parrot|linuxmint)
                OS="kali"
                PKG="apt"
                ;;
            *)
                if command -v apt >/dev/null 2>&1; then
                    OS="kali"
                    PKG="apt"
                else
                    OS="unknown"
                fi
                ;;
        esac
    else
        OS="unknown"
    fi
}

install_base() {
    if [ "$OS" = "termux" ]; then
            if command -v termux-change-repo >/dev/null 2>&1; then
            msg_warn "termux-change-repo bersifat interaktif, dilewati agar tidak stuck."
            msg_warn "Jalankan manual 'termux-change-repo' kalau mau ganti mirror."
        fi

        run_cmd_fg "Update package list (pkg update)..." pkg update -y
        run_cmd_fg "Upgrade packages (pkg upgrade)..." pkg upgrade -y

    elif [ "$OS" = "kali" ]; then
        run_cmd_fg "Update package list (sudo apt update)..." sudo apt update -y
        run_cmd_fg "Upgrade packages (sudo apt upgrade)..." sudo apt upgrade -y
    else
        msg_err "OS tidak dikenali."
        exit 1
    fi
}

install_pkg_termux() {
    local pkg="$1"
    if command -v "$pkg" >/dev/null 2>&1; then
        msg_ok "$pkg sudah terinstall."
    else
        msg_warn "$pkg belum ada, install sekarang..."
        if run_cmd_silent "Install $pkg" pkg install "$pkg" -y; then
            :
        else
            msg_warn "Gagal install $pkg (mungkin nama paket tidak tersedia di Termux)."
        fi
    fi
}

install_pkg_kali() {
    local pkg="$1"
    if command -v "$pkg" >/dev/null 2>&1; then
        msg_ok "$pkg sudah terinstall."
    else
        msg_warn "$pkg belum ada, install sekarang..."
        run_cmd_fg "Install $pkg" sudo apt install "$pkg" -y
    fi
}

install_pip_pkg() {
    local pip_pkg="$1"

    if command -v pip3 >/dev/null 2>&1; then
        PIP_CMD="pip3"
    elif command -v pip >/dev/null 2>&1; then
        PIP_CMD="pip"
    else
        msg_warn "pip belum ada, mencoba install..."
        if [ "$OS" = "termux" ]; then
            run_cmd_fg "Install python (untuk pip)" pkg install python -y
        else
            run_cmd_fg "Install python3-pip" sudo apt install python3-pip -y
        fi
        if command -v pip3 >/dev/null 2>&1; then
            PIP_CMD="pip3"
        elif command -v pip >/dev/null 2>&1; then
            PIP_CMD="pip"
        else
            msg_err "pip tetap tidak ditemukan."
            return 1
        fi
    fi

    if "$PIP_CMD" show "$pip_pkg" >/dev/null 2>&1; then
        msg_ok "PIP '$pip_pkg' sudah terinstall."
    else
        msg_warn "PIP '$pip_pkg' belum ada, install sekarang..."
        if run_cmd_silent "Install pip package $pip_pkg" "$PIP_CMD" install "$pip_pkg"; then
            :
        elif run_cmd_silent "Install pip package $pip_pkg (break-system-packages)" \
                "$PIP_CMD" install "$pip_pkg" --break-system-packages; then
            :
        else
            msg_warn "Gagal install pip '$pip_pkg'. Cek /tmp/xvalez_last.log"
        fi
    fi
}

main() {
    banner
    detect_os

    if [ "$OS" = "termux" ]; then
        msg_ok "Terdeteksi: TERMUX 📱"
        install_base

        TERMUX_PKGS=(
            python
            git
            bash
            curl
            xxd
            openssl
            openssh
            wget
            ffmpeg
            jq
        )

        for p in "${TERMUX_PKGS[@]}"; do
            install_pkg_termux "$p"
        done

        if pkg search python2 >/dev/null 2>&1; then
            install_pkg_termux "python2"
        else
            msg_warn "python2 tidak tersedia di repository Termux modern, dilewati."
        fi

    elif [ "$OS" = "kali" ]; then
        msg_ok "Terdeteksi: KALI LINUX 💻"
        install_base

        KALI_PKGS=(
            python3
            python3-pip
            python2
            git
            bash
            curl
            xxd
            openssl
            openssh-client
            wget
            ffmpeg
        )

        for p in "${KALI_PKGS[@]}"; do
            install_pkg_kali "$p"
        done
    else
        msg_err "OS tidak dikenali. Script ini hanya support Termux dan Kali Linux."
        exit 1
    fi

    echo
    msg_info "Mengecek library Python / PIP..."

    PIP_LIBS=(
        phonenumbers
        requests
        colorama
        scrapy
        python-dotenv
    )

    for lib in "${PIP_LIBS[@]}"; do
        install_pip_pkg "$lib"
    done

    echo
    echo -e "${GREEN}${BOLD}[✓] Semua package & pip siap!${RESET}"
    echo -e "${CYAN}Sedang menjalankan tools...${RESET}"
    echo -e "${GREEN}${BOLD}SABAR DULU YA PUKI 🐷${RESET}"
    echo
    echo
    echo
    echo
    clear
    echo
    echo
    echo
    echo
    echo -e "${BLUE}${BOLD}BENTAR BANG! DIKIT LAGI 🗿${RESET}"

    if [ -f "run.py" ]; then
        python3 run.py || python run.py
    else
        msg_err "run.py tidak ditemukan di folder ini."
        exit 1
    fi
}

main "$@"