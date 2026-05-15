#!/usr/bin/env bash

set -eu

if [[ -n "${LIB_LOG_LOADED:-}" ]]; then
  return 0
fi
readonly LIB_LOG_LOADED=1

log_error() {
  local message="$1"
  
  echo "[ERROR] $message" >&2
}
