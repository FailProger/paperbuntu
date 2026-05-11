#!/usr/bin/env bash

set -eu

# Script params    INFO: Mey be edited
readonly REPO_URL="https://github.com/FailProger/paperbuntu"
readonly CONFIG_DIR_NAME="user-config"
readonly LIB_FILE_NAME="lib.sh"

readonly INSTALL_DEPENDENCIES=("build-essential" "git")

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

cp_config() {
  local path=${2:-$HOME_CONFIG}
  if [[ -d "$path" ]]; then
    path="$path/$(basename $1)"
  fi
  
  mk_dir $(dirname "$path") > /dev/null
  cp -r "$CONFIG_DIR/$1" "$path"
  
  find "$path" -type d -exec chmod 700 {} +
  find "$path" -type f -exec chmod 600 {} +
}

install_keyd() {
  # Install dependencies
  apt update && apt install -y ${INSTALL_DEPENDENCIES[@]}

  # Install and configure keyd
  local keyd_dir="/tmp/keyd-install"
  [[ -d $keyd_dir ]] && rm -rf $keyd_dir
  git clone https://github.com/rvaiya/keyd $keyd_dir
  cd $keyd_dir
  make && make install
  cd /
  rm -rf $keyd_dir
  cp_config "keyd" /etc
  systemctl enable keyd && systemctl start keyd

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

  trap cleanup SIGINT SIGTERM
  install_keyd
}

main "$@"
