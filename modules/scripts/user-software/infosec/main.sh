# Imports
source "$SCRIPTS_DIR/user-software/infosec/install.sh"
source "$SCRIPTS_DIR/user-software/infosec/configure.sh"

install_infosec() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  apt update
  apt install -y ${USER_SOFTWARE_INFOSEC__INSTALL_DEPENDENCIES[@]}
  
  # Install infosec tools
  user_software_infosec__install_all
  
  # Configure infosec tools
  user_software_infosec__configure_all
  
  cleanup_apt
}

