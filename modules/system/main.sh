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

# Imports
if [[ -z "${REPO_URL:-}" ]]; then
  source "$ROOT_DIR/config.sh"
fi
source "$ROOT_DIR/lib/file.sh"

source "$ROOT_DIR/modules/system/configure.sh"
source "$ROOT_DIR/modules/system/install.sh"

configure_system() {
  # Install dependencies
  apt update &&
    apt install -y ${CONFIGURE_DEPENDENCIES[@]} && unset CONFIGURE_DEPENDENCIES

  # Configure locales, time, hostname, hosts and fstab,
  # add user and configure apt repo
  configure_base && configure_apt && add_user

  install_kernel && instsall_bootloader

  # Upgrade system
  apt update && apt upgrade -y
  
  # Install user's packages
  install_users_packs && configure_users_packs
  
  # Move repo
  local repo_name=${REPO_URL##*/}
  local repo_dir="/home/$USERNAME/$repo_name" && unset repo_name
  
  if [[ "$ROOT_DIR" != "$repo_dir" ]]; then
    cd /
    mk_dir /home/$USERNAME
    mv "$ROOT_DIR" "$repo_dir"
    ROOT_DIR="$repo_dir"
    ch_own "$ROOT_DIR"
  fi

  unset repo_dir

  # Install graphic
  $ROOT_DIR/graphic-install.sh "$USERNAME"

  # Install users programms
  $ROOT_DIR/cli-install.sh "$USERNAME"
  $ROOT_DIR/gui-install.sh "$USERNAME"

  # Install pentest tools
  $ROOT_DIR/pentest-install.sh
}
