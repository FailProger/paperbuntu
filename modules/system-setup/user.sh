system_setup__setup_user() {
  _system_setup__add_user
}

_system_setup__add_user() {
  # Add user
  useradd -m -s /bin/bash -G sudo "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd || passwd "$USERNAME"
}

