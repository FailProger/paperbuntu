#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
INSTALL_DEPENDENCIES=(
  "curl"
  "zip"
  "unzip"
  "fontconfig"
)
BASE_PACKS=(
  "linux-image-generic"
  "linux-headers-generic"
  "sudo"
)
USERS_PACKS=("network-manager")

# Imports
source "$ROOT_DIR/lib/file.sh"

install_kernel() {
  # Install base
  export DEBIAN_FRONTEND=noninteractive  # Env for noninteractive keyboard-configuration
  apt update &&
    apt install -y ${BASE_PACKS[@]} && unset BASE_PACKS

  unset DEBIAN_FRONTEND
}

instsall_bootloader() {
  apt update && apt install -y grub-efi-amd64
  
  # Install grub
  local repo_name=${REPO_URL##*/}
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=${repo_name^}
  update-grub
}

install_users_packs() {
  apt update &&
    apt install -y ${USERS_PACKS[@]} && unset USERS_PACKS

  # Install Nerd Fonts
  local nerd_fonts_dir=$(mk_dir "/usr/local/share/fonts/hack-nerd-font/")
  curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
  unzip Hack.zip -d "$nerd_fonts_dir"
  rm Hack.zip
  rm "$nerd_fonts_dir/LICENSE.md" "$nerd_fonts_dir/README.md"
  chmod -R 644 $nerd_fonts_dir/*
  chmod +x $nerd_fonts_dir
  fc-cache -fv
}
