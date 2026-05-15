#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
DEPENDENCIES=("extrepo")
GUI_PACKS=("alacritty" "librewolf")

# Imports
source "$ROOT_DIR/lib/user.sh"
source "$ROOT_DIR/lib/utils.sh"

install_gui() {
  trap 'cleanup_apt 1' SIGINT SIGTERM
  
  # Install dependencies
  apt update &&
    apt install -y ${DEPENDENCIES[@]} && unset DEPENDENCIES
  
  extrepo enable librewolf

  # Install gui
  apt update &&
    apt install -y ${GUI_PACKS[@]} && unset GUI_PACKS

  # Configure alacritty
  cp_config "alacritty"
  update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 100

  cleanup_apt
}
