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

wget_download() {
  local attempts=5
  local connect_timeout=5
  local read_timeout=5
  local between_timeout=2
  
  local url="${1:?'Dont get url!'}"
  
  # Try 3 times download with wget
  for (( i=0; i < "$attempts"; i++ )); do
    if wget --connect-timeout="$connect_timeout" --read-timeout="$read_timeout" -c "$url"; then
      return 0
    fi

    sleep "$between_timeout"
  done

  return 1
}
