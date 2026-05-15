#!/usr/bin/env bash

set -eu

if [[ -n "${LIB_DISK_LOADED:-}" ]]; then
  return 0
fi
readonly LIB_DISK_LOADED=1

get_disk_name() {
  local disk_name=$(lsblk | grep disk -m 1 | cut -f 1 -d " ")
  echo "$disk_name"
}

get_disk_parts_names() {
  local disk_name="${1:?'Dont get disk name!'}"
  
  # Get partitions names
  local efi=$(find /dev -name "$disk_name*1")
  local root=$(find /dev -name "$disk_name*2")

  echo "$efi" "$root"
}

mount_disk() {
  local disk_name="${1:?'Dont get disk name!'}"

  local disk_parts_names=$(get_disk_parts_names "$disk_name")
  local efi=$(cut -f 1 -d " " <<< "$disk_parts_names")
  local root=$(cut -f 2 -d " " <<< "$disk_parts_names")

  # Mount partitions
  mount $root /mnt
  mkdir -p /mnt/boot/efi
  mount $efi /mnt/boot/efi
}

umount_disk() {
  local return_code="${1:-0}"
  
  umount -R /mnt 2> /dev/null
  [[ "$return_code" -eq 0 ]] || exit 1
}
