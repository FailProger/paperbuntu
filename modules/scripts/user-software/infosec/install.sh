# Script params
readonly USER_SOFTWARE_INFOSEC__INSTALL_DEPENDENCIES=(
  'wget'
  'git'
  'unzip'
  'gzip'
  'build-essential'
  'openssl'
  'libssl-dev'
  'libssh-dev'
  'libssh2-1-dev'
  'libidn11-dev'
  'libpcre2-dev'
  'libgtk2.0-dev'
  'libmysqlclient-dev'
  'libpq-dev'
  'libsvn-dev'
  'firebird-dev'
  'libmemcached-dev'
  'libgpg-error-dev'
  'libsmbclient'
  'libncurses5-dev'
  'libncursesw5-dev'
  'yasm'
  'pciutils'
  'openjdk-21-jdk'
)
readonly USER_SOFTWARE_INFOSEC__INSTALL_PACKAGES=(
  'xxd'
  'hexedit'
  'steghide'
  'libimage-exiftool-perl'
  'ltrace'
  'strace'
)

user_software_infosec__install_all() {
  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Install infosec tools
  # Enumeration
  _install_nmap

  # Hashes
  _install_hashcat; _install_john

  # Passwords
  _download_seclists

  # Web
  _install_dirsearch; _install_feroxbuster; _install_ffuf; _install_hydra

  # Wireless
  _install_aircrack-ng; _install_wifit3

  # Analyzing
  _install_wireshark
  
  # Exploitation
  _install_metasploit

  # Clients
  _install_smbclient; _install_ftp; _install_enum4linux

  # Steganography
  _install_binwalk; _install_stegseek

  # Reverse Engineering
  _install_ghidra
  
  lib__normalize_local_bin

  cd "$past_dir"
  rm -rf "$tmp_dir"
}

_install_nmap() {
  git clone --depth 1 'https://github.com/nmap/nmap'
  cd nmap

  ./configure
  make; make install
  
  cd ..
  rm -rf nmap
}

_install_hydra() {
  git clone --depth 1 'https://github.com/vanhauser-thc/thc-hydra'
  cd thc-hydra

  ./configure
  make; make install

  cd ..
  rm -rf thc-hydra
}

_install_hashcat() {
  apt install -y hashcat
}

_install_john() {
  git clone --depth 1 'https://github.com/openwall/john'
  cd john/src

  ./configure
  make -s clean; make -sj4

  cd ..

  lib__mk_dir /opt
  local john_dir='/opt/john-the-ripper'
  mv ./run "$john_dir"

  cd ..
  rm -rf john
}

_download_seclists() {
  local seclists_dir='/usr/local/share/seclists'
  git clone --depth 1 'https://github.com/danielmiessler/SecLists' "$seclists_dir"
}

_install_dirsearch() {
  git clone --depth 1 'https://github.com/maurosoria/dirsearch'
  cd dirsearch

  rm -rf .git .github .gitignore AGENTS.md CHANGELOG.md CONTRIBUTORS.md README.md docs tests testing.py 
  
  # Get system python version like 3.XX
  local py_ver=$(python3 -V | cut -f 2 -d ' ')
  py_ver=${py_ver/%.[0-9]/}
  # Install python dependencies for dirsearch
  apt install -y "python$py_ver-venv" "libpython$py_ver"

  python3 -m venv .venv
  ./.venv/bin/pip install -r requirements.txt
  
  cd ..
  
  lib__mk_dir /opt
  local ds_dir='/opt/dirsearch'
  mv ./dirsearch "$ds_dir"
}

_install_feroxbuster() {
  lib__wget_download 'https://github.com/epi052/feroxbuster/releases/latest/download/feroxbuster_amd64.deb.zip'

  unzip feroxbuster*.deb.zip
  rm feroxbuster*.deb.zip
  
  apt install ./feroxbuster*.deb

  rm feroxbuster*.deb
}

_install_ffuf() {
  lib__wget_github_repo_download_latest 'ffuf/ffuf' 'ffuf_.*_linux_amd64.tar.gz'
  lib__mv_to_local_bin 'ffuf'
}

_install_aircrack-ng() {
  apt install -y aircrack-ng
}

_install_wifit3() {
  lib__wget_download 'https://github.com/derv82/wifit3/releases/latest/download/wifit3-linux-x64'

  chmod 755 wifit3-linux-x64
  mv wifit3-linux-x64 /usr/local/bin/wifit3
}

_install_wireshark() {
  apt install -y wireshark
}

_install_metasploit() {
  lib__wget_download 'https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb'
  chmod 755 msfupdate.erb
  
  ./msfupdate.erb
}

_install_smbclient() {
  apt install -y smbclient
}

_install_ftp() {
  apt install -y ftp
}

_install_enum4linux() {
  lib__wget_download 'https://raw.githubusercontent.com/CiscoCXSecurity/enum4linux/master/enum4linux.pl'
  
  chmod 755 enum4linux.pl
  mv enum4linux.pl /usr/local/bin/enum4linux
}

_install_binwalk() {
  apt install -y binwalk --no-install-recommends
}

_install_stegseek() {
  lib__wget_github_repo_download_latest 'RickdeJager/stegseek' 'stegseek_.*-1.deb'
  apt install -y ./stegseek_*-1.deb
}

_install_ghidra() {
  lib__wget_github_repo_download_latest 'NationalSecurityAgency/ghidra' 'ghidra_.*_PUBLIC_.*.zip'

  lib__mk_dir /opt
  unzip ghidra*.zip -d /opt
  mv /opt/ghidra* /opt/ghidra

  rm ghidra*.zip
}

