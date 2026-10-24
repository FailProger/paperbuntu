# Script params
readonly USER_SOFTWARE_CLI__CONFIGURE_DEPENDENCIES=(
  'sudo'
)

user_software_cli__configure_all() {
  # Configure all cli programms
  # Shell
  _configure_zsh; _configure_tmux; _configure_shellfirm; _configure_starship
  
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

_configure_tmux() {
  cp_config 'tmux/tmux.conf' "$HOME/.tmux.conf"
}

_configure_starship() {
  local config_dir="$HOME/.config/starship"
  mk_dir "$config_dir"
  ch_own "$config_dir"
  sudo -u "$USERNAME" starship preset 'jetpack' -o "$config_dir/starship.toml"
}

_configure_nvim() {
  local config_dir="$HOME/.config/nvim"

  git clone --depth 1 'https://github.com/AstroNvim/template' "$config_dir"
  rm -rf "$config_dir/.git" "$config_dir/README.md"

  cp -r "$DOTFILES_DIR/nvim" "$HOME/.config"

  find "$config_dir" -type d -exec chmod 700 {} +
  find "$config_dir" -type f -exec chmod 600 {} +

  ch_own "$config_dir"
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

