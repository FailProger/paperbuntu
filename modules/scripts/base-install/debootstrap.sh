bi_debootstrap__get_dependencies() {
  local deps='debootstrap'
  echo "$deps"
}

bi_debootstrap__install_base() {
  # Install base system
  debootstrap --arch="$ARCH" --variant="$VARIANT" "$RELEASE" /mnt "$MIRROR"
}

