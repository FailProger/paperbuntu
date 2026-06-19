#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}" &&
  -z "${HOME:-}" &&
  -z "${REPO_URL:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly GRAPHIC_CONFIGURE_DEPENDENCIES=('fontconfig')

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"

configure_all() {
  # Install dependencies
  apt update &&
    apt install -y ${GRAPHIC_CONFIGURE_DEPENDENCIES[@]}
  
  # Configure all graphic packs
  # Desktop
  _configure_windows_manager; _configure_statusbar; _configure_wallpaper
  
  # Login
  _configure_display_manager
  
  # Other
  _configure_fonts
}

_configure_windows_manager() {
  cp_config 'i3'
}

_configure_statusbar() {
  cp_config 'i3status'
}

_configure_wallpaper() {
  local wp_dir="$HOME/.local/share/wallpapers"
  sudo -u "$USERNAME" mkdir -p "$wp_dir"
  
  cp_config 'wallpapers' "$wp_dir/${REPO_URL##*/}"
  
  find "$wp_dir" -type d -exec chmod 755 {} +
  find "$wp_dir" -type f -exec chmod 644 {} +
  chown -R "$USERNAME:$USERNAME" "$wp_dir"
}

_configure_display_manager() {
  local dm_dir='/etc/sddm.conf.d'
  mk_dir "$dm_dir"
  
  cat > "$dm_dir/autologin.conf" << EOF
[Autologin]
User=$USERNAME
Session=i3
EOF
}

_configure_fonts() {
  fc-cache -fv
}
