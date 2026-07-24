#!/usr/bin/env bash

set -eu

if [[ -n "${LIB_DISK_LOADED:-}" ]]; then
  return 0
fi
readonly LIB_DISK_LOADED=1

# Global consts
if [[ -z "${LIB_DIR:-}" ]]; then
  readonly LIB_DIR="$(dirname ${BASH_SOURCE[0]})"
fi

# Imports
source "$LIB_DIR/log.sh"

get_disk_name() {
  local disks_name="$(lsblk -l | grep disk | cut -f 1 -d ' ')"
  
  if [[ $(wc -l <<< "$disks_name") -eq 1 ]]; then
    echo "$disks_name"
  else
    log_error "Found more 1 disks, please run script with -d flag and get disk name. For more see ./install.sh -h."
  fi
}

get_disk_part_path() {
  local disk_name="${1:?'Dont get disk name!'}"
  local part_number="${2:?'Dont get disk part number'}"
  
  # Get partition path
  find /dev -name "$disk_name*$part_number"
}

umount_disk() {
  local return_code="${1:-0}"
  
  umount -R /mnt 2> /dev/null
  [[ "$return_code" -eq 0 ]] || exit "$return_code"
}
