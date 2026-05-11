#!/usr/bin/env bash

set -eu

# Script params    INFO: Mey be edited
readonly REPO_URL="https://github.com/FailProger/paperbuntu"
readonly CONFIG_DIR_NAME="user-config"
readonly LIB_FILE_NAME="lib.sh"

readonly INSTALL_DEPENDENCIES=("git" "curl" "wget" "build-essential" "xclip" "gdu")
readonly INSTALL_CLI=("zsh" "neovim")

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

install_cli() {
  # Install dependencies
  apt update && apt install -y ${INSTALL_DEPENDENCIES[@]}
  cp_config "git/gitconfig" "$HOME/.gitconfig"

  # Install cli programm
  apt update && apt install -y ${INSTALL_CLI[@]}
  
  # Configure zsh
  chsh -s "$(which zsh)" "$USERNAME"
  # Remove oh-my-zsh if exists
  local omz_dir="$HOME/.oh-my-zsh"
  [[ -d "$omz_dir" ]] && rm -r "$omz_dir"
  # Install oh my zsh
  export RUNZSH=no
  sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # Install plugins and Powerlevel10k
  local omz_custom_dir="$omz_dir/custom"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$omz_custom_dir/plugins/zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$omz_custom_dir/plugins/zsh-syntax-highlighting"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$omz_custom_dir/themes/powerlevel10k"
  # Change own
  ch_own "$omz_dir"
  # Copy config files
  cp_config "zsh/zshrc" "$HOME/.zshrc"
  cp_config "p10k/p10k.zsh" "$HOME/.p10k.zsh"

  unset omz_dir
  unset omz_custom_dir

  # Configure nvim
  cp_config "nvim"
  
  # Install lla
  curl -sSL https://raw.githubusercontent.com/chaqchase/lla/main/install.sh | bash
  cp_config "lla"

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

  trap cleanup_apt SIGINT SIGTERM
  install_cli
}

main "$@"
