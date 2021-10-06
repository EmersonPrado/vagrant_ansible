#!/bin/bash

# ssh_origin.sh - Configs SSH authentication in origin VMs
# Includes destiny VMs into file /home/vagrant/.ssh/known_hosts
# Copies private key to default path .ssh/id_rsa

original=/vagrant/.vagrant/machines/${1}/virtualbox/private_key
copy=~vagrant/.ssh/id_rsa
if ! [ -f "$copy" ] || ! diff -q "$original" "$copy" > /dev/null 2>&1 ; then
  cp "$original" "$copy"
fi
[ "$(stat --format=%U:%G $copy)" = 'vagrant:vagrant' ] ||
  chown vagrant:vagrant "$copy"
[ "$(stat --format=%a $copy)" = '600' ] ||
  chmod 600 "$copy"

shift

hosts_file=~vagrant/.ssh/known_hosts
[ -f "$hosts_file" ] ||
  touch "$hosts_file"
[ "$(stat --format=%U:%G $hosts_file)" = 'vagrant:vagrant' ] ||
  chown vagrant:vagrant "$hosts_file"
[ "$(stat --format=%a $hosts_file)" = '600' ] ||
  chmod 600 "$hosts_file"

for destiny in "$@" ; do
  chave="$(ssh-keyscan -t rsa "$destiny" 2> /dev/null)"
  if [ -n "$chave" ] ; then
    grep -q "$chave" "$hosts_file" || {
      ssh-keygen -F "$destiny" -f "$hosts_file" && ssh-keygen -R "$destiny" -f "$hosts_file"
      echo "$chave" >> "$hosts_file"
    }
  else
    {
      echo
      echo "Destiny host not found!"
      echo "Provision origin host $1 again after destiny host $destiny creation"
      echo
    } >&2
  fi
done
