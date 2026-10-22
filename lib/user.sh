lib__get_user() {
  local users="$(ls /home)"
  local users_count=$(wc -l <<< "$users")
    
  if [[ "$users_count" -eq 1 ]]; then
    echo "${users}"
    return 0
  elif [[ $users_count -gt 1 ]]; then
    lib__log_error "Find $users_count users in /home. Please rerun script and get username ($users). See more -h.";
  else
    lib__log_error "User directory in /home not found. Please create user home directory and rerun script."
  fi
  exit 1
}

lib__cp_config() {
  local home_config=${HOME_CONFIG:-"/home/$(lib__get_user)/.config"}
  local file="${1:?'Dont get file name!'}"
  local path="${2:-$home_config}"
  
  if [[ ! -d "$home_config" ]]; then
    if [[ -f "$home_config" ]]; then
      lib__log_error "Path $file is file. Please delete it and create .config dir."
      exit 1
    fi
    mkdir -p "$home_config"
    lib__ch_own "$home_config"
  fi

  if [[ -d "$path" ]]; then
    path="$path/$(basename $file)"
  fi
  
  lib__mk_dir $(dirname "$path")
  if [[ -n "${DOTFILES_DIR:-}" ]]; then
    cp -r "$DOTFILES_DIR/$file" "$path"
  else
    cp -r "$file" "$path"
  fi
  
  find "$path" -type d -exec chmod 700 {} +
  find "$path" -type f -exec chmod 600 {} +
  
  lib__ch_own "$path"
}

