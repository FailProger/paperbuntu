bi_debootstrap__get_dependencies() {
  local deps='
  debootstrap
  mount
  ubuntu-keyring
  gnupg
  '
  echo "$deps"
}

bi_debootstrap__install_base() {
  # Install base system
  debootstrap --arch="$ARCH" --variant="$VARIANT" "$RELEASE" /mnt "$MIRROR"
}

