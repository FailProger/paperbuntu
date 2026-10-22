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
  lib__cp_config 'zsh/zshenv' "$HOME/.zshenv"
  lib__cp_config 'zsh/zshrc' "$HOME/.zshrc"
  lib__cp_config 'zsh/zsh_custom' "$HOME/.zsh_custom"
}

_configure_tmux() {
  lib__cp_config 'tmux/tmux.conf' "$HOME/.tmux.conf"
}

_configure_starship() {
  local config_dir="$HOME/.config/starship"
  lib__mk_dir "$config_dir"
  lib__ch_own "$config_dir"
  sudo -u "$USERNAME" starship preset 'jetpack' -o "$config_dir/starship.toml"
}

_configure_nvim() {
  lib__cp_config 'nvim'
}

_configure_git() {
  lib__cp_config 'git/gitconfig' "$HOME/.gitconfig"
}

_configure_eza() {
  lib__cp_config 'eza'
}

_configure_shellfirm() {
  lib__cp_config 'shellfirm'
}

