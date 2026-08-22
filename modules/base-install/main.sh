# --- Need variables ---
# ROOT_DIR
# REPO_URL
# DISK_NAME

if [[ -n "${MODULE_BASE_INSTALL_LOADED:-}" ]]; then return 0; fi
readonly MODULE_BASE_INSTALL_LOADED=1

# Imports
source "$ROOT_DIR/lib/disk.sh"

source "$ROOT_DIR/modules/base-install/disk.sh"
source "$ROOT_DIR/modules/base-install/debootstrap.sh"

install_base() {
  # Install dependencies
  apt update
  apt install -y ${BASE_INSTALL__DEBOOTSTRAP_DEPENDENCIES[@]} \
                 ${BASE_INSTALL__DISK_DEPENDENCIES[@]}

  trap 'umount_disk 1' SIGINT SIGTERM

  base_install__partition_disk
  base_install__debootstrap_install
}

