#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${DISK_NAME:-}" &&
  -z "${USERNAME:-}" &&
  -z "${PASSWORD:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly DBS_DEPENDENCIES=("debootstrap" "parted" "zip" "unzip")

# Imports
if [[ -z "${REPO_URL:-}" ]]; then
  source "$ROOT_DIR/config/config.sh"
fi
source "$ROOT_DIR/lib/disk.sh"
source "$ROOT_DIR/lib/system.sh"

debootstrap_install_system() {
  # Install dependencies
  apt update &&
    apt install -y ${DBS_DEPENDENCIES[@]}

  # Part and format disk
  if is_uefi; then
    _part_disk_uefi && _format_disk_uefi && _mount_disk_uefi
  else
    _part_disk_bios && _format_disk_bios && _mount_disk_bios
  fi

  trap 'umount_disk 1' SIGINT SIGTERM

  # Install base system
  debootstrap --arch="$ARCH" --variant="$VARIANT" "$RELEASE" /mnt "$MIRROR"
}

_part_disk_uefi() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel gpt
  parted "$disk" mkpart ESP fat32 1MiB 513MiB
  parted "$disk" set 1 esp on
  parted "$disk" mkpart root ext4 513MiB 100%
}

_format_disk_uefi() {
  local efi=$(get_disk_part_path "$DISK_NAME" '1')
  local root=$(get_disk_part_path "$DISK_NAME" '2')
  
  # Format partitions
  mkfs.fat -F 32 "$efi"
  mkfs.ext4 -F "$root"
}

_mount_disk_uefi() {
  local efi=$(get_disk_part_path "$DISK_NAME" '1')
  local root=$(get_disk_part_path "$DISK_NAME" '2')

  # Mount partitions
  mount $root /mnt
  mkdir -p /mnt/boot/efi
  mount $efi /mnt/boot/efi
}

_part_disk_bios() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel msdos
  parted "$disk" mkpart primary ext4 1MiB 100%
  parted "$disk" set 1 boot on
}

_format_disk_bios() {
  local root=$(get_disk_part_path "$DISK_NAME" '1')
  
  # Format partitions
  mkfs.ext4 -F "$root"
}

_mount_disk_bios() {
  local root=$(get_disk_part_path "$DISK_NAME" '1')

  # Mount partitions
  mount $root /mnt
}
