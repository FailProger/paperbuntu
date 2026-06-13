#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
DEPENDENCIES=('wget' 'bzip2')
GUI_PACKS=('alacritty')

# Imports

install_all() {
  # Install dependencies and gui programms from apt
  apt update &&
    apt install -y ${DEPENDENCIES[@]} && unset DEPENDENCIES &&
    apt install -y ${GUI_PACKS[@]} && unset GUI_PACKS
  
  # Install other gui programms
  _install_zen_browser;
}

_install_zen_browser() {
  wget -qO- 'https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-specific.tar.bz2' | tar xj -C /opt
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
}
