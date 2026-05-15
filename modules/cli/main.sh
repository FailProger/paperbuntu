#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
DEPENDENCIES=("build-essential" "xclip")
CLI_PACKS=("wget" "zsh" "gdu" "neovim")

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/cli/install.sh"
source "$ROOT_DIR/modules/cli/configure.sh"

install_cli() {
  trap 'cleanup_apt 1' SIGINT SIGTERM
  
  # Install dependencies
  apt update &&
    apt install -y ${DEPENDENCIES[@]} && unset DEPENDENCIES &&
    apt install -y ${INSTALL_DEPENDENCIES[@]} && unset INSTALL_DEPENDENCIES &&
    apt install -y ${CONFIGURE_DEPENDENCIES[@]} && unset CONFIGURE_DEPENDENCIES
  
  cp_config "git/gitconfig" "$HOME/.gitconfig"

  # Install cli programms from apt
  apt update &&
    apt install -y ${CLI_PACKS[@]} && unset CLI_PACKS

  # Install other cli programms
  install_other
  
  # Configure all cli programms
  configure_all

  cleanup_apt
}
