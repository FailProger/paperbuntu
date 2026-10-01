# Global consts
readonly MODULES_DIR=$(dirname "${BASH_SOURCE[0]}")

# For imports
commands_dir="$MODULES_DIR/commands"

scripts_dir="$MODULES_DIR/scripts"
user_software_dir="$scripts_dir/user-software"

# Imports
source "$MODULES_DIR/../lib/main.sh"

source "$commands_dir/full-or-setup.sh"
source "$commands_dir/software.sh"

source "$scripts_dir/base-install/main.sh"
source "$scripts_dir/system-setup/main.sh"
source "$scripts_dir/chroot.sh"

source "$user_software_dir/desktop/main.sh"
source "$user_software_dir/cli/main.sh"
source "$user_software_dir/gui/main.sh"
source "$user_software_dir/pentest/main.sh"

unset commands_dir; unset scripts_dir; unset user_software_dir

