#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}" &&
  -z "${HOME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly CLI_CONFIGURE_DEPENDENCIES=(
  'sudo'
  'git'
  'curl'
)

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"

configure_all() {
  # Install dependencies
  apt update &&
    apt install -y ${CLI_CONFIGURE_DEPENDENCIES[@]}
  
  # Configure all cli programms
  # Shell
  _configure_zsh; _configure_shellfirm; _configure_starship
  
  # Files
  _configure_nvim; _configure_git; _configure_eza; 
}

_configure_zsh() {
  # Configure zsh
  chsh -s "$(which zsh)" "$USERNAME"
  
  # Copy config files
  cp_config 'zsh/zshenv' "$HOME/.zshenv"
  cp_config 'zsh/zshrc' "$HOME/.zshrc"
  cp_config 'zsh/zsh_custom' "$HOME/.zsh_custom"
}

_configure_starship() {
  local config_dir="$HOME/.config/starship"
  mk_dir "$config_dir" && ch_own "$config_dir"
  sudo -u "$USERNAME" starship preset 'jetpack' -o "$config_dir/starship.toml"
}

_configure_nvim() {
  cp_config 'nvim'
}

_configure_git() {
  cp_config 'git/gitconfig' "$HOME/.gitconfig"
}

_configure_eza() {
  cp_config 'eza'
}

_configure_shellfirm() {
  cp_config 'shellfirm'
}

