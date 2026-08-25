# Script params
readonly USER_SOFTWARE_CLI__INSTALL_DEPENDENCIES=(
  'sudo'
  'wget'
  'gzip'
  'build-essential'
)
readonly USER_SOFTWARE_CLI__INSTALL_PACKAGES=(
  'openssh-client'
  'zsh'
  'git'
  '7zip'
  'xz-utils'
  'zstd'
  'xclip'
  'jq'
)

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/utils.sh"

user_software_cli__install_all() {
  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Install other cli programms
  # Shell
  _install_zinit; _install_atuin; _install_shellfirm; _install_starship
  
  # Files
  _install_nvim; _install_gdu; _install_eza; _install_fzf; _install_zoxide

  normalize_local_bin
  
  cd "$past_dir"
  rm -rf "$tmp_dir"
}

_install_zinit() {
  sudo -u "$USERNAME" /usr/bin/bash -s << 'EOF'
NO_INPUT=1 NO_ANNEXES=1 NO_EDIT=1 NO_TUTORIAL=1 \
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
EOF
}

_install_nvim() {
  wget_download 'https://github.com/neovim/neovim/releases/download/v0.11.7/nvim-linux-x86_64.tar.gz'

  mk_dir /opt
  tar -xf 'nvim'* -C /opt
  mv /opt/nvim* /opt/nvim
  ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim

  rm -rf *'nvim'*
}

_install_gdu() {
  wget_download 'https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz'
  _user_software_cli__mv_to_bin 'gdu'
}

_install_eza() {
  wget_download 'https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz'
  _user_software_cli__mv_to_bin 'eza'
}

_install_fzf() {
  wget_version_and_download 'https://api.github.com/repos/junegunn/fzf/releases/latest' 'fzf-.*-linux_amd64.tar.gz'
  _user_software_cli__mv_to_bin 'fzf'
}

_install_zoxide() {
  wget_version_and_download 'https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest' 'zoxide-.*-x86_64-unknown-linux-musl.tar.gz'
  _user_software_cli__mv_to_bin 'zoxide'
}

_install_atuin() {
  wget_download 'https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz'
  _user_software_cli__mv_to_bin 'atuin'
}

_install_shellfirm() {
  wget_version_and_download 'https://api.github.com/repos/kaplanelad/shellfirm/releases/latest' 'shellfirm-.*-x86_64-linux.tar.xz'
  _user_software_cli__mv_to_bin 'shellfirm'
}

_install_starship() {
  wget_download 'https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz'
  _user_software_cli__mv_to_bin 'starship'
}

_user_software_cli__mv_to_bin() {
  local file_name="${1:?'Dont get package name!'}"

  local out_dir="dir-$file_name"
  mk_dir "$out_dir"
  
  tar -xf "$file_name"* -C "$out_dir"
  
  find . -type f -name "*$file_name*" -perm -111 -exec mv {} "/usr/local/bin/$file_name" \;
  
  rm -rf *"$file_name"*
}

