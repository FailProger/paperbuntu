#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}" &&
  -z "${PASSWORD:-}" &&
  -z "${DISK_NAME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Imports
if [[ -z "${REPO_URL:-}" ]]; then
  source "$ROOT_DIR/config/config.sh"
fi
source "$ROOT_DIR/lib/disk.sh"
source "$ROOT_DIR/lib/file.sh"

chroot_configure_system() {
  trap 'umount_disk 1' SIGINT SIGTERM
  
  # Mount system
  mount --bind /dev /mnt/dev
  mount --bind /dev/pts /mnt/dev/pts
  mount -t proc proc /mnt/proc
  mount -t sysfs sys /mnt/sys
  mount --bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
  cp /etc/resolv.conf /mnt/etc/resolv.conf
  
  # Copy repo
  local repo_dir="/mnt/tmp/${REPO_URL##*/}"
  mk_dir "$repo_dir"
  cp -r "$ROOT_DIR"/* "$repo_dir"

  # Configure system
  chroot /mnt /bin/bash "${repo_dir#/mnt}/configure.sh" -u "$USERNAME" -p "$PASSWORD" -d "$DISK_NAME"

  umount_disk

  reboot
}
