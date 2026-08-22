# Script params
readonly BASE_INSTALL__DEBOOTSTRAP_DEPENDENCIES=('debootstrap')

base_install__debootstrap_install() {
  # Install base system
  debootstrap --arch="$ARCH" --variant="$VARIANT" "$RELEASE" /mnt "$MIRROR"
}

