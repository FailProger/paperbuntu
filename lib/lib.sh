#!/usr/bin/env bash

log_error() {
  echo "[ERROR] $1" >&2
}

mk_dir() {
  if [[ ! -e "$1" ]]; then
    mkdir -p "$1"
  elif [[ -f "$1" ]]; then
    log_error "Path $1 is file. Please delete it or rename."
    exit 1
  fi
  echo "$1"
}

ch_own() {
  chown -R $USERNAME:$USERNAME "$1"
}

cp_config() {
  if [[ ! -d "$HOME_CONFIG" ]]; then
    if [[ -f "$HOME_CONFIG" ]]; then
      log_error "Path $1 is file. Please delete it and create .config dir."
      exit 1
    fi
    mkdir -p "$HOME_CONFIG"
    ch_own "$HOME_CONFIG"
  fi

  local path=${2:-$HOME_CONFIG}
  if [[ -d "$path" ]]; then
    path="$path/$(basename $1)"
  fi
  
  mk_dir $(dirname "$path") > /dev/null
  cp -r "$CONFIG_DIR/$1" "$path"
  
  find "$path" -type d -exec chmod 700 {} +
  find "$path" -type f -exec chmod 600 {} +
  
  ch_own "$path"
}

get_user() {
  local users="$(ls /home)"
  local users_count=$(wc -l <<< "$users")
    
  if [[ "$users_count" -eq 1 ]]; then
    echo "${users}"
    return 0
  elif [[ $users_count -gt 1 ]]; then
    log_error "Find $users_count users in /home. Please rerun script and get username ($users)."; echo
    usage
  else
    log_error "User directory in /home not found. Please create user home directory and rerun script."
  fi
  
  exit 1
}

cleanup_apt() {
  apt autoremove -y && apt autoclean -y
  exit ${1:-1}
}
