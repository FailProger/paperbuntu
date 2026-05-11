#!/usr/bin/env bash

set -eu

# Script params    INFO: Mey be edited
readonly REPO_URL="https://github.com/FailProger/paperbuntu"
readonly CONFIG_DIR_NAME="user-config"
readonly LIB_FILE_NAME="lib.sh"
readonly GUI_INSTALL=(
  "xorg"
  "i3"
  "i3status"
  "dmenu"
  "j4-dmenu-desktop"
  "feh"
  "sddm"
  )

# Global conts
readonly ROOT_DIR=$(dirname "$0")
readonly CONFIG_DIR="$ROOT_DIR/$CONFIG_DIR_NAME"
readonly LIB_FILE="$ROOT_DIR/lib/$LIB_FILE_NAME"

usage() {
  cat << EOF
Usage: ./$(basename "$0") [OPTION] [<USERNAME>]
Home page: github ($REPO_URL)
OPTIONS:
  -h    This help message.
ARGUMENTS:
  USERNAME    User for which i3 will be configured. If not getted
              will be selected the user who has dir in /home. If
              users count more then 1 script will breaked.
EOF
}

cleanup() {
  apt autoremove -y && apt autoclean -y
  exit ${1:-1}
}
trap cleanup SIGINT SIGTERM

install_i3() {
  # GUI install
  apt update && apt install -y ${GUI_INSTALL[@]}
  cp_config "i3"
  cp_config "i3status"

  local sddm_dir=$(mk_dir "/etc/sddm.conf.d")
  cat > $sddm_dir/autologin.conf << EOF
  [Autologin]
  User=$USERNAME
  Session=i3
EOF

  cleanup 0
}

main() {
  source "$LIB_FILE"
  
  # Get script options
  while getopts ":h" opt; do
    case "$opt" in
      h) usage; exit 0;;
      ?) log_error "Uncorrect option: -$OPTARG."; echo; usage; exit 1;;
    esac
  done

  # Check arguments count
  if [[ "$#" -gt 1 ]]; then
    log_error "Given many arguments."; echo
    usage; exit 1
  fi
  
  # Check root user
  if [[ $EUID -ne 0 ]]; then
    log_error "Run script as root."
    exit 1
  fi

  # Get install params
  readonly USERNAME="${1:-$(get_user)}"
  readonly HOME="/home/$USERNAME"
  readonly HOME_CONFIG="$HOME/.config"

  install_i3
}

main "$@"
