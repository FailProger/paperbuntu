# Imports
source "$SCRIPTS_DIR/base-install/disk.sh"
source "$SCRIPTS_DIR/base-install/debootstrap.sh"

install_base() {
  # Install dependencies
  _bi__install_deps

  trap 'lib__umount_disk 1' SIGINT SIGTERM

  bi_disk__partition_disk
  bi_debootstrap__install_base
}

_bi__install_deps() {
  local deps="
  $(bi_disk__get_dependencies)
  $(bi_debootstrap__get_dependencies)
  "

  lib__apt_install_dependencies "$deps"
}

