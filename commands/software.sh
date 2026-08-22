if [[ -n "${COMMAND_SOFTWARE_LOADED:-}" ]]; then return 0; fi
readonly COMMAND_SOFTWARE_LOADED=1

# Imports
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/user.sh"

source "$ROOT_DIR/modules/user-software/desktop/main.sh"
source "$ROOT_DIR/modules/user-software/cli/main.sh"
source "$ROOT_DIR/modules/user-software/gui/main.sh"
source "$ROOT_DIR/modules/user-software/pentest/main.sh"

command_software() {
  local command="$1"
  shift
  
  local username=''
  local run_install=''
  
  # Get script options
  while getopts ':u:y' opt; do
    case "$opt" in
      u) username="$OPTARG";;
      y) run_install='yes';;
      ?) log_error "Uncorrect option: -$OPTARG."; exit 1;;
    esac
  done
  
  # Ask user continue installation
  while [[ -z "$run_install" ]]; do
    read -p 'WARNING: A lot custom software will be installed on this system, continue? [Y/N] ' run_install
    case $run_install in
      Y|y|Yes|YES|yes) break;;
      N|n|No|NO|no) echo 'Exit...'; exit 0;;
      *) run_install=''; log_error 'Please enter Yes/No.'; continue;;
    esac
  done

  unset run_install

  # Get install params
  readonly USERNAME="${username:-$(get_user)}"; unset username
  readonly HOME="/home/$USERNAME"
  readonly HOME_CONFIG="$HOME/.config"

  if [[ "$command" == 'software' ]]; then
    install_desktop; install_cli; install_gui; install_pentest
  else
    eval "install_$command"
  fi
}

