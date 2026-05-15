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
DEPENDENCIES=("debootstrap" "parted")

# Imports
if [[ -z "${REPO_URL:-}" ]]; then
  source "$ROOT_DIR/config.sh"
fi
source "$ROOT_DIR/lib/disk.sh"

debootstrap_install() {
  # Install dependencies
  apt update &&
    apt install -y ${DEPENDENCIES[@]} &&
    unset DEPENDENCIES

  # Part and format disk
  _part_disk && _format_disk

  # Mount disk
  trap 'umount_disk 1' SIGINT SIGTERM && mount_disk "$DISK_NAME"

  # Install base system
  debootstrap --arch="$ARCH" --variant="$VARIANT" "$RELEASE" /mnt "$MIRROR"
}

_part_disk() {
  # Get disk
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa $disk
  parted $disk mklabel gpt
  parted $disk mkpart ESP fat32 1MiB 513MiB
  parted $disk set 1 esp on
  parted $disk mkpart root ext4 513MiB 100%
}

_format_disk() {
  # Get partitions names
  local disk_parts_names=$(get_disk_parts_names "$DISK_NAME")
  local efi=$(cut -f 1 -d " " <<< "$disk_parts_names")
  local root=$(cut -f 2 -d " " <<< "$disk_parts_names")
  
  # Format partitions
  mkfs.fat -F 32 "$efi"
  mkfs.ext4 -F "$root"
}
