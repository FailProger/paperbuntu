# --- Need variables ---
# ROOT_DIR
# REPO_URL
# DISK_NAME
# USERNAME
# PASSWORD
 
if [[ -n "${MODULE_CHROOT_LOADED:-}" ]]; then return 0; fi
readonly MODULE_CHROOT_LOADED=1

# Imports
source "$ROOT_DIR/lib/disk.sh"
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/system.sh"

chroot_setup() {
  trap 'umount_disk 1' SIGINT SIGTERM

  _chroot__mount_system
  
  # Copy repo
  local repo_dir="/mnt/tmp/${REPO_URL##*/}"
  mk_dir "$repo_dir"
  cp -r "$ROOT_DIR"/. "$repo_dir"

  # Configure system
  chroot /mnt /usr/bin/bash "${repo_dir#/mnt}/install.sh" setup -u "$USERNAME" -p "$PASSWORD" -d "$DISK_NAME" -y

  rm -rf "$repo_dir"

  umount_disk
  reboot
}

_chroot__mount_system() {
  # Mount system
  mount --bind /dev /mnt/dev
  mount --bind /dev/pts /mnt/dev/pts
  mount -t proc proc /mnt/proc
  mount -t sysfs sys /mnt/sys
  # If UEFI
  is_uefi && mount --bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
  
  cp /etc/resolv.conf /mnt/etc/resolv.conf
}

