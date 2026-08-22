# Script params
readonly USER_SOFTWARE_DESKTOP__INSTALL_DEPENDENCIES=(
  'wget'
  'zip'
  'unzip'
)
readonly USER_SOFTWARE_DESKTOP__INSTALL_PACKAGES=(
  'xorg'
  'i3'
  'i3status'
  'dmenu'
  'j4-dmenu-desktop'
  'feh'
  'sddm'
)

# Imports
source "$ROOT_DIR/lib/user.sh"
source "$ROOT_DIR/lib/utils.sh"

user_software_desktop__install_all() {
  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Install other desktop environment packs
  _user_software_desktop__install_fonts
  
  cd "$past_dir"
  rm -rf "$tmp_dir"
}

_user_software_desktop__install_fonts() {
  # Install Hack Nerd Font
  local nerd_fonts_dir='/usr/local/share/fonts/hack-nerd-font/'
  mk_dir "$nerd_fonts_dir"
  
  wget_download 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip'
  unzip 'Hack.zip' -d "$nerd_fonts_dir"
  
  rm 'Hack.zip'
  rm "$nerd_fonts_dir/LICENSE.md" "$nerd_fonts_dir/README.md"
  
  chmod -R 644 "$nerd_fonts_dir"/*
  chmod 755 "$nerd_fonts_dir"
}
