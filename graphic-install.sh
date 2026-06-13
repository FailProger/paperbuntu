#!/usr/bin/env bash

set -eu

# Script params
readonly DEPENDENCIES=(
  "curl"
  "zip"
  "unzip"
  "fontconfig"
)
readonly GUI_PACKS=(
  "xorg"
  "i3"
  "i3status"
  "dmenu"
  "j4-dmenu-desktop"
  "feh"
  "sddm"
)

# Global consts
readonly ROOT_DIR=$(dirname "$0")

# Imports
source "$ROOT_DIR/config.sh"

source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/user.sh"
source "$ROOT_DIR/lib/utils.sh"

_usage() {
  cat << EOF
Usage: ./$(basename "$0") [OPTION] [<USERNAME>]
Home page: github ($REPO_URL)
OPTIONS:
  -h    This help message.
ARGUMENTS:
  USERNAME    User for which programms will be installed. If not getted
              will be selected the user who has dir in /home. If
              users count more then 1 script will breaked.
EOF
}

_install_graphic() {
  trap 'cleanup_apt 1' SIGINT SIGTERM
  
  # GUI install
  apt update &&
    apt install -y ${DEPENDENCIES[@]} &&
    apt install -y ${GUI_PACKS[@]}
  
  cp_config "i3"
  cp_config "i3status"

  local sddm_dir=$(mk_dir "/etc/sddm.conf.d")
  cat > $sddm_dir/autologin.conf << EOF
[Autologin]
User=$USERNAME
Session=i3
EOF

  _install_fonts

  cleanup_apt
}

_install_fonts() {
  # Install Hack Nerd Font
  local nerd_fonts_dir=$(mk_dir "/usr/local/share/fonts/hack-nerd-font/")
  curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
  unzip Hack.zip -d "$nerd_fonts_dir"
  rm Hack.zip
  rm "$nerd_fonts_dir/LICENSE.md" "$nerd_fonts_dir/README.md"
  chmod -R 644 $nerd_fonts_dir/*
  chmod +x $nerd_fonts_dir
  fc-cache -fv
}

main() {
  # Get script options
  while getopts ":h" opt; do
    case "$opt" in
      h) _usage; exit 0;;
      ?) log_error "Uncorrect option: -$OPTARG."; echo; _usage; exit 1;;
    esac
  done

  # Check arguments count
  if [[ "$#" -gt 1 ]]; then
    log_error "Given many arguments."; echo
    _usage; exit 1
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

  _install_graphic
}

main "$@"
