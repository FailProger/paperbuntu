if [[ -n "${LIB_UTILS_LOADED:-}" ]]; then return 0; fi
readonly LIB_UTILS_LOADED=1

# Global consts
readonly LIB_UTILS__ATTEMPTS=5
readonly LIB_UTILS__CONNECT_TIMEOUT=5
readonly LIB_UTILS__READ_TIMEOUT=5
readonly LIB_UTILS__BETWEEN_TIMEOUT=2

cleanup_apt() {
  local return_code="${1:-0}"
  
  apt autoremove -y; apt autoclean -y
  [[ "$return_code" -eq 0 ]] || exit "$return_code"
}

wget_download() {
  local url="${1:?'Do not get url!'}"
  
  for (( i=0; i < "$LIB_UTILS__ATTEMPTS"; i++ )); do
    if wget --connect-timeout="$LIB_UTILS__CONNECT_TIMEOUT" --read-timeout="$LIB_UTILS__READ_TIMEOUT" -c "$url"; then
      return 0
    fi

    sleep "$LIB_UTILS__BETWEEN_TIMEOUT"
  done

  return 1
}

wget_github_repo_download_latest() {
  local repo="${1:?'Do not get repo!'}"
  local download_url=''
  
  for (( i=0; i < "$LIB_UTILS__ATTEMPTS"; i++ )); do
    download_url=$(
      wget -qO- --connect-timeout="$LIB_UTILS__CONNECT_TIMEOUT" --read-timeout="$LIB_UTILS__READ_TIMEOUT" "https://api.github.com/repos/$repo/releases/latest" |
        grep -oP '"browser_download_url":\s*"\K[^"]+'
    )
    
    if [[ -n "$download_url" ]]; then
      wget_download "$download_url"
      return 0
    fi
    
    sleep "$LIB_UTILS__BETWEEN_TIMEOUT"
  done

  return 1
}

wget_github_repo_latest_version() {
  local repo="${1:?'Do not get repo!'}"
  local version=''
  
  for (( i=0; i < "$LIB_UTILS__ATTEMPTS"; i++ )); do
    version=$(
      wget -qO- --connect-timeout="$LIB_UTILS__CONNECT_TIMEOUT" --read-timeout="$LIB_UTILS__READ_TIMEOUT" "https://api.github.com/repos/$repo/releases/latest" |
        grep -oP '"tag_name":\s*"\K[^"]+'
    )
      
    if [[ -n "$version" ]]; then
      echo "$version"
      return 0
    fi

    sleep "$LIB_UTILS__BETWEEN_TIMEOUT"
  done

  return 1
}

