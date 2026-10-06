# Global consts
readonly LIB_UTILS__ATTEMPTS=5
readonly LIB_UTILS__CONNECT_TIMEOUT=5
readonly LIB_UTILS__READ_TIMEOUT=5
readonly LIB_UTILS__BETWEEN_TIMEOUT=2

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
  local file_name="${2:?'Do not get file name!'}"
  local download_url=''
  
  for (( i=0; i < "$LIB_UTILS__ATTEMPTS"; i++ )); do
    download_url=$(
      wget -qO- --connect-timeout="$LIB_UTILS__CONNECT_TIMEOUT" --read-timeout="$LIB_UTILS__READ_TIMEOUT" "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"browser_download_url":\s*"\K[^"]+' \
        | grep "$file_name"
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
      wget -qO- --connect-timeout="$LIB_UTILS__CONNECT_TIMEOUT" --read-timeout="$LIB_UTILS__READ_TIMEOUT" "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"tag_name":\s*"\K[^"]+'
    )
      
    if [[ -n "$version" ]]; then
      echo "$version"
      return 0
    fi

    sleep "$LIB_UTILS__BETWEEN_TIMEOUT"
  done

  return 1
}

_user_software_cli__mv_to_bin() {
  local file_name="${1:?'Dont get package name!'}"

  local out_dir="dir-$file_name"
  mk_dir "$out_dir"
  
  tar -xf "$file_name"* -C "$out_dir"
  
  find . -type f -name "*$file_name*" -perm -111 -exec mv {} "/usr/local/bin/$file_name" \;
  
  rm -rf *"$file_name"*
}

