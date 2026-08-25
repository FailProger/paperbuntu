if [[ -n "${LIB_UTILS_LOADED:-}" ]]; then return 0; fi
readonly LIB_UTILS_LOADED=1

cleanup_apt() {
  local return_code="${1:-0}"
  
  apt autoremove -y; apt autoclean -y
  [[ "$return_code" -eq 0 ]] || exit "$return_code"
}

wget_download() {
  local attempts=5
  local connect_timeout=5
  local read_timeout=5
  local between_timeout=2
  
  local url="${1:?'Dont get url!'}"
  
  # Try 5 times download with wget
  for (( i=0; i < "$attempts"; i++ )); do
    if wget --connect-timeout="$connect_timeout" --read-timeout="$read_timeout" -c "$url"; then
      return 0
    fi

    sleep "$between_timeout"
  done

  return 1
}

wget_version_and_download() {
  local attempts=5
  local connect_timeout=5
  local read_timeout=5
  local between_timeout=2
  
  local repo_url="${1:?'Dont get repo url!'}"
  local file_name="${2:?'Dont get file name!'}"
  
  # Try 5 times get version download with wget
  for (( i=0; i < "$attempts"; i++ )); do
    if wget -qO- --connect-timeout="$connect_timeout" --read-timeout="$read_timeout" "$repo_url" \
      | jq -r ".assets[] | select(.name | test(\"$file_name\")) | .browser_download_url" \
      | xargs wget --connect-timeout="$connect_timeout" --read-timeout="$read_timeout"; then
      return 0
    fi

    sleep "$between_timeout"
  done

  return 1
}

