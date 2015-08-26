#!/bin/bash

function validate_file {
	if [ ! -f $1 ]; then
		echo "conf file $1 not found!"
		exit 2
	fi
}

if [ "$#" -ne 1 ]; then
	echo "usage: nginx_setup.sh <conf_path>"
	exit 1
fi


# create apt folders
rm -rf /srv
mkdir -p /srv/www/apt/debian /srv/www/apt/debian-security /srv/www/apt/ubuntu /srv/www/apt/daily-images /srv/www/cache/partial
chown www-data:www-data -R /srv/www/apt
ln -sf /srv/www/apt/debian /srv/www
ln -sf /srv/www/apt/debian-security /srv/www
ln -sf /srv/www/apt/ubuntu /srv/www
ln -sf /srv/www/apt/daily-images /srv/www

CONF_DIR="$1"
CONF_APT="$CONF_DIR/apt"
CONF_DNSSPOOF_DEF="$CONF_DIR/dnsspoof.default"
CONF_DNSSPOOF_ETC="$CONF_DIR/dnsspoof.etc"
CONF_DNSSPOOF_INI="$CONF_DIR/dnsspoof.initd"

validate_file "$CONF_APT"
validate_file "$CONF_DNSSPOOF_DEF"
validate_file "$CONF_DNSSPOOF_ETC"
validate_file "$CONF_DNSSPOOF_INI"

# configure nginx
cp $CONF_APT /etc/nginx/sites-available/apt
ln -sf /etc/nginx/sites-available/apt /etc/nginx/sites-enabled/

cp $CONF_DNSSPOOF_ETC /etc/dnsspoof.conf
cp $CONF_DNSSPOOF_DEF /etc/default/dnsspoof
cp $CONF_DNSSPOOF_INI /etc/init.d/dnsspoof
chmod 755 /etc/init.d/dnsspoof
update-rc.d dnsspoof defaults

/etc/init.d/nginx restart
/etc/init.d/dnsspoof stop
/etc/init.d/dnsspoof start
