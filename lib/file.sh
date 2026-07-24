#!/usr/bin/env bash

set -eu

if [[ -n "${LIB_FILE_LOADED:-}" ]]; then
  return 0
fi
readonly LIB_FILE_LOADED=1

# Global consts
if [[ -z "${LIB_DIR:-}" ]]; then
  readonly LIB_DIR="$(dirname ${BASH_SOURCE[0]})"
fi

# Imports
source "$LIB_DIR/log.sh"

mk_dir() {
  local dir="${1:?'Dont get dir name!'}"
  
  if [[ ! -e "$dir" ]]; then
    mkdir -p "$dir"
  elif [[ -f "$dir" ]]; then
    log_error "Path $dir is file. Please delete it or rename."
    exit 1
  fi
}

ch_own() {
  local file="${1:?'Dont get file name!'}"
  local username="${USERNAME:-${2:?'Dont get username!'}}"
  
  chown -R "$username:$username" "$file"
}
