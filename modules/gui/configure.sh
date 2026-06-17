#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
# readonly GUI_CONFIGURE_DEPENDENCIES=()

# Imports
source "$ROOT_DIR/lib/user.sh"

configure_all() {
  # Install dependencies
  # apt update &&
  #  apt install -y ${GUI_CONFIGURE_DEPENDENCIES[@]}
  
  # Configure all gui programms
  _configure_alacritty
}

_configure_alacritty() {
  # Configure alacritty
  cp_config 'alacritty'
  update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which alacritty)" 100
}
