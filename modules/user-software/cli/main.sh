# --- Need variables ---
# ROOT_DIR
# USERNAME
# HOME
# HOME_CONFIG

if [[ -n "${MODULE_USER_SOFTWARE_CLI_LOADED:-}" ]]; then return 0; fi
readonly MODULE_USER_SOFTWARE_CLI_LOADED=1

# Imports
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/user-software/cli/install.sh"
source "$ROOT_DIR/modules/user-software/cli/configure.sh"

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

