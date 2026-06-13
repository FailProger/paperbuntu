#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
DEPENDENCIES=('git' 'curl')

# Imports
source "$ROOT_DIR/lib/user.sh"

configure_all() {
  # Install dependencies
  apt update &&
    apt install -y ${DEPENDENCIES[@]} && unset DEPENDENCIES
  
  # Configure all gui programms
  _configure_alacritty
}

_configure_alacritty() {
  # Configure alacritty
  cp_config "alacritty"
  update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 100
}
