# Imports
source "$ROOT_DIR/lib/system.sh"

system_setup__install_bootloader() {
  _system_setup__install_grub
}

_system_setup__install_grub() {
  if is_uefi; then
    _system_setup__install_grub_uefi
  else
    _system_setup__install_grub_bios
  fi
  
  update-grub
}

_system_setup__install_grub_uefi() {
  apt install -y grub-efi-amd64
  
  # Install grub
  local repo_name=${REPO_URL##*/}
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="${repo_name}"
}

_systerm_setup__install_grub_bios() {
  apt install -y grub-pc
  
  # Install grub
  grub-install --target=i386-pc "/dev/$DISK_NAME"
}

