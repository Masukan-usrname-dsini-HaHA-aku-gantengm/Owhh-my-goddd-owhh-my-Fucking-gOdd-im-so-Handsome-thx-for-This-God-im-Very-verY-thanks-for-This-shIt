# -*- coding: utf-8 -*-
import os
import sys
import json
import time
import re
import subprocess
from datetime import datetime

# --- PALET WARNA (Lebih Terang & Mencolok) ---
C_RESET = "\033[0m"
C_BOLD = "\033[1m"
C_MAIN = "\033[1;36m"      # Cyan Terang
C_ACCENT = "\033[1;33m"    # Kuning Terang (Accent)
C_YELLOW = "\033[1;33m"    # Kuning Terang (Fix NameError)
C_GREEN = "\033[1;32m"     # Hijau Terang
C_RED = "\033[1;31m"       # Merah Terang
C_BLOOD = "\033[38;5;196m" # Merah Darah Lighting (Glow Red)
C_TEXT = "\033[1;37m"      # Putih Terang
C_DARK = "\033[1;30m"      # Abu Gelap (untuk border/garis)

# --- KONFIGURASI & PATH ---
TARGET_DIR = "/data/data/com.termux/files/usr/.x"
if not os.path.exists("/data/data/com.termux/files/usr"): 
    TARGET_DIR = os.path.join(os.path.expanduser("~"), ".x") # Fallback jika di luar Termux

os.makedirs(TARGET_DIR, exist_ok=True)
DB_PATH = os.path.join(TARGET_DIR, "users_db.json")
SESSION_PATH = os.path.join(TARGET_DIR, "session.json")

VERSION = "1.0.0-beta"
AUTHOR = "HexZ Team"
WEBSITE = "https://hexzstore.vercel.app/"

# --- TEMPLATE MENU ---
listMenu = {
    "Downloader All": [
        {
            "name": "Downloader Status WA",
            "repo": "https://github.com/WoY-aPa-KaBaR-tEmAnKu-wlkWokWKWKWK6767/SwSaverAhahahahahkwbdoej2o2broffjfjre394i5jttjtj-wait-AdrianzzItuGantengGakSiehhHahaha",
            "file": "swsaver.py",
            "after": "haloOrangNggakBertanggungJawab"
        }
    ],
    "Hacking": [
        {
            "name": "Wifi Killer",
            "repo": "https://github.com/WoY-aPa-KaBaR-tEmAnKu-wlkWokWKWKWK6767/WifiKiller-Aduhhh-jangan-kesini-lah-wokwokwokwokwowk-thx-",
            "file": "wifi.py",
            "after": "mauNgapainAnjing"
        }
    ]
}

# --- DATABASE ENGINE (LOCAL) ---
def load_json(path, default=None):
    if default is None: default = {}
    if os.path.exists(path):
        try:
            with open(path, 'r') as f: return json.load(f)
        except: return default
    return default

def save_json(path, data):
    with open(path, 'w') as f: json.dump(data, f, indent=4)

if not os.path.exists(DB_PATH):
    save_json(DB_PATH, {"users": {}})

def sync_git_pull():
    if os.path.exists(".git"):
        try:
            subprocess.run(["git", "pull"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except: pass

# --- UI HELPERS ---
def clear():
    os.system('clear' if os.name != 'nt' else 'cls')

def draw_line(char="═", length=54):
    print(f"{C_MAIN}{char * length}{C_RESET}")

def print_box(text, color=C_ACCENT):
    length = len(text) + 2
    print(f"{color}╔{'═' * length}╗")
    print(f"║ {C_TEXT}{text}{color} ║")
    print(f"╚{'═' * length}╝{C_RESET}")

def show_logo():
    logo = f"""{C_BLOOD}{C_BOLD}
██╗ ██╗ ██╗ ██╗ █████╗ ██╗ ███████╗███████╗
╚██╗██╔╝ ██║ ██║██╔══██╗██║ ██╔════╝╚══███╔╝
╚███╔╝█████╗██║ ██║███████║██║ █████╗ ███╔╝ 
██╔██╗╚════╝╚██╗ ██╔╝██╔══██║██║ ██╔══╝ ███╔╝ 
██╔╝ ██╗ ╚████╔╝ ██║ ██║███████╗███████╗███████╗
╚═╝ ╚═╝ ╚═══╝ ╚═╝ ╚═╝╚══════╝╚══════╝╚══════╝{C_RESET}
          {C_MAIN}v{VERSION} | By {AUTHOR}{C_RESET}"""
    print(logo)

# --- FLOW UTAMA ---
def main():
    sync_git_pull()
    session = load_json(SESSION_PATH)
    
    if "username" in session:
        db = load_json(DB_PATH)
        if session["username"] in db.get("users", {}):
            dashboard(session["username"])
        else:
            os.remove(SESSION_PATH)
            auth_screen()
    else:
        auth_screen()

# --- AUTHENTICATION FLOW ---
def auth_screen():
    while True:
        clear()
        show_logo()
        print()
        draw_line()
        print(f" {C_BOLD}{C_ACCENT}[1]{C_RESET} {C_TEXT}Login{C_RESET}")
        print(f" {C_BOLD}{C_ACCENT}[2]{C_RESET} {C_TEXT}Register (Buat Akun Baru){C_RESET}")
        print(f" {C_BOLD}{C_ACCENT}[0]{C_RESET} {C_TEXT}Keluar{C_RESET}")
        draw_line()
        
        choice = input(f"{C_MAIN}Pilih Opsi: {C_RESET}").strip()
        
        if choice == "1":
            login_page()
            break
        elif choice == "2":
            register_page()
            break
        elif choice == "0":
            sys.exit(0)

def login_page():
    clear()
    show_logo()
    print_box("LOGIN X-ValeZ", C_MAIN)
    username = input(f" {C_TEXT}Username: {C_RESET}").strip()
    password = input(f" {C_TEXT}Password: {C_RESET}").strip()
    
    db = load_json(DB_PATH)
    user = db.get("users", {}).get(username)
    
    if user and user["password"] == password:
        save_json(SESSION_PATH, {"username": username})
        print(f"\n{C_GREEN}[✓] Login berhasil!{C_RESET}")
        time.sleep(1)
        dashboard(username)
    else:
        print(f"\n{C_RED}[!] Username atau Password salah!{C_RESET}")
        time.sleep(1.5)
        auth_screen()

def register_page():
    clear()
    show_logo()
    print_box("REGISTRATION", C_ACCENT)
    print(f"{C_TEXT} Silahkan buat akun untuk mengakses tools X-ValeZ.{C_RESET}\n")
    
    db = load_json(DB_PATH)
    
    while True:
        username = input(f"{C_MAIN} Masukan Username (Max 7 Chars): {C_RESET}").strip()
        if len(username) > 7:
            print(f" {C_RED}[!] Terlalu panjang! Maksimal 7 karakter.{C_RESET}")
        elif not username.isalnum():
            print(f" {C_RED}[!] No spasi/simbol/emoji! Hanya huruf & angka.{C_RESET}")
        elif username in db.get("users", {}):
            print(f" {C_RED}[!] Username sudah terpakai! Cari nama lain.{C_RESET}")
        else:
            break
            
    while True:
        password = input(f"{C_MAIN} Masukan Password: {C_RESET}").strip()
        if len(password) < 4:
            print(f" {C_RED}[!] Password minimal 4 karakter.{C_RESET}")
        else:
            break
            
    user_id = f"XVZ-{int(time.time()) % 100000}"
    
    db["users"][username] = {
        "password": password,
        "id": user_id,
        "score": 0
    }
    save_json(DB_PATH, db)
    
    save_json(SESSION_PATH, {"username": username})
    print(f"\n{C_GREEN}[✓] Akun berhasil dibuat! Mengalihkan ke dashboard...{C_RESET}")
    time.sleep(1.5)
    dashboard(username)

# --- USER DASHBOARD ---
def dashboard(username):
    while True:
        try:
            clear()
            show_logo()
            
            db = load_json(DB_PATH)
            user_info = db.get("users", {}).get(username, {"id": "-", "score": 0})
            total_users = len(db.get("users", {}))
            
            now = datetime.now()
            date_str = now.strftime("%d:%B:%Y")
            time_str = now.strftime("%H:%M:%S")
            
            print()
            print(f"{C_MAIN}╔═[ PROFILE & INFO ]════════════════════════════════════╗")
            print(f"║ {C_TEXT}User     : {C_BOLD}{C_TEXT}{username:<37}{C_RESET} {C_MAIN}║")
            print(f"║ {C_TEXT}ID       : {C_TEXT}{user_info['id']:<37}{C_RESET} {C_MAIN}║")
            print(f"║ {C_TEXT}Reg Users: {C_TEXT}{str(total_users):<37}{C_RESET} {C_MAIN}║")
            print(f"║ {C_TEXT}Score    : {C_GREEN}{str(user_info.get('score', 0)):<37}{C_RESET} {C_MAIN}║")
            print(f"║ {C_TEXT}Date     : {C_TEXT}{date_str:<37}{C_RESET} {C_MAIN}║")
            print(f"║ {C_TEXT}Time     : {C_TEXT}{time_str:<37}{C_RESET} {C_MAIN}║")
            print(f"║ {C_TEXT}Web      : {C_TEXT}{WEBSITE:<37}{C_RESET} {C_MAIN}║")
            print(f"╚═══════════════════════════════════════════════════════╝{C_RESET}")
            
            menu_mapping = {}
            current_index = 1
            
            # Print List Menu Dinamis A-Z
            for label in sorted(listMenu.keys()):
                print()
                print_box(label, C_ACCENT)
                sorted_items = sorted(listMenu[label], key=lambda x: x['name'])
                for item in sorted_items:
                    print(f"   {C_MAIN}[{current_index}]{C_RESET} {C_TEXT}{item['name']}{C_RESET}")
                    menu_mapping[current_index] = item
                    current_index += 1
                    
            # Print Menu Pengaturan
            print()
            print_box("Pengaturan & Informasi", C_YELLOW)
            print(f"   {C_MAIN}[ln]{C_RESET} {C_TEXT}Lainnya / Hubungi Media Sosial{C_RESET}")
            print(f"   {C_MAIN}[du]{C_RESET} {C_TEXT}Daftar Nama User Terdaftar{C_RESET}")
            print(f"   {C_MAIN}[ls]{C_RESET} {C_TEXT}Leaderboard Score Terbanyak{C_RESET}")
            print(f"   {C_MAIN}[ha]{C_RESET} {C_TEXT}Hapus Akun Permanen{C_RESET}")
            print(f"   {C_MAIN}[lo]{C_RESET} {C_TEXT}Log Out Akun{C_RESET}")
            print(f"   {C_MAIN}[0]{C_RESET}  {C_TEXT}Keluar Aplikasi{C_RESET}")
            
            print()
            choice = input(f"{C_MAIN}Pilih Opsi ID/Menu: {C_RESET}").strip().lower()
            if not choice: continue
            
            if choice == "0":
                print(f"\n{C_GREEN}Terima kasih telah menggunakan X-ValeZ!{C_RESET}")
                sys.exit(0)
            elif choice == "lo":
                if os.path.exists(SESSION_PATH): os.remove(SESSION_PATH)
                print(f"\n{C_YELLOW}[✓] Berhasil Log Out!{C_RESET}"); time.sleep(1)
                auth_screen()
                break
            elif choice == "ha":
                confirm = input(f"\n{C_RED}[!] Yakin hapus akun permanen? (y/N): {C_RESET}").strip().lower()
                if confirm == 'y':
                    if username in db["users"]: del db["users"][username]
                    save_json(DB_PATH, db)
                    if os.path.exists(SESSION_PATH): os.remove(SESSION_PATH)
                    print(f"{C_GREEN}[✓] Akun berhasil dihapus!{C_RESET}"); time.sleep(1)
                    auth_screen()
                    break
            elif choice == "ls":
                clear()
                show_logo()
                print_box("LEADERBOARD SCORE", C_YELLOW)
                top_users = sorted(db.get("users", {}).items(), key=lambda x: x[1].get("score", 0), reverse=True)[:10]
                for idx, (uname, data) in enumerate(top_users, 1):
                    print(f"  {C_MAIN}[{idx}]{C_RESET} {C_TEXT}{uname:<15} {C_MAIN}->{C_RESET} Score: {C_GREEN}{data.get('score', 0)}{C_RESET}")
                print()
                input(f"{C_DARK}Tekan Enter untuk kembali...{C_RESET}")
            elif choice == "du":
                clear()
                show_logo()
                print_box("REGISTERED USERS", C_ACCENT)
                for idx, uname in enumerate(sorted(db.get("users", {}).keys()), 1):
                    print(f"  {C_MAIN}[{idx}]{C_RESET} {C_TEXT}{uname}{C_RESET}")
                print()
                input(f"{C_DARK}Tekan Enter untuk kembali...{C_RESET}")
            elif choice == "ln":
                clear()
                show_logo()
                print_box("MEDIA SOSIAL & LINK", C_MAIN)
                print(f" {C_ACCENT}•{C_RESET} {C_TEXT}TikTok : tiktok.com/@adrianzz3241{C_RESET}")
                print(f" {C_ACCENT}•{C_RESET} {C_TEXT}YouTube: youtube.com/@adrianzz324{C_RESET}")
                print(f" {C_ACCENT}•{C_RESET} {C_TEXT}GitHub : github.com/Adrianzz324{C_RESET}")
                print(f" {C_ACCENT}•{C_RESET} {C_TEXT}Web    : {WEBSITE}{C_RESET}")
                print()
                input(f"{C_DARK}Tekan Enter untuk kembali...{C_RESET}")
                
            elif choice.isdigit() and int(choice) in menu_mapping:
                execute_tool(username, menu_mapping[int(choice)])
            else:
                print(f"{C_RED}[!] Pilihan tidak valid.{C_RESET}"); time.sleep(1)
                
        except KeyboardInterrupt:
            print(f"\n{C_YELLOW}[!] Kembali ke dashboard...{C_RESET}")
            time.sleep(1)
            continue

def execute_tool(username, item):
    clear()
    show_logo()
    repo_name = item["repo"].split("/")[-1]
    repo_path = os.path.join(TARGET_DIR, repo_name)
    after_path = os.path.join(TARGET_DIR, item["after"])
    
    print()
    print_box(f"Memproses: {item['name']}", C_GREEN)
    
    if not os.path.exists(after_path) and not os.path.exists(repo_path):
        print(f"{C_TEXT}[+] Mengunduh file sistem...{C_RESET}")
        try:
            subprocess.run(["git", "clone", item["repo"], repo_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
            if os.path.exists(repo_path):
                os.rename(repo_path, after_path)
        except Exception as e:
            print(f"{C_RED}[!] Gagal mengunduh file, pastikan internet lancar.{C_RESET}")
            time.sleep(2)
            return
    else:
        print(f"{C_TEXT}[+] Sinkronisasi pembaruan...{C_RESET}")
        try:
            target_workdir = after_path if os.path.exists(after_path) else repo_path
            subprocess.run(["git", "-C", target_workdir, "pull"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except: pass

    active_path = after_path if os.path.exists(after_path) else repo_path
    script_file = os.path.join(active_path, item["file"])
    
    if os.path.exists(script_file):
        db = load_json(DB_PATH)
        if username in db["users"]:
            db["users"][username]["score"] = db["users"][username].get("score", 0) + 10
            save_json(DB_PATH, db)
            
        print(f"{C_GREEN}[✓] Sukses! Mengaktifkan tools...{C_RESET}\n")
        time.sleep(1)
        try:
            subprocess.run([sys.executable, script_file])
        except KeyboardInterrupt:
            pass
    else:
        print(f"{C_RED}[!] File sistem tidak ditemukan atau korup!{C_RESET}")
        time.sleep(2)

if __name__ == "__main__":
    main()
