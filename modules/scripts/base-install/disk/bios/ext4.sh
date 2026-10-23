bi_d_b_ext4__partition_ext4() {
  _bi_d_b_ext4__partition
  _bi_d_b_ext4__format
  _bi_d_b_ext4__mount
}

_bi_d_b_ext4__partition() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel msdos
  parted "$disk" mkpart primary ext4 1MiB 100%
  parted "$disk" set 1 boot on
}

_bi_d_b_ext4__format() {
  local root=$(lib__get_disk_part_path "$DISK_NAME" '1')
  
  # Format partitions
  mkfs.ext4 -F "$root"
}

_bi_d_b_ext4__mount() {
  local root=$(lib__get_disk_part_path "$DISK_NAME" '1')

  # Mount partitions
  mount "$root" /mnt
}

