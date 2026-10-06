# Imports
source "$SCRIPTS_DIR/system-setup/base.sh"
source "$SCRIPTS_DIR/system-setup/apt.sh"
source "$SCRIPTS_DIR/system-setup/user.sh"
source "$SCRIPTS_DIR/system-setup/kernel.sh"
source "$SCRIPTS_DIR/system-setup/bootloader.sh"
source "$SCRIPTS_DIR/system-setup/user-packages.sh"

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

