lib__mk_dir() {
  local dir="${1:?'Dont get dir name!'}"
  
  if [[ ! -e "$dir" ]]; then
    mkdir -p "$dir"
  elif [[ -f "$dir" ]]; then
    lib__log_error "Path $dir is file. Please delete it or rename."
    exit 1
  fi
}

lib__ch_own() {
  local file="${1:?'Dont get file name!'}"
  local username="${USERNAME:-${2:?'Dont get username!'}}"
  
  chown -R "$username:$username" "$file"
}

lib__normalize_local_bin() {
  local bin='/usr/local/bin'

  chown -R root:root "$bin"
  find "$bin" -type f -exec chmod 755 {} +;
}

