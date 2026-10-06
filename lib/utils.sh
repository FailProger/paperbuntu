cleanup_apt() {
  local return_code="${1:-0}"
  
  apt autoremove -y; apt autoclean -y
  [[ "$return_code" -eq 0 ]] || exit "$return_code"
}

