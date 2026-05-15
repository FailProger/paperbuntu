#!/usr/bin/env bash

set -eu

# Global consts
ROOT_DIR=$(dirname "$0")

# Imports
source "$ROOT_DIR/config.sh"

source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/disk.sh"

source "$ROOT_DIR/modules/system/main.sh"

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
EOF
}

main() {
  local username=""
  local password=""
  local disk_name=""
  
  # Get script options
  while getopts ":hu:p:d:" opt; do
    case "$opt" in
      h) _usage; exit 0;;
      u) username="$OPTARG";;
      p) password="$OPTARG";;
      d) disk_name="$OPTARG";;
      ?) log_error "Uncorrect option: -$OPTARG."; echo; _usage; exit 1;;
    esac
  done
  
  # Check root user
  if [[ $EUID -ne 0 ]]; then
    log_error "Run script as root."
    exit 1
  fi
  
  # Get install params
  readonly USERNAME="${username:-$DEFAULT_USERNAME}" && unset username
  readonly PASSWORD="${password:-$DEFAULT_PASSWORD}" && unset password
  readonly DISK_NAME="${disk_name:-$(get_disk_name)}" && unset disk_name

  configure_system
}

main "$@"
