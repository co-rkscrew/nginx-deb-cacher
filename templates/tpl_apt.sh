#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "usage: tpl_apt.sh <DEB_CACHE_IP_MASK>"
  echo "                  <DEB_CACHE_DEB_MIR>"
  echo "                  <DEB_CACHE_DEB_SMIR>"
  echo "                  <DEB_CACHE_UBU_MIR>"
  echo "                  <DEB_CACHE_UBU_SMIR>"
  exit 1
fi

DEB_CACHE_IP_MASK=$1

DEB_CACHE_DEB_MIR=$2
DEB_CACHE_DEB_SMIR=$3
DEB_CACHE_UBU_MIR=$4
DEB_CACHE_UBU_SMIR=$5

cat <<END
# apt spoof/proxy
server  {
  listen 80;
  server_name ${DEB_CACHE_DEB_MIR} ${DEB_CACHE_DEB_SMIR} ${DEB_CACHE_UBU_MIR} ${DEB_CACHE_UBU_SMIR};

  access_log /var/log/nginx/apt.access.log;
  error_log /var/log/nginx/apt.error.log;

  root /srv/www/;
  resolver 127.0.0.1;

  allow ${DEB_CACHE_IP_MASK};
  allow 127.0.0.1;
  deny all;

  location /debian/pool/ {
    try_files \$uri @mirror;
  }

  # try cache dist later
  #location /debian/dists/ {
  #  try_files \$uri @mirror;
  #}

  location /debian/docs/ {
    try_files \$uri @mirror;
  }

  location /debian-security/pool/ {
    try_files \$uri @mirror;
  }

  location /ubuntu/pool/ {
    try_files \$uri @mirror;
  }

  location / {
    proxy_next_upstream error timeout http_404;
    proxy_pass http://\$host\$request_uri;
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded_For \$proxy_add_x_forwarded_for;
    add_header X-Mirror-Upstream-Status \$upstream_status;
    add_header X-Mirror-Upstream-Response-Time \$upstream_response_time;
    add_header X-Mirror-Status \$upstream_cache_status;
  }

  location @mirror {
    access_log /var/log/nginx/apt.remote.log;
    proxy_store on;
    proxy_store_access user:rw group:rw all:r;
    proxy_next_upstream error timeout http_404;
    proxy_pass http://\$host\$request_uri;
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded_For \$proxy_add_x_forwarded_for;
    add_header X-Mirror-Upstream-Status \$upstream_status;
    add_header X-Mirror-Upstream-Response-Time \$upstream_response_time;
    add_header X-Mirror-Status \$upstream_cache_status;
   }
}
END