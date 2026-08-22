if [[ -n "${COMMAND_FULL_OR_SETUP_LOADED:-}" ]]; then return 0; fi
readonly COMMAND_FULL_OR_SETUP_LOADED=1

# Imports
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/disk.sh"

source "$ROOT_DIR/modules/base-install/main.sh"
source "$ROOT_DIR/modules/system-setup/main.sh"
source "$ROOT_DIR/modules/chroot.sh"

source "$ROOT_DIR/modules/user-software/desktop/main.sh"
source "$ROOT_DIR/modules/user-software/cli/main.sh"
source "$ROOT_DIR/modules/user-software/gui/main.sh"
source "$ROOT_DIR/modules/user-software/pentest/main.sh"

command_full_or_setup() {
  local command="$1"

  if [[ "$command" == 'setup' || "$command" == 'full' ]]; then
    shift
  fi
  
  local username=''
  local password=''
  local disk_name=''
  local run_install=''
  
  # Get script options
  while getopts ':u:p:d:y' opt; do
    case "$opt" in
      u) username="$OPTARG";;
      p) password="$OPTARG";;
      d) disk_name="$OPTARG";;
      y) run_install='yes';;
      ?) log_error "Uncorrect option: -$OPTARG."; exit 1;;
    esac
  done

  # Get disk name
  readonly DISK_NAME=${disk_name:-$(get_disk_name)}; unset disk_name
  
  # Ask user continue installation
  while [[ -z "$run_install" ]]; do
    local read_text=''
    
    if [[ "$command" == 'setup' ]]; then
      read_text="WARNING: This script is designed to setup a fresh base system, it IS NOT SAFE to run on an already configured, or personally customized machine, continue? [Y/N] "
    else
      read_text="WARNING: All data on disk $DISK_NAME will be erased, continue? [Y/N] "
    fi
    read -p "$read_text" run_install
      
    case $run_install in
      Y|y|Yes|YES|yes) break;;
      N|n|No|NO|no) echo 'Exit...'; exit 0;;
      *) run_install=''; log_error 'Please enter Yes/No.'; continue;;
    esac
  done

  unset run_install

  # Get install params
  readonly USERNAME="${username:-$DEFAULT_USERNAME}"; unset username
  readonly PASSWORD="${password:-$DEFAULT_PASSWORD}"; unset password
  readonly HOME="/home/$USERNAME"
  readonly HOME_CONFIG="$HOME/.config"
  
  if [[ "$command" == 'setup' ]]; then
    setup_system
    install_desktop; install_cli; install_gui; install_pentest
  else
    install_base
    chroot_setup
  fi 
}

