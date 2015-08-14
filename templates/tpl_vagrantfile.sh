#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "usage: tpl_vagrantfile.sh <DEB_CACHE_IP_ADDR>"
  exit 1
fi

DEB_CACHE_IP_ADDR=$1


cat <<END
# -*- mode: ruby -*-
# vi: set ft=ruby :

\$provision_script = <<SCRIPT
  apt-get update
  apt-get install -y nginx dsniff bind9

  /vagrant/nginx_setup.sh /vagrant/conf
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "chef/debian-7.8"

  config.vm.network "private_network", ip: "${DEB_CACHE_IP_ADDR}"

  config.vm.provision "shell", inline: \$provision_script
end
END