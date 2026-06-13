#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Imports
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/cli/install.sh"
source "$ROOT_DIR/modules/cli/configure.sh"

install_cli() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  # Install all cli programms
  install_all
  
  # Configure all cli programms
  configure_all
  
  cleanup_apt
}
