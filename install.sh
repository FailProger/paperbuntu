#!/usr/bin/env bash

set -euo pipefail

# Global consts
readonly ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Imports
source "$ROOT_DIR/config.sh"
source "$ROOT_DIR/modules/imports.sh"

_usage() {
  cat << EOF
Usage: ./$(basename "$0") [COMMAND] [OPTION]...
Home page: github ($REPO_URL)

COMMANDS:
  full      Full installation debootstrap system and setup it.
  setup     Install kernel, all software and setup frash base system.
  software  Install all software and setup them.
  desktop   Install desktop environment for system and setup it.
  cli       Install CLI programms and setup them.
  gui       Install GUI programms and setup them.
  infosec   Install infosec tools and setup them.

  If do not get COMMAND but get all options will be used full themod.

OPTIONS:
  -h        This help message.
  -u        User who will be created in new system. If not getted
            will be used default username from ./config.sh.
  -p        Password for user in new system. If not getted will be
            used default password from ./config.sh.
  -d        Disk name for system installation. If not getted will
            be selected first disk. You can see disks run:
            lsblk | grep disk.
  -y        Run install without asking the permission.

EXAMPLES:
  ./install.sh -y
  ./install.sh full -u 'paperbuntu' -p 'paperbuntu' -d 'sda'
  ./install.sh cli -u 'paperbuntu'
  ./install.sh setup -u 'paperbuntu' -p 'paperbuntu' -d 'sda'
EOF
}

main() {
  local arg="${1:--h}"

  case "$arg" in
    -h)
      _usage; exit 0
      ;;
    software|desktop|cli|gui|infosec)
      command_software $@
      ;;
    -?|full|setup)
      command_full_or_setup $@
      ;;
    *)
      log_error "Uncorrect command: $arg"; echo; _usage; exit 1;;
  esac
}

main $@

