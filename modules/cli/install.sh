#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly CLI_INSTALL_DEPENDENCIES=('curl' 'build-essential' 'xclip')
readonly CLI_PACKS=('ssh' 'wget' 'zsh' 'gdu' 'neovim')

# Imports
source "$ROOT_DIR/lib/user.sh"

install_all() {
  # Install dependencies and cli programms from apt
  apt update &&
    apt install -y ${CLI_INSTALL_DEPENDENCIES[@]} &&
    apt install -y ${CLI_PACKS[@]}

  # Install other cli programms
  _install_lla
}

_install_lla() {
  # Install lla from github
  curl -sSL 'https://raw.githubusercontent.com/chaqchase/lla/main/install.sh' | bash
  cp_config 'lla'
}
