# Imports
source "$SCRIPTS_DIR/user-software/desktop/install.sh"
source "$SCRIPTS_DIR/user-software/desktop/configure.sh"

install_desktop() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  apt update
  apt install -y ${USER_SOFTWARE_DESKTOP__INSTALL_DEPENDENCIES[@]} \
                 ${USER_SOFTWARE_DESKTOP__CONFIGURE_DEPENDENCIES[@]} \
                 ${USER_SOFTWARE_DESKTOP__INSTALL_PACKAGES[@]}

  # Install all desktop environment packs
  user_software_desktop__install_all
  
  # Configure all desktop environment packs
  user_software_desktop__configure_all
  
  cleanup_apt
}

