install_base() {
  # Install dependencies
  apt update
  apt install -y ${BASE_INSTALL__DEBOOTSTRAP_DEPENDENCIES[@]} \
                 ${BASE_INSTALL__DISK_DEPENDENCIES[@]}

  trap 'umount_disk 1' SIGINT SIGTERM

  base_install__partition_disk
  base_install__debootstrap_install
}

