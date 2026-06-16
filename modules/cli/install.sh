#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly CLI_INSTALL_DEPENDENCIES=('curl' 'build-essential' 'xclip' 'jq')
readonly CLI_PACKS=(
  'ssh'
  'wget'
  'zsh'
  'gdu'
  'neovim'
  'atuin'
  'eza'
  'fzf'
  'starship'
  'zoxide'
)

# Imports
source "$ROOT_DIR/lib/user.sh"

install_all() {
  # Install dependencies and cli programms from apt
  apt update &&
    apt install -y ${CLI_INSTALL_DEPENDENCIES[@]} &&
    apt install -y ${CLI_PACKS[@]}

  # Create temp dir
  local past_dir=$(pwd)
  local install_dir=$(mk_dir '/tmp/cli-install')
  cd "$install_dir"
  
  # Install other cli programms
  _install_shellfirm
  
  cd "$past_dir"
  rm -rf "$install_dir"
}

_install_shellfirm() {
  curl -s 'https://api.github.com/repos/kaplanelad/shellfirm/releases/latest' \
    | jq -r '.assets[] | select(.name | test("shellfirm-.*-x86_64-linux.tar.xz")) | .browser_download_url' \
    | xargs curl -L -O
  
  tar -xf shellfirm*
  find . -type f -name 'shellfirm' -exec mv {} /usr/local/bin \;
  
  rm -rf shellfirm*
}
