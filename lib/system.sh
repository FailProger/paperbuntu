#!/usr/bin/env bash

set -eu

if [[ -n "${LIB_SYSTEM_LOADED:-}" ]]; then
  return 0
fi
readonly LIB_SYSTEM_LOADED=1

is_uefi() {
  if [[ -d /sys/firmware/efi ]]; then
    return 0
  fi
  return 1
}
