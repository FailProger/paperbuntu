# Script params
readonly SYSTEM_SETUP__BASE_DEPENDENCIES=('locales')

# Imports
source "$ROOT_DIR/lib/disk.sh"
source "$ROOT_DIR/lib/system.sh"

system_setup__setup_base() {
  _system_setup__setup_locale
  _system_setup__setup_hostname
  _system_setup__setup_fstab
}

_system_setup__setup_locale() {
  # Configure locales and time
  locale-gen "$LOCALE"
  update-locale LANG="$LOCALE"
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
}

_system_setup__setup_hostname() {
  # Configure hostname and hosts
  local repo_name=${REPO_URL##*/}
  echo "$repo_name" > /etc/hostname
  echo "127.0.0.1 localhost $repo_name" > /etc/hosts
}

_system_setup__setup_fstab() {
  if is_uefi; then
    _system_setup__setup_fstab_uefi
  else
    _system_setup__setup_fstab_bios
  fi
}

_system_setup__setup_fstab_uefi() {
  local efi=$(get_disk_part_path "$DISK_NAME" '1')
  local root=$(get_disk_part_path "$DISK_NAME" '2')
  local efi_uuid=$(blkid -s UUID -o value "$efi")
  local root_uuid=$(blkid -s UUID -o value "$root")

  # Configure fstab
  cat > /etc/fstab << EOF
# $DISK_NAME - ESP
UUID=$efi_uuid /boot/efi vfat umask=0077 0 1
# $DISK_NAME - root partition
UUID=$root_uuid / ext4 defaults 0 1
EOF
}

_system_setup__setup_fstab_bios() {
  local root=$(get_disk_part_path "$DISK_NAME" '1')
  local root_uuid=$(blkid -s UUID -o value "$root")

  # Configure fstab
  cat > /etc/fstab << EOF
# $DISK_NAME - root partition
UUID=$root_uuid / ext4 defaults 0 1
EOF
}

