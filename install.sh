#!/bin/bash

# --- WARNA UTAMA ---
GREEN='\033[38;5;108m'
BLUE='\033[38;5;67m'
RESET='\033[0m'

echo -e "${BLUE}[*] Memulai Pengecekan Dependensi X-ValeZ...${RESET}"

# Fungsi Cek & Install Package System
check_pkg() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${BLUE}[+] Menginstal package: $1...${RESET}"
        apt update -y && apt install $1 -y
    else
        echo -e "${GREEN}[✓] $1 sudah terinstal. Done.${RESET}"
    fi
}

# Fungsi Cek & Install PIP Modules
check_pip() {
    if ! python3 -c "import $1" &> /dev/null; then
        echo -e "${BLUE}[+] Menginstal python module: $1...${RESET}"
        pip install $1
    else
        echo -e "${GREEN}[✓] Python module $1 sudah terinstal. Done.${RESET}"
    fi
}

# Jalankan Verifikasi
check_pkg git
check_pkg python
check_pkg rich
check_pkg zlib
check_pkg curl
check_pkg selenium
# Note: Karena script murni menggunakan standard library bawaan python untuk performa optimal di Termux,
# penambahan modul tambahan pip bersifat opsional jika diperlukan ke depannya.
check_pip requests 2>/dev/null || pip install requests --quiet

echo -e "${GREEN}[✓] Silahkan 'python run.py' dahulu! Enjoy 😖💦${RESET}"
