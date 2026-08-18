#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
#  fix.sh - X-ValeZ Fixer Tool
#  Downgrade Python ke 3.13.5 + Install Dependency Baileys
# =========================================================

# ---------- WARNA ----------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------- FUNGSI BANNER ----------
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
‎ ⠖ ⠖ ⡆    ⣀⣀⣀  
‎⢸‘    ⡗⠐⠉⠁  ⣇⡤⠽⡆
‎ ⢉⡟⠳⡄     . ⣇⣀⡴⠃
‎ ⡏     ⡸⠉⠉⠉⠁    
‎  ⠙⠒⠚⠁
EOF
    echo -e "${RESET}"
    echo -e "${MAGENTA}${BOLD}         ╔══════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}         ║${WHITE}   File \"fix.sh\" ini untuk memperbaiki      ${MAGENTA}║${RESET}"
    echo -e "${MAGENTA}${BOLD}         ║${WHITE}   semua masalah pada script X-ValeZ         ${MAGENTA}║${RESET}"
    echo -e "${MAGENTA}${BOLD}         ╚══════════════════════════════════════════╝${RESET}"
    echo ""
}

# ---------- FUNGSI GARIS ----------
line() {
    echo -e "${BLUE}${BOLD}────────────────────────────────────────────────────${RESET}"
}

# ---------- FUNGSI STEP ----------
step() {
    echo -e "${GREEN}${BOLD}[✔] ${WHITE}$1${RESET}"
}

step_run() {
    echo -e "${CYAN}${BOLD}[➤] ${WHITE}$1${RESET}"
}

error_msg() {
    echo -e "${RED}${BOLD}[✘] $1${RESET}"
}

success_msg() {
    echo -e "${GREEN}${BOLD}[✓] $1${RESET}"
}

spinner() {
    local pid=$1
    local msg=$2
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %8 ))
        printf "\r${YELLOW}${BOLD}[%s] %s${RESET}" "${spin:$i:1}" "$msg"
        sleep 0.1
    done
    printf "\r${GREEN}${BOLD}[✔] %s${RESET}\n" "$msg"
}

# ================= MULAI SCRIPT =================
print_banner
line
echo -e "${WHITE}${BOLD}   Target Python  : ${YELLOW}3.13.5${RESET}"
echo -e "${WHITE}${BOLD}   Target Package  : ${YELLOW}@whiskeysockets/baileys, @hapi/boom, pino, qrcode-terminal${RESET}"
line
echo ""

# ---------- CEK TERMUX ----------
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    error_msg "Script ini hanya bisa dijalankan di Termux!"
    exit 1
fi

# ---------- UPDATE & UPGRADE PACKAGE ----------
step_run "Memperbarui daftar package Termux..."
pkg update -y > /tmp/fixlog.txt 2>&1 &
spinner $! "Update repository Termux"

step_run "Meng-upgrade package Termux..."
pkg upgrade -y >> /tmp/fixlog.txt 2>&1 &
spinner $! "Upgrade package Termux"

# ---------- INSTALL DEPENDENSI DASAR ----------
step_run "Menginstall dependency dasar (git, wget, build-essential)..."
pkg install -y git wget curl build-essential python-pip >> /tmp/fixlog.txt 2>&1 &
spinner $! "Install dependency dasar"

line
echo -e "${MAGENTA}${BOLD}   >> PROSES DOWNGRADE PYTHON KE VERSI 3.13.5 <<${RESET}"
line

# ---------- CEK PYTHON VERSION SAAT INI ----------
CURRENT_PY=$(python --version 2>&1 | awk '{print $2}')
echo -e "${CYAN}${BOLD}Versi Python saat ini : ${WHITE}${CURRENT_PY}${RESET}"

# ---------- INSTALL PYENV / MANUAL DOWNGRADE ----------
step_run "Mengecek ketersediaan Python 3.13.5 di repo Termux..."

# Termux tidak selalu punya versi spesifik lewat pkg, maka kita pakai pyenv-alike / build manual
if command -v pyenv >/dev/null 2>&1; then
    step_run "pyenv terdeteksi, menggunakan pyenv untuk downgrade..."
else
    step_run "Menginstall pyenv untuk mengatur versi Python..."
    pkg install -y pyenv >> /tmp/fixlog.txt 2>&1 &
    spinner $! "Install pyenv"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" 2>/dev/null
fi

step_run "Menginstall Python 3.13.5 (proses ini bisa memakan waktu lama)..."
if command -v pyenv >/dev/null 2>&1; then
    pyenv install 3.13.5 >> /tmp/fixlog.txt 2>&1 &
    spinner $! "Compile & install Python 3.13.5"
    pyenv global 3.13.5 >> /tmp/fixlog.txt 2>&1
    success_msg "Python berhasil di-set ke versi 3.13.5 (via pyenv)"
else
    error_msg "pyenv tidak tersedia. Mencoba fallback pkg install python versi tertentu..."
    pkg install -y python=3.13.5* >> /tmp/fixlog.txt 2>&1 &
    spinner $! "Fallback install python 3.13.5"
fi

NEW_PY=$(python --version 2>&1)
line
echo -e "${GREEN}${BOLD}Python sekarang    : ${WHITE}${NEW_PY}${RESET}"
line

# ================= NODEJS & NPM CHECK =================
echo ""
echo -e "${MAGENTA}${BOLD}   >> INSTALL DEPENDENCY NPM UNTUK X-VALEZ <<${RESET}"
line

if ! command -v node >/dev/null 2>&1; then
    step_run "Node.js belum terpasang, menginstall Node.js..."
    pkg install -y nodejs >> /tmp/fixlog.txt 2>&1 &
    spinner $! "Install Node.js"
else
    step "Node.js sudah terpasang: $(node -v)"
fi

if ! command -v npm >/dev/null 2>&1; then
    step_run "npm belum terpasang, menginstall npm..."
    pkg install -y nodejs-lts >> /tmp/fixlog.txt 2>&1 &
    spinner $! "Install npm"
else
    step "npm sudah terpasang: $(npm -v)"
fi

# ---------- INSTALL PACKAGE NPM ----------
step_run "Menjalankan npm install untuk dependency Baileys..."
echo -e "${YELLOW}   Package: @whiskeysockets/baileys @hapi/boom pino qrcode-terminal${RESET}"
echo ""

npm install @whiskeysockets/baileys @hapi/boom pino qrcode-terminal --no-bin-links > /tmp/npmlog.txt 2>&1 &
NPM_PID=$!
spinner $NPM_PID "Installing npm packages (baileys, boom, pino, qrcode-terminal)"
wait $NPM_PID
NPM_STATUS=$?

line
if [ $NPM_STATUS -eq 0 ]; then
    success_msg "Semua package npm berhasil diinstall!"
else
    error_msg "Terjadi kesalahan saat install npm. Cek log di /tmp/npmlog.txt"
fi
line

# ================= RINGKASAN AKHIR =================
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║              ${WHITE}RINGKASAN PERBAIKAN X-VALEZ${CYAN}          ║${RESET}"
echo -e "${CYAN}${BOLD}╠══════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}${BOLD}║${RESET} Python Version   : ${GREEN}${NEW_PY}${RESET}"
echo -e "${CYAN}${BOLD}║${RESET} Node Version     : ${GREEN}$(node -v 2>/dev/null)${RESET}"
echo -e "${CYAN}${BOLD}║${RESET} NPM Version      : ${GREEN}$(npm -v 2>/dev/null)${RESET}"
echo -e "${CYAN}${BOLD}║${RESET} Baileys Package  : ${GREEN}Terinstall${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${MAGENTA}${BOLD}   Semua proses selesai! Script X-ValeZ siap dijalankan.${RESET}"
echo -e "${YELLOW}${BOLD}   Log lengkap tersimpan di: /tmp/fixlog.txt & /tmp/npmlog.txt${RESET}"
echo ""
line
echo -e "${WHITE}${BOLD}Woy puki udah selesai nih ya! Silahkan jalankan:${RESET}"
echo -e "${GREEN}1. Ketik: exit${RESET}"
echo -e "${GREEN}2. Kalau udah keluar, silahkan jalankan script-nya${RESET}"
line