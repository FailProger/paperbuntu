user_software_gui__configure_all() {
  # Configure all gui programms

  # Terminal emulator
  _configure_alacritty

  # Web Browsers
  _configure_zen_browser
}

_configure_alacritty() {
  # Configure alacritty
  cp_config 'alacritty'
  update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which alacritty)" 100
}

_configure_zen_browser() {
  # Configure Zen Browser
  ln -s /opt/zen/zen /usr/local/bin/zen

  local applications_dir='/usr/local/share/applications'
  mk_dir "$applications_dir"
  cat > "$applications_dir/zen.desktop" << EOF
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
}

