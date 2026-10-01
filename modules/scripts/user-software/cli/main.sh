install_cli() {
  trap 'cleanup_apt 1' SIGINT SIGTERM

  apt update
  apt install -y ${USER_SOFTWARE_CLI__INSTALL_DEPENDENCIES[@]} \
                 ${USER_SOFTWARE_CLI__CONFIGURE_DEPENDENCIES[@]} \
                 ${USER_SOFTWARE_CLI__INSTALL_PACKAGES[@]}

  # Install all cli programms
  user_software_cli__install_all
  
  # Configure all cli programms
  user_software_cli__configure_all
  
  cleanup_apt
}

