#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Imports
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/graphic/install.sh"
source "$ROOT_DIR/modules/graphic/configure.sh"

install_graphic() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  # Install all graphic packs
  install_all
  
  # Configure all graphic packs
  configure_all
  
  cleanup_apt
}
