cd $HOME
e="echo -e "

g="\033[32;1m"
c="\033[36;1m"
r="\033[31;1m"
y="\033[33;1m"
a="\033[90;1m"
n="\033[0m"

: 'Pembuat : ViewTech Official'
: 'Pengembangan : Adrianzz324'

detect_home() {
if [ -n "$ZSH_VERSION" ]; then
    echo "$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    echo "$HOME/.bashrc"
else
    echo "$HOME/.bashrc"
fi
}

konfigurasi=$(detect_home)

pyversion=$(python --version 2>&1)

if (grep -o "3.13" <<< "$pyversion") &>/dev/null; then
  clear 
  echo ""
  $e "${r}[ ${g}✓ ${r}]${c} Python saat ini sudah ada di versi 3.13"
  echo ""
  exit 1
fi

if (test -z "$(command -v pyenv)"); then
  clear 
  echo ""
  $e "${r}[ ${g}+ ${r}]${c} Downgrade py ${pyversion} -> 3.13.5"
  $e "${n}"
  [ -d "$HOME/.pyenv" ] && rm -rf "$HOME/.pyenv"  
  curl -s https://pyenv.run | bash
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $konfigurasi
  echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> $konfigurasi
  echo 'eval "$(pyenv init -)"' >> $konfigurasi
  source $konfigurasi
else
  [ -d "$HOME/.pyenv" ] && rm -rf "$HOME/.pyenv"
fi
echo ""
$e "${r}[ ${g}+ ${r}]${y} Python install pyenv memerlukan waktu 2 jam."
$e "${n}"
export CPPFLAGS="-Wno-error=implicit-function-declaration -Wno-implicit-function-declaration -Wno-error=int-conversion -Wno-int-conversion"
export LDFLAGS="-latomic"
export ac_cv_func_getpwent=no
export ac_cv_func_copy_file_range=no
export ac_cv_func_sendfile=no
export ac_cv_func_posix_spawn=no
export ac_cv_func_posix_spawnp=no
export PYTHON_CONFIGURE_OPTS="--disable-shared"
pyenv install 3.13.5

echo ""
$e "${r}[ ${g}>> ${r}]${g} Python versi 3.13 sudah berhasil di install"
$e "${r}[ ${g}>> ${r}]${c} Jalankan perintah berikut 👇👇"
$e "${r}[ ${g}>> ${r}]${c} ~/.pyenv/versions/3.13.5/bin/python --version"
$e "${r}[ ${g}>> ${r}]${c} exit"
echo ""
