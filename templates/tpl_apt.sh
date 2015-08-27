#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "usage: tpl_apt.sh <DEB_CACHE_IP_MASK>"
  exit 1
fi

DEB_CACHE_IP_MASK=$1

cat <<END
# apt spoof/proxy

proxy_cache_path /srv/www/cache levels=1 keys_zone=STATIC:10m inactive=30d max_size=12g;

server  {
  listen 80;
  server_name .debian.org d-i.debian.org;

  access_log /var/log/nginx/apt.access.log;
  error_log /var/log/nginx/apt.error.log;

  root /srv/www/;
  resolver 8.8.8.8;

  allow ${DEB_CACHE_IP_MASK};
  allow 127.0.0.1;
  deny all;

  location /debian/dists/ {
    access_log /var/log/nginx/apt.dists.log;
    proxy_pass http://\$host\$request_uri;
    proxy_redirect off;
    proxy_set_header Host \$host; proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    client_max_body_size 100m;
    client_body_buffer_size 1m;
    proxy_cache STATIC;
    proxy_temp_path /srv/www/cache/partial;
    proxy_store_access user:rw group:rw all:r;
    proxy_cache_valid 30d;
    # might be interesting to /debian/pool
    #proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
  }

  location /debian/ {
    try_files \$uri @mirror;
  }

  location /debian-security/dists {
    access_log /var/log/nginx/apt.dists.log;
    proxy_pass http://\$host\$request_uri;
    proxy_redirect off;
    proxy_set_header Host \$host; proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    client_max_body_size 100m;
    client_body_buffer_size 1m;
    proxy_cache STATIC;
    proxy_temp_path /srv/www/cache/partial;
    proxy_store_access user:rw group:rw all:r;
    proxy_cache_valid 30d;
    # might be interesting to /debian-security/pool
    #proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
  }

  location /debian-security/ {
    try_files \$uri @mirror;
  }

  # http://d-i.debian.org/daily-images/amd64/daily/*
  location /daily-images/amd64/daily/ {
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