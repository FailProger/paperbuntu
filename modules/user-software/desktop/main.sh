# --- Need variables ---
# ROOT_DIR
# REPO_URL
# USERNAME
# HOME
# HOME_CONFIG

if [[ -n "${MODULE_USER_SOFTWARE_DESKTOP_LOADED:-}" ]]; then return 0; fi
readonly MODULE_USER_SOFTWARE_DESKTOP_LOADED=1

# Imports
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/user-software/desktop/install.sh"
source "$ROOT_DIR/modules/user-software/desktop/configure.sh"

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
