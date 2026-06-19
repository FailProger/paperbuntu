#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly GRAPHIC_INSTALL_DEPENDENCIES=(
  'wget'
  'zip'
  'unzip'
)
readonly GRAPHIC_PACKS=(
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

install_all() {
  # Install dependencies and graphic packs from apt
  apt update &&
    apt install -y ${GRAPHIC_INSTALL_DEPENDENCIES[@]} &&
    apt install -y ${GRAPHIC_PACKS[@]}
  
  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Install other graphic packs
  _install_fonts
  
  cd "$past_dir"
  rm -rf "$tmp_dir"
}

_install_fonts() {
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
