# --- Need variables ---
# ROOT_DIR
# USERNAME
# HOME
# HOME_CONFIG

if [[ -n "${MODULE_USER_SOFTWARE_GUI_LOADED:-}" ]]; then return 0; fi
readonly MODULE_USER_SOFTWARE_GUI_LOADED=1

# Imports
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/user-software/gui/install.sh"
source "$ROOT_DIR/modules/user-software/gui/configure.sh"

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

