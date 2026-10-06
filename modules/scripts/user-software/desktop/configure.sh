# Script params
readonly USER_SOFTWARE_DESKTOP__CONFIGURE_DEPENDENCIES=(
  'sudo'
  'fontconfig'
)

user_software_desktop__configure_all() {
  # Configure all desktop environment packs
  # Desktop
  _user_software_desktop__configure_windows_manager
  _user_software_desktop__configure_visual_compouser
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

_user_software_desktop__configure_visual_compouser() {
  cp_config 'picom'
}

_user_software_desktop__configure_statusbar() {
  cp_config 'polybar'

  chmod 700 "$HOME/.config/polybar/launch.sh"
}

_user_software_desktop__configure_wallpaper() {
  local share_dir="$HOME/.local/share"
  sudo -u "$USERNAME" mkdir -p "$share_dir"
  
  cp_config 'wallpapers' "$share_dir"

  cat > "$HOME/.fehbg" << 'EOF'
#!/bin/sh
feh --no-fehbg --bg-fill "$HOME/.local/share/wallpapers/nothing2-21x9.png"
EOF
  chmod 700 "$HOME/.fehbg"; chown "$USERNAME:$USERNAME" "$HOME/.fehbg"

  local wp_dir="$share_dir/wallpapers"
  
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

