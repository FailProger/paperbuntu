# Script params
readonly USER_SOFTWARE_GUI__INSTALL_DEPENDENCIES=(
  'sudo'
  'wget'
  'xz-utils'
  'bzip2'
  'cmake'
  'g++'
  'pkg-config'
  'libfontconfig1-dev'
  'libxcb-xfixes0-dev'
  'libxkbcommon-dev'
)

# Imports
source "$ROOT_DIR/lib/utils.sh"

user_software_gui__install_all() {
  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Terminal emulator
  _install_alacritty
  
  # Web Browsers
  _install_zen_browser
  
  normalize_local_bin
  
  cd "$past_dir"
  rm -rf "$tmp_dir"
}

_install_alacritty() {
  sudo -u "$USERNAME" /usr/bin/bash -s << 'EOF'
cd "$HOME"

git clone --depth 1 'https://github.com/alacritty/alacritty'
cd alacritty

curl --proto '=https' --tlsv1.2 -sSf 'https://sh.rustup.rs' | sh -s -- -y

export PATH="$PATH:$HOME/.cargo/bin"
source "$HOME/.cargo/env"

rustup override set stable
rustup update stable

cargo build --release
EOF

  mv "$HOME/alacritty/target/release/alacritty" /usr/local/bin/alacritty
  rm -rf "$HOME"/*'alacritty'*
}

_install_zen_browser() {
  wget_download 'https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz'
  
  mk_dir /opt
  tar -xf 'zen'* -C /opt
  ln -s /opt/zen/zen /usr/local/bin/zen

  cat > /usr/local/share/applications/zen.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Zen
Comment=Beautifully designed browser
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=zen
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/zen/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

  rm 'zen'*
}

_install_librewolf() {
  apt install -y extrepo
  extrepo enable librewolf && extrepo update librewolf
  
  apt update && apt install -y librewolf
}

_install_waterfox() {
  local latest_version=$(wget_github_repo_latest_version 'BrowserWorks/Waterfox')
  wget_download "https://cdn1.waterfox.net/waterfox/releases/$latest_version/Linux_x86_64/waterfox-$latest_version.tar.bz2"
  
  mk_dir /opt
  tar -xf 'waterfox'* -C /opt
  ln -s /opt/waterfox/waterfox /usr/local/bin/waterfox

  cat > /usr/local/share/applications/waterfox.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Waterfox
Comment=Privacy-focused browser
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=waterfox
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/waterfox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

  rm 'waterfox'*
}

