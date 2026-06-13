#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${USERNAME:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
DEPENDENCIES=('git' 'curl')

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"

configure_all() {
  # Install dependencies
  apt update &&
    apt install -y ${DEPENDENCIES[@]} && unset DEPENDENCIES
  
  # Configure all cli programms
  _configure_zsh; _configure_nvim; _configure_git
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
  
  # Install plugins and Powerlevel10k
  local omz_custom_dir="$omz_dir/custom"
  git clone --depth 1 'https://github.com/zsh-users/zsh-autosuggestions' "$omz_custom_dir/plugins/zsh-autosuggestions"
  git clone --depth 1 'https://github.com/zsh-users/zsh-syntax-highlighting.git' "$omz_custom_dir/plugins/zsh-syntax-highlighting"
  git clone --depth 1 'https://github.com/romkatv/powerlevel10k.git' "$omz_custom_dir/themes/powerlevel10k"
  
  # Change own
  ch_own "$omz_dir"
  
  # Copy config files
  cp_config 'zsh/zshrc' "$HOME/.zshrc"
  cp_config 'p10k/p10k.zsh' "$HOME/.p10k.zsh"
}

_configure_nvim() {
  cp_config 'nvim'
}

_configure_git() {
  cp_config 'git/gitconfig' "$HOME/.gitconfig"
}
