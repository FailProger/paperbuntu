#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Imports
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/gui/install.sh"
source "$ROOT_DIR/modules/gui/configure.sh"

install_gui() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  # Install all gui programms
  install_all

  # Configure all gui programms
  configure_all

  cleanup_apt
}
