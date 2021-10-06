#!/bin/bash

# install_ansible.sh - Installs Ansible

if ! dpkg -l ansible > /dev/null 2>&1 ; then
  apt-get update && apt-get -y install ansible
fi
