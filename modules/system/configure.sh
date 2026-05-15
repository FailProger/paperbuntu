#!/usr/bin/env bash

set -eu

if [[
  -z "${ROOT_DIR:-}" &&
  -z "${DISK_NAME:-}" &&
  -z "${USERNAME:-}" &&
  -z "${PASSWORD:-}"
]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
CONFIGURE_DEPENDENCIES=("locales")

# Imports
if [[ -z "${REPO_URL:-}" ]]; then
  source "$ROOT_DIR/config.sh"
fi
source "$ROOT_DIR/lib/disk.sh"
source "$ROOT_DIR/lib/file.sh"

configure_base() {
  # Configure locales and time
  locale-gen "$LOCALE"
  update-locale LANG="$LOCALE"
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

  # Configure hostname and hosts
  local repo_name=${REPO_URL##*/}
  echo "$repo_name" > /etc/hostname
  echo "127.0.0.1 localhost $repo_name" > /etc/hosts
  
  # Get partitions uuid
  local disk_parts_names=$(get_disk_parts_names "$DISK_NAME")
  local efi=$(cut -f 1 -d " " <<< "$disk_parts_names")
  local root=$(cut -f 2 -d " " <<< "$disk_parts_names")
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

add_user() {
  # Add user
  useradd -m -s /bin/bash -G sudo "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd || passwd "$USERNAME"

  # Configure sudo run
  local sudoers_dir=$(mk_dir "/etc/sudoers.d")
  echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | tee "$sudoers_dir/$USERNAME-nopasswd" > /dev/null
  chmod 440 "$sudoers_dir/$USERNAME-nopasswd"
}

configure_apt() {
  # Add repositories
  local apt_dir=$(mk_dir "/etc/apt")
  
  cat > $apt_dir/sources.list << EOF
deb $MIRROR $RELEASE main restricted universe multiverse
deb $MIRROR $RELEASE-updates main restricted universe multiverse
deb ${MIRROR//archive/security} $RELEASE-security main restricted universe multiverse
EOF
}

configure_users_packs() {
  # Configure Network Manager
  local netplan_dir=$(mk_dir "/etc/netplan")
  
  cat > $netplan_dir/01-network-manager-all.yaml << EOF
network:
  version: 2
  renderer: NetworkManager
EOF
}
