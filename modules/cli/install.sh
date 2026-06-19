#!/usr/bin/env bash

set -eu

if [[ -z "${ROOT_DIR:-}" ]]; then
  echo "[ERROR] This is module. Please don't run it."
  exit 1
fi

# Script params
readonly CLI_INSTALL_DEPENDENCIES=(
  'wget'
  'gzip'
  'xz-utils'
  'build-essential'
  'xclip'
  'jq'
)
readonly CLI_PACKS=(
  'openssh-client'
  'zsh'
)

# Imports
source "$ROOT_DIR/lib/file.sh"
source "$ROOT_DIR/lib/utils.sh"

install_all() {
  # Install dependencies and cli programms from apt
  apt update &&
    apt install -y ${CLI_INSTALL_DEPENDENCIES[@]} &&
    apt install -y ${CLI_PACKS[@]}

  # Create temp dir
  local past_dir=$(pwd)
  local tmp_dir=$(mktemp -d)
  cd "$tmp_dir"
  
  # Install other cli programms
  # Shell
  _install_atuin; _install_shellfirm; _install_starship
  
  # Files
  _install_nvim; _install_gdu; _install_eza; _install_fzf; _install_zoxide
  
  cd "$past_dir"
  rm -rf "$tmp_dir"
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
  _mv_to_bin 'gdu'
}

_install_eza() {
  wget_download 'https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz'
  _mv_to_bin 'eza'
}

_install_fzf() {
  _get_version_and_download 'https://api.github.com/repos/junegunn/fzf/releases/latest' 'fzf-.*-linux_amd64.tar.gz'
  _mv_to_bin 'fzf'
}

_install_zoxide() {
  _get_version_and_download 'https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest' 'zoxide-.*-x86_64-unknown-linux-musl.tar.gz'
  _mv_to_bin 'zoxide'
}

_install_atuin() {
  wget_download 'https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz'
  _mv_to_bin 'atuin'
}

_install_shellfirm() {
  _get_version_and_download 'https://api.github.com/repos/kaplanelad/shellfirm/releases/latest' 'shellfirm-.*-x86_64-linux.tar.xz'
  _mv_to_bin 'shellfirm'
}

_install_starship() {
  wget_download 'https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz'
  _mv_to_bin 'starship'
}

_get_version_and_download() {
  local attempts=5
  local connect_timeout=5
  local read_timeout=5
  local between_timeout=2
  
  local repo_url="${1:?'Dont get repo url!'}"
  local file_name="${2:?'Dont get file name!'}"
  
  for (( i=0; i < "$attempts"; i++ )); do
    if wget -qO- --connect-timeout="$connect_timeout" --read-timeout="$read_timeout" "$repo_url" \
      | jq -r ".assets[] | select(.name | test(\"$file_name\")) | .browser_download_url" \
      | xargs wget --connect-timeout="$connect_timeout" --read-timeout="$read_timeout"; then
      return 0
    fi

    sleep "$between_timeout"
  done

  return 1
}

_mv_to_bin() {
  local file_name="${1:?'Dont get package name!'}"

  local out_dir="dir-$file_name"
  mk_dir "$out_dir"
  
  tar -xf "$file_name"* -C "$out_dir"
  
  find . -type f -name "*$file_name*" -perm -111 -exec mv {} "/usr/local/bin/$file_name" \;
  
  rm -rf *"$file_name"*
}
