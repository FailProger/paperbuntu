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
    _bi_disk__partition_uefi
    _bi_disk__format_uefi
    _bi_disk__mount_uefi
  else
    _bi_disk__partition_bios
    _bi_disk__format_bios
    _bi_disk__mount_bios
  fi
}

# --- UEFI ---
_bi_disk__partition_uefi() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel gpt
  parted "$disk" mkpart ESP fat32 1MiB 513MiB
  parted "$disk" set 1 esp on
  parted "$disk" mkpart root ext4 513MiB 100%
}

_bi_disk__format_uefi() {
  local efi=$(lib__get_disk_part_path "$DISK_NAME" '1')
  local root=$(lib__get_disk_part_path "$DISK_NAME" '2')
  
  # Format partitions
  mkfs.fat -F 32 "$efi"
  mkfs.ext4 -F "$root"
}

_bi_disk__mount_uefi() {
  local efi=$(lib__get_disk_part_path "$DISK_NAME" '1')
  local root=$(lib__get_disk_part_path "$DISK_NAME" '2')

  # Mount partitions
  mount "$root" /mnt
  mkdir -p /mnt/boot/efi
  mount "$efi" /mnt/boot/efi
}

# --- BIOS ---
_bi_disk__partition_bios() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel msdos
  parted "$disk" mkpart primary ext4 1MiB 100%
  parted "$disk" set 1 boot on
}

_bi_disk__format_bios() {
  local root=$(lib__get_disk_part_path "$DISK_NAME" '1')
  
  # Format partitions
  mkfs.ext4 -F "$root"
}

_bi_disk__mount_bios() {
  local root=$(lib__get_disk_part_path "$DISK_NAME" '1')

  # Mount partitions
  mount "$root" /mnt
}

