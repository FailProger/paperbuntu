#!/usr/bin/env bash

set -eu

# Script params    INFO: Mey be edited
readonly REPO_URL="https://github.com/FailProger/paperbuntu"
readonly CONFIG_FILE_NAME="config.sh"
readonly LIB_FILE_NAME="lib.sh"

readonly I3_INSTALL_SCRIPT_NAME="i3-install.sh"
readonly CLI_INSTALL_SCRIPT_NAME="user-cli-install.sh"
readonly GUI_INSTALL_SCRIPT_NAME="user-gui-install.sh"

readonly INSTALL_DEPENDENCIES=("locales" "curl" "zip" "unzip" "fontconfig")
readonly INSTALL_BASE=(
  "linux-image-generic"
  "linux-headers-generic"
  "grub-efi-amd64"
  "sudo"
  "network-manager"
)

# Global conts
ROOT_DIR=$(dirname "$0")
readonly CONFIG_FILE="$ROOT_DIR/$CONFIG_FILE_NAME"
readonly LIB_FILE="$ROOT_DIR/lib/$LIB_FILE_NAME"

usage() {
  cat << EOF
Usage: ./$(basename "$0") [OPTION]...
Home page: github ($REPO_URL)
OPTIONS:
  -h    This help message.
  -u    User who will be created in new system. If not getted
        will be used default username from $ROOT_DIR/config.
  -p    Password for user in new system. If not getted will be
        used default password from $ROOT_DIR/config.
  -d    Disk name for system installation. If not getted will
        be selected first disk. You can see disks run:
        lsblk | grep disk.
EOF
}

configure_system() {
  # Install dependencies
  apt update && apt install -y ${INSTALL_DEPENDENCIES[@]}

  # Configure locales and time
  locale-gen "$SYSTEM_LOCALE"
  update-locale LANG="$SYSTEM_LOCALE"
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

  # Configure hostname and hosts
  local repo_name=${REPO_URL##*/}
  echo "$repo_name" > /etc/hostname
  echo "127.0.0.1 localhost $repo_name" > /etc/hosts

  # Get disk name
  local disk_name=${1:-$(lsblk | grep disk -m 1 | cut -f 1 -d " ")}
  
  # Get partitions names
  local efi=$(find /dev -name "$disk_name*1")
  local root=$(find /dev -name "$disk_name*2")
  local efi_uuid=$(blkid -s UUID -o value $efi)
  local root_uuid=$(blkid -s UUID -o value $root)
  
  # Configure fstab
  cat > /etc/fstab << EOF
  # $disk_name - ESP
  UUID=${efi_uuid} /boot/efi vfat umask=0077 0 1
  # $disk_name - root partition
  UUID=${root_uuid} / ext4 defaults 0 1
EOF

  unset disk_name
  unset efi
  unset root
  unset efi_uuid
  unset root_uuid

  # Add user
  useradd -m -s /bin/bash -G sudo "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd || passwd "$USERNAME"

  # Configure sudo run
  local sudoers_dir=$(mk_dir "/etc/sudoers.d")
  echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | tee "$sudoers_dir/$USERNAME-nopasswd" > /dev/null
  chmod 440 "$sudoers_dir/$USERNAME-nopasswd"

  unset sudoers_dir

  # Add repositories
  local apt_dir=$(mk_dir "/etc/apt")
  cat > $apt_dir/sources.list << EOF
  deb $SYSTEM_REPO $SYSTEM_SUITE main restricted universe multiverse
  deb $SYSTEM_REPO $SYSTEM_SUITE-updates main restricted universe multiverse
  deb ${SYSTEM_REPO//archive/security} $SYSTEM_SUITE-security main restricted universe multiverse
EOF

  unset apt_dir

  # Install base
  export DEBIAN_FRONTEND=noninteractive  # Env for noninteractive keyboard-configuration
  apt update && apt install -y ${INSTALL_BASE[@]}

  unset DEBIAN_FRONTEND

  # Install grub
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=${repo_name^}
  update-grub

  # Configure Network Manager
  local netplan_dir=$(mk_dir "/etc/netplan")
  cat > $netplan_dir/01-network-manager-all.yaml << EOF
  network:
    version: 2
    renderer: NetworkManager
EOF
  
  unset netplan_dir

  # Upgrade system
  apt update && apt upgrade -y
  
  # Install Nerd Fonts
  local nerd_fonts_dir=$(mk_dir "/usr/local/share/fonts/hack-nerd-font/")
  curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
  unzip Hack.zip -d "$nerd_fonts_dir"
  rm Hack.zip
  rm "$nerd_fonts_dir/LICENSE.md" "$nerd_fonts_dir/README.md"
  chmod -R 644 $nerd_fonts_dir/*
  chmod +x $nerd_fonts_dir
  fc-cache -fv

  unset nerd_fonts_dir
  
  # Move repo
  local repo_dir="/home/$USERNAME/$repo_name"
  if [[ "$ROOT_DIR" != "$repo_dir" ]]; then
    cd /
    mk_dir /home/$USERNAME > /dev/null
    mv "$ROOT_DIR" "$repo_dir"
    ROOT_DIR="$repo_dir"
    ch_own "$ROOT_DIR"
  fi

  unset repo_dir
  unset repo_name

  # Start i3 install
  $ROOT_DIR/$I3_INSTALL_SCRIPT_NAME "$USERNAME"

  # Start user install
  $ROOT_DIR/$CLI_INSTALL_SCRIPT_NAME "$USERNAME"
  $ROOT_DIR/$GUI_INSTALL_SCRIPT_NAME "$USERNAME"
}

main() {
  source "$LIB_FILE"

  local username=""
  local password=""
  local disk=""
  
  # Get script options
  while getopts ":hu:p:d:" opt; do
    case "$opt" in
      h) usage; exit 0;;
      u) username="$OPTARG";;
      p) password="$OPTARG";;
      d) disk="$OPTARG";;
      ?) log_error "Uncorrect option: -$OPTARG."; echo; usage; exit 1;;
    esac
  done
  
  # Check root user
  if [[ $EUID -ne 0 ]]; then
    log_error "Run script as root."
    exit 1
  fi
  
  # Get install params
  readonly USERNAME="${username:-$DEFAULT_USERNAME}"
  readonly PASSWORD="${password:-$DEFAULT_PASSWORD}"
  source "$CONFIG_FILE"

  unset username
  unset password

  configure_system "$disk"
}

main "$@"
