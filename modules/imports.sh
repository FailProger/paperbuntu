# Global consts
readonly MODULES_DIR=$(dirname "${BASH_SOURCE[0]}")

# For imports in script files
readonly SCRIPTS_DIR="$MODULES_DIR/scripts"

# Imports
source "$MODULES_DIR/../lib/main.sh"

source "$MODULES_DIR/commands/full-or-setup.sh"
source "$MODULES_DIR/commands/software.sh"

source "$SCRIPTS_DIR/base-install/main.sh"
source "$SCRIPTS_DIR/system-setup/main.sh"
source "$SCRIPTS_DIR/chroot.sh"

source "$SCRIPTS_DIR/user-software/desktop/main.sh"
source "$SCRIPTS_DIR/user-software/cli/main.sh"
source "$SCRIPTS_DIR/user-software/gui/main.sh"
source "$SCRIPTS_DIR/user-software/infosec/main.sh"

