#!/bin/bash

clear

# Fungsi untuk mengecek paket sistem (OS)
c_pkg() {
    local pkg=$1
    clear
    echo "[?] Mengecek package sistem: $pkg..."
    
    if command -v "$pkg" &> /dev/null; then
        echo "[+] $pkg sudah terinstall."
    else
        echo "[-] $pkg BELUM terinstall!"
        # Tempatkan perintah install otomatis di sini jika mau
        # Contoh: sudo apt install $pkg -y
    fi
    echo ""
}

# Fungsi untuk mengecek library Python (PIP)
c_pip() {
    local pip_pkg=$1
    clear
    echo "[?] Mengecek library PIP: $pip_pkg..."
    
    # Memastikan python dan pip ada sebelum mengecek
    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        echo "[!] Error: pip atau pip3 tidak ditemukan di sistem!"
        echo ""
        return 1
    fi

    # Cek menggunakan pip show
    if pip3 show "$pip_pkg" &> /dev/null || pip show "$pip_pkg" &> /dev/null; then
        clear
        echo "[+] Library PIP '$pip_pkg' sudah terinstall."
    else
        echo "[-] Library PIP '$pip_pkg' BELUM terinstall! Sedang instalasi..."
        clear
    fi
    echo ""
}

# =========================================================
# CARA PAKAI: Tinggal panggil fungsinya di bawah ini
# =========================================================

# 1. Cek paket aplikasi sistem
c_pkg "python3"
c_pkg "python2"
c_pkg "python"
c_pkg "git"
c_pkg "curl"
c_pkg "xxd"
c_pkg "openssl"
c_pkg "openssh"
c_pkg "wget"
c_pkg "ffmpeg"

# 2. Cek library Python / PIP
c_pip "phonenumbers"
c_pip "requests"
c_pip "colorama"
c_pip "scrapy"

clear
echo "[✓] Semua package & pip siap! Sedang run tools..."
python run.py