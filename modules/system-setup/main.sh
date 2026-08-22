# --- Need variables ---
# ROOT_DIR
# REPO_URL
# DISK_NAME
# USERNAME
# PASSWORD

if [[ -n "${MODULE_SYSTEM_SETUP_LOADED:-}" ]]; then return 0; fi
readonly MODULE_SYSTEM_SETUP_LOADED=1

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/utils.sh"

source "$ROOT_DIR/modules/system-setup/base.sh"
source "$ROOT_DIR/modules/system-setup/apt.sh"
source "$ROOT_DIR/modules/system-setup/user.sh"
source "$ROOT_DIR/modules/system-setup/kernel.sh"
source "$ROOT_DIR/modules/system-setup/bootloader.sh"
source "$ROOT_DIR/modules/system-setup/user-packages.sh"

setup_system() {
  trap 'cleanup_apt 1' SIGINT SIGTERM
  
  export DEBIAN_FRONTEND='noninteractive'

  # Install dependencies
  apt update
  apt install -y ${SYSTEM_SETUP__BASE_DEPENDENCIES[@]}

  # Configure base (locales, time, hostname, hosts, fstab),
  # setup apt repo and add user
  system_setup__setup_base
  system_setup__setup_apt
  system_setup__setup_user

  # Install kernel, user packages and bootloader
  apt update
  apt install -y ${SYSTEM_SETUP__KERNEL_PACKAGES[@]} ${SYSTEM_SETUP__USER_PACKAGES[@]}
  system_setup__install_bootloader

  system_setup__setup_user_packages
  
  # Upgrade system
  apt upgrade -y
  
  cleanup_apt
}

