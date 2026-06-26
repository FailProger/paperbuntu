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
  
  # Development
  _configure_nvim; _configure_git
  
  # Files
  _configure_eza; 
}

_configure_zsh() {
  # Configure zsh
  chsh -s "$(which zsh)" "$USERNAME"
  
  # Remove oh-my-zsh if exists
  local omz_dir="$HOME/.oh-my-zsh"
  [[ -d "$omz_dir" ]] && rm -r "$omz_dir"
  
  # Install oh my zsh
  export RUNZSH='no'
  sudo -u "$USERNAME" sh -c "$(curl -fsSL 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh')" "" --unattended
  
  # Install plugins
  local omz_custom_dir="$omz_dir/custom"
  git clone --depth 1 'https://github.com/zsh-users/zsh-autosuggestions' "$omz_custom_dir/plugins/zsh-autosuggestions"
  git clone --depth 1 'https://github.com/zsh-users/zsh-syntax-highlighting.git' "$omz_custom_dir/plugins/zsh-syntax-highlighting"
  
  # Change own
  ch_own "$omz_dir"
  
  # Copy config files
  cp_config 'zsh/zshrc' "$HOME/.zshrc"
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
