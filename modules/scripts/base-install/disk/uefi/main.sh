source "$SCRIPTS_DIR/base-install/disk/uefi/ext4.sh"

bi_d_u__partition_uefi() {
  case "$FILE_SYSTEM" in
    ext4)
      bi_d_u_ext4__partition_ext4
      ;;
    *)
      lib__log_error "Unsupporting file system to parting: $FILE_SYSTEM"; exit 1;;
  esac
}

