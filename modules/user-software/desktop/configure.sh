# Script params
readonly USER_SOFTWARE_DESKTOP__CONFIGURE_DEPENDENCIES=('fontconfig')

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"

user_software_desktop__configure_all() {
  # Configure all desktop environment packs
  # Desktop
  _user_software_desktop__configure_windows_manager
  _user_software_desktop__configure_statusbar
  _user_software_desktop__configure_wallpaper
  
  # Login
  _user_software_desktop__configure_display_manager
  
  # Other
  _user_software_desktop__configure_fonts
}

# Desktop
_user_software_desktop__configure_windows_manager() {
  cp_config 'i3'
}

_user_software_desktop__configure_statusbar() {
  cp_config 'i3status'
}

_user_software_desktop__configure_wallpaper() {
  local wp_dir="$HOME/.local/share/wallpapers"
  sudo -u "$USERNAME" mkdir -p "$wp_dir"
  
  cp_config 'wallpapers' "$wp_dir/${REPO_URL##*/}"
  
  find "$wp_dir" -type d -exec chmod 755 {} +
  find "$wp_dir" -type f -exec chmod 644 {} +
  chown -R "$USERNAME:$USERNAME" "$wp_dir"
}

# Login
_user_software_desktop__configure_display_manager() {
  local dm_dir='/etc/sddm.conf.d'
  mk_dir "$dm_dir"
  
  cat > "$dm_dir/autologin.conf" << EOF
[Autologin]
User=$USERNAME
Session=i3
EOF
}

# Other
_user_software_desktop__configure_fonts() {
  fc-cache -fv
}

