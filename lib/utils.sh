#!/usr/bin/env bash

set -eu

if [[ -n "${LIB_UTILS_LOADED:-}" ]]; then
  return 0
fi
readonly LIB_UTILS_LOADED=1

cleanup_apt() {
  local return_code="${1:-0}"
  
  apt autoremove -y && apt autoclean -y
  exit "$return_code"
}
