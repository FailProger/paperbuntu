#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

INSTALL_DEPENDENCIES=("curl")

source "$ROOT_DIR/lib/user.sh"

install_other() {
  # Install other cli programms
  _install_lla
}

_install_lla() {
  # Install lla from github
  curl -sSL https://raw.githubusercontent.com/chaqchase/lla/main/install.sh | bash
  cp_config "lla"
}
