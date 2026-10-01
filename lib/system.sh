is_uefi() {
  if [[ -d /sys/firmware/efi ]]; then
    return 0
  fi
  return 1
}

