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

  # create apt folders
  mkdir -p /srv/www/apt/debian /srv/www/apt/debian-security /srv/www/apt/ubuntu
  chown www-data:www-data -R /srv/www/apt
  cd /srv/www
  ln -s /srv/www/apt/debian .
  ln -s /srv/www/apt/debian-security .
  ln -s /srv/www/apt/ubuntu .

  # configure nginx
  cp /vagrant/conf/apt /etc/nginx/sites-available/apt
  ln -s /etc/nginx/sites-available/apt /etc/nginx/sites-enabled/
  
  cp /vagrant/conf/dnsspoof.initd /etc/init.d/dnsspoof
  chmod 755 /etc/init.d/dnsspoof
  update-rc.d dnsspoof defaults
  cp /vagrant/conf/dnsspoof.default /etc/default/dnsspoof
  
  /etc/init.d/nginx restart
  /etc/init.d/dnsspoof stop
  /etc/init.d/dnsspoof start
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "chef/debian-7.8"

  config.vm.network "private_network", ip: "${DEB_CACHE_IP_ADDR}"

  config.vm.provision "shell", inline: \$provision_script
end
END