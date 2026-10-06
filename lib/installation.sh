mv_to_local_bin() {
  local file_name="${1:?'Dont get package name!'}"

  local out_dir="dir-$file_name"
  mk_dir "$out_dir"
  
  tar -xf "$file_name"* -C "$out_dir"
  
  find . -type f -name "*$file_name*" -perm -111 -exec mv {} "/usr/local/bin/$file_name" \;
  
  rm -rf *"$file_name"*
}

