# Imports
source "$ROOT_DIR/lib/file.sh"

system_setup__setup_apt() {
  # Add repositories
  local apt_dir='/etc/apt'
  mk_dir "$apt_dir"
  
  cat > $apt_dir/sources.list << EOF
deb $MIRROR $RELEASE main restricted universe multiverse
deb $MIRROR $RELEASE-updates main restricted universe multiverse
deb ${MIRROR//archive/security} $RELEASE-security main restricted universe multiverse
EOF
}

