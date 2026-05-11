#!/usr/bin/env bash

set -eu

# Script params    INFO: Mey be edited
readonly REPO_URL="https://github.com/FailProger/paperbuntu"
readonly CONFIG_FILE_NAME="config.sh"
readonly LIB_FILE_NAME="lib.sh"

readonly CONFIGURE_SCRIPT_NAME="configure.sh"
readonly INSTALL_DEPENDENCIES=("debootstrap" "parted")

# Global conts
readonly ROOT_DIR=$(dirname "$0")
readonly CONFIG_FILE="$ROOT_DIR/$CONFIG_FILE_NAME"
readonly LIB_FILE="$ROOT_DIR/lib/$LIB_FILE_NAME"

usage() {
  cat << EOF
Usage: ./$(basename "$0") [OPTION]...
Home page: github ($REPO_URL)
OPTIONS:
  -h    This help message.
  -u    User who will be created in new system. If not getted
        will be used default username from $ROOT_DIR/config.
  -p    Password for user in new system. If not getted will be
        used default password from $ROOT_DIR/config.
  -d    Disk name for system installation. If not getted will
        be selected first disk. You can see disks run:
        lsblk | grep disk.
  -y    Run install without asking the permission.
EOF
}

part_disk() {
  # Get disk
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa $disk
  parted $disk mklabel gpt
  parted $disk mkpart ESP fat32 1MiB 513MiB
  parted $disk set 1 esp on
  parted $disk mkpart root ext4 513MiB 100%
}

format_disk() {
  # Get partitions names
  local efi=$(find /dev -name "$DISK_NAME*1")
  local root=$(find /dev -name "$DISK_NAME*2")
  
  # Format partitions
  mkfs.fat -F 32 $efi
  mkfs.ext4 -F $root
}

mount_disk() {
  # Get partitions names
  local efi=$(find /dev -name "$DISK_NAME*1")
  local root=$(find /dev -name "$DISK_NAME*2")

  # Mount partitions
  mount $root /mnt
  mkdir -p /mnt/boot/efi
  mount $efi /mnt/boot/efi
}

umount_disk() {
  umount -R /mnt 2> /dev/null
  [[ ${1:-1} -eq 0 ]] || exit 1
}

install_system() {
  # Install dependencies
  apt update && apt install -y ${INSTALL_DEPENDENCIES[@]}

  # Part and format disk
  part_disk && format_disk

  # Mount disk
  mount_disk

  # Install base system
  debootstrap --arch=$SYSTEM_ARCH --variant=$SYSTEM_VARIANT "$SYSTEM_SUITE" /mnt "$SYSTEM_REPO"

  # Mount system
  mount --bind /dev /mnt/dev
  mount --bind /dev/pts /mnt/dev/pts
  mount -t proc proc /mnt/proc
  mount -t sysfs sys /mnt/sys
  mount --bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
  cp /etc/resolv.conf /mnt/etc/resolv.conf
  
  # Copy repo
  local repo_dir=$(mk_dir "/mnt/tmp/${REPO_URL##*/}")
  cp -r ./* "$repo_dir"

  # Configure system
  chroot /mnt /bin/bash "${repo_dir#/mnt}/$CONFIGURE_SCRIPT_NAME" -u "$USERNAME" -p "$PASSWORD" -d "$DISK_NAME"
  unset repo_dir

  umount_disk 0

  reboot
}

main() {
  source "$LIB_FILE"
  
  local username=""
  local password=""
  local disk=""
  local run_install=""
  
  # Get script options
  while getopts ":hu:p:d:y" opt; do
    case "$opt" in
      h) usage; exit 0;;
      u) username="$OPTARG";;
      p) password="$OPTARG";;
      d) disk="$OPTARG";;
      y) run_install="yes";;
      ?) log_error "Uncorrect option: -$OPTARG."; echo; usage; exit 1;;
    esac
  done

  # Check root user
  if [[ $EUID -ne 0 ]]; then
    log_error "Run script as root."
    exit 1
  fi

  # Get disk name
  readonly DISK_NAME=${disk:-$(lsblk | grep disk -m 1 | cut -f 1 -d " ")}

  # Ask user continue installation
  while [[ -z "$run_install" ]]; do
    read -p "WARNING: All data on disk $DISK_NAME will be erased, continue? [Y/N] " run_install
    case $run_install in
      Y|y|Yes|YES|yes) break;;
      N|n|No|NO|no) echo "Exit..."; exit 0;;
      *) run_install=""; log_error "Please enter Yes/No."; continue;;
    esac
  done

  # Get install params
  readonly USERNAME="${username:-$DEFAULT_USERNAME}"
  readonly PASSWORD="${password:-$DEFAULT_PASSWORD}"
  source "$CONFIG_FILE"

  unset username
  unset password
  unset run_install
  unset disk

  trap umount_disk SIGINT SIGTERM
  install_system
}

main "$@"
