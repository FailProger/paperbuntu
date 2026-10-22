lib__apt_install_dependencies() {
  local deps=${1:?'Do not get dependencies to install!'}
  deps=$(printf '%s\n' $deps | awk '!seen[$0]++')

  local deps_to_install=''

  for pkg in $deps; do
    if ! dpkg -s "$pkg" > /dev/null 2>&1; then
      deps_to_install="$deps_to_install $pkg"
    fi
  done

  if [[ -z "$deps_to_install" ]]; then
    return 0
  fi

  apt-get update
  apt-get install -y $deps_to_install
}

