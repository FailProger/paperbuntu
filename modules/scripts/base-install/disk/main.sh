source "$SCRIPTS_DIR/base-install/disk/uefi/main.sh"
source "$SCRIPTS_DIR/base-install/disk/bios/main.sh"

bi_disk__get_dependencies() {
  local deps='
  parted
  dosfstools
  e2fsprogs
  util-linux
  '
  echo "$deps"
}

bi_disk__partition_disk() {
  # Partition and format the disk
  if lib__is_uefi; then
    bi_d_u__partition_uefi
  else
    bi_d_b_partition_bios
  fi
}

