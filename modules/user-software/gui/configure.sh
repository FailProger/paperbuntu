# Imports
source "$ROOT_DIR/lib/user.sh"

user_software_gui__configure_all() {
  # Configure all gui programms
  _configure_alacritty
}

_configure_alacritty() {
  # Configure alacritty
  cp_config 'alacritty'
  update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which alacritty)" 100
}

