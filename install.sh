#!/usr/bin/env bash

set -eu

# Global consts
readonly ROOT_DIR=$(dirname "$0")

# Imports
source "$ROOT_DIR/config.sh"

source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/disk.sh"

source "$ROOT_DIR/modules/debootstrap.sh"
source "$ROOT_DIR/modules/chroot-configure.sh"

_usage() {
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

main() {
  local username=""
  local password=""
  local disk_name=""
  local run_install=""
  
  # Get script options
  while getopts ":hu:p:d:y" opt; do
    case "$opt" in
      h) _usage; exit 0;;
      u) username="$OPTARG";;
      p) password="$OPTARG";;
      d) disk_name="$OPTARG";;
      y) run_install="yes";;
      ?) log_error "Uncorrect option: -$OPTARG."; echo; _usage; exit 1;;
    esac
  done

  # Check root user
  if [[ $EUID -ne 0 ]]; then
    log_error "Run script as root."
    exit 1
  fi

  # Get disk name
  readonly DISK_NAME=${disk_name:-$(get_disk_name)} && unset disk_name
  
  # Ask user continue installation
  while [[ -z "$run_install" ]]; do
    read -p "WARNING: All data on disk $DISK_NAME will be erased, continue? [Y/N] " run_install
    case $run_install in
      Y|y|Yes|YES|yes) break;;
      N|n|No|NO|no) echo "Exit..."; exit 0;;
      *) run_install=""; log_error "Please enter Yes/No."; continue;;
    esac
  done

  unset run_install

  # Get install params
  readonly USERNAME="${username:-$DEFAULT_USERNAME}" && unset username
  readonly PASSWORD="${password:-$DEFAULT_PASSWORD}" && unset password

  debootstrap_install_system
  chroot_configure_system
}

main "$@"
