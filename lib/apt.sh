lib__apt_install_dependencies() {
  local deps=${1:?'Do not get dependencies to install!'}
  deps=$(printf '%s\n' $deps | awk '!seen[$0]++')

  local deps_to_install
  local pkg

  for pkg in $deps; do
    if [[ ! "$(dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null)" == 'install ok installed' ]]; then
      deps_to_install="$deps_to_install $pkg"
    fi
  done

  if [[ -z "$deps_to_install" ]]; then
    return 0
  fi

  if [[ -z ${LIB_APT__UPDATED:-} ]]; then
    apt-get update
    LIB_APT__UPDATED=1
  fi

  apt-get install -y $deps_to_install
}

