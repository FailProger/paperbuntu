# Imports
source "$SCRIPTS_DIR/user-software/gui/install.sh"
source "$SCRIPTS_DIR/user-software/gui/configure.sh"

install_gui() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  apt update
  apt install -y ${USER_SOFTWARE_GUI__INSTALL_DEPENDENCIES[@]}

  # Install all gui programms
  user_software_gui__install_all

  # Configure all gui programms
  user_software_gui__configure_all

  cleanup_apt
}

