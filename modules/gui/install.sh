#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly GUI_INSTALL_DEPENDENCIES=(
  'sudo'
  'wget'
  'xz-utils'
  'cmake'
  'g++'
  'pkg-config'
  'libfontconfig1-dev'
  'libxcb-xfixes0-dev'
  'libxkbcommon-dev'
)

# Imports
source "$ROOT_DIR/lib/utils.sh"

install_all() {
  # Install dependencies
  apt update &&
    apt install -y ${GUI_INSTALL_DEPENDENCIES[@]}
  
  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Install gui programms
  _install_alacritty; _install_zen_browser;
  
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

rustup override set stable && rustup update stable
cargo build --release
EOF

  mv "$HOME/alacritty/target/release/alacritty" /usr/local/bin/alacritty
  rm -rf "$HOME/*alacritty*"
}

_install_zen_browser() {
  download 'https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz'
  
  mk_dir /opt
  tar -xf 'zen'* -C /opt
  ln -s /opt/zen/zen /usr/local/bin/zen

  cat > /usr/share/applications/zen.desktop << EOF
[Desktop Entry]
Version=$(/opt/zen/zen --version | cut -f 3 -d ' ')
Name=Zen
Comment=Beautifully designed, privacy-focused, and packed with features.
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=zen
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/zen/browser/chrome/icons/default/default128.png
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

  rm -rf *'zen'*
}
