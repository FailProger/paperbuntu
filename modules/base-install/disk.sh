# Script params
readonly BASE_INSTALL__DISK_DEPENDENCIES=('parted')

# Imports
source "$ROOT_DIR/lib/disk.sh"
source "$ROOT_DIR/lib/system.sh"

base_install__partition_disk() {
  # Partition and format the disk
  if is_uefi; then
    _base_install__partition_uefi
    _base_install__format_uefi
    _base_install__mount_uefi
  else
    _base_install__partition_bios
    _base_install__format_bios
    _base_install__mount_bios
  fi
}

# --- UEFI ---
_base_install__partition_uefi() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel gpt
  parted "$disk" mkpart ESP fat32 1MiB 513MiB
  parted "$disk" set 1 esp on
  parted "$disk" mkpart root ext4 513MiB 100%
}

_base_install__format_uefi() {
  local efi=$(get_disk_part_path "$DISK_NAME" '1')
  local root=$(get_disk_part_path "$DISK_NAME" '2')
  
  # Format partitions
  mkfs.fat -F 32 "$efi"
  mkfs.ext4 -F "$root"
}

_base_install__mount_uefi() {
  local efi=$(get_disk_part_path "$DISK_NAME" '1')
  local root=$(get_disk_part_path "$DISK_NAME" '2')

  # Mount partitions
  mount $root /mnt
  mkdir -p /mnt/boot/efi
  mount $efi /mnt/boot/efi
}

# --- BIOS ---
_base_install__partition_bios() {
  local disk="/dev/$DISK_NAME"

  # Part disk
  wipefs -fqa "$disk"
  parted "$disk" mklabel msdos
  parted "$disk" mkpart primary ext4 1MiB 100%
  parted "$disk" set 1 boot on
}

_base_install__format_bios() {
  local root=$(get_disk_part_path "$DISK_NAME" '1')
  
  # Format partitions
  mkfs.ext4 -F "$root"
}

_base_install__mount_bios() {
  local root=$(get_disk_part_path "$DISK_NAME" '1')

  # Mount partitions
  mount $root /mnt
}

