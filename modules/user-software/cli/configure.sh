# Script params
readonly USER_SOFTWARE_CLI__CONFIGURE_DEPENDENCIES=(
  'sudo'
  'git'
  'curl'
)

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"

user_software_cli__configure_all() {
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
  mk_dir "$config_dir"
  ch_own "$config_dir"
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

