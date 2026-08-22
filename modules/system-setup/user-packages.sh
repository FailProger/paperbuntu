# Script params
readonly SYSTEM_SETUP__USER_PACKAGES=(
  'sudo'
  'network-manager'
)

# Imports
source "$ROOT_DIR/lib/file.sh"

system_setup__setup_user_packages() {
  _system_setup__setup_sudo
  _system_setup__setup_network_manager
}

_system_setup__setup_sudo() {
  # Configure sudo run
  local sudoers_dir='/etc/sudoers.d'
  mk_dir "$sudoers_dir"
  
  echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | tee "$sudoers_dir/$USERNAME-nopasswd" > /dev/null
  chmod 440 "$sudoers_dir/$USERNAME-nopasswd"
}

_system_setup__setup_network_manager() {
  # Configure Network Manager
  local netplan_dir='/etc/netplan'
  mk_dir "$netplan_dir"
  
  cat > $netplan_dir/01-network-manager-all.yaml << EOF
network:
  version: 2
  renderer: NetworkManager
EOF
}

