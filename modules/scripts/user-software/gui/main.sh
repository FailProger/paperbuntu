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

