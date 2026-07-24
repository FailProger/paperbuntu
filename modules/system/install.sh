#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${DISK_NAME:-}" &&
  -z "${REPO_URL:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly SYS_BASE_PACKS=(
  'linux-image-generic'
  'linux-headers-generic'
  'sudo'
)
readonly SYS_USERS_PACKS=('network-manager')

# Imports
source "$ROOT_DIR/lib/system.sh"

install_kernel() {
  # Install base
  apt update &&
    apt install -y ${SYS_BASE_PACKS[@]}
}

instsall_bootloader() {
  apt update

  if is_uefi; then
    _install_grub_uefi
  else
    _install_grub_bios
  fi
  
  update-grub
}

_install_grub_uefi() {
  apt install -y grub-efi-amd64
  
  # Install grub
  local repo_name=${REPO_URL##*/}
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="${repo_name}"
}

_install_grub_bios() {
  apt install -y grub-pc
  
  # Install grub
  grub-install --target=i386-pc "/dev/$DISK_NAME"
}

install_users_packs() {
  apt update &&
    apt install -y ${SYS_USERS_PACKS[@]}
}
