bi_d_u_ext4__partition_ext4() {
  _bi_d_u_ext4__partition
  _bi_d_u_ext4__format
  _bi_d_u_ext4__mount
}

_bi_d_u_ext4__partition() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel gpt
  parted "$disk" mkpart ESP fat32 1MiB 513MiB
  parted "$disk" set 1 esp on
  parted "$disk" mkpart root ext4 513MiB 100%
}

_bi_d_u_ext4__format() {
  local efi=$(lib__get_disk_part_path "$DISK_NAME" '1')
  local root=$(lib__get_disk_part_path "$DISK_NAME" '2')
  
  # Format partitions
  mkfs.fat -F 32 "$efi"
  mkfs.ext4 -F "$root"
}

_bi_d_u_ext4__mount() {
  local efi=$(lib__get_disk_part_path "$DISK_NAME" '1')
  local root=$(lib__get_disk_part_path "$DISK_NAME" '2')

  # Mount partitions
  mount "$root" /mnt
  mkdir -p /mnt/boot/efi
  mount "$efi" /mnt/boot/efi
}

