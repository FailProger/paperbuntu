log_error() {
  local message="${1:?'Dont get log message!'}"
  
  echo "[ERROR] $message" >&2
}

