#!/bin/bash

# ssh_destiny.sh - Configs SSH authentication in destiny MVs
# Includes origin MVs public keys into .ssh/authorized_keys

keys_file=~vagrant/.ssh/authorized_keys
[ -f "$keys_file" ] || touch "$keys_file"
[ "$(stat --format=%U:%G $keys_file)" = 'vagrant:vagrant' ] ||
  chown vagrant:vagrant "$keys_file"
[ "$(stat --format=%a $keys_file)" = '600' ] ||
  chmod 600 "$keys_file"

for origin in "$@" ; do
  key="$(
    ssh-keygen -y -f "/vagrant/.vagrant/machines/${origin}/virtualbox/private_key"
  )"
  grep -q "$key" "$keys_file" ||
    echo "$key" >> "$keys_file"
done
