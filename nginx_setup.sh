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
mkdir -p /srv/www/apt/debian /srv/www/apt/debian-security /srv/www/apt/ubuntu
chown www-data:www-data -R /srv/www/apt
cd /srv/www
ln -s /srv/www/apt/debian .
ln -s /srv/www/apt/debian-security .
ln -s /srv/www/apt/ubuntu .

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
ln -s /etc/nginx/sites-available/apt /etc/nginx/sites-enabled/

cp $CONF_DNSSPOOF_ETC /etc/dnsspoof.conf
cp $CONF_DNSSPOOF_DEF /etc/default/dnsspoof
cp $CONF_DNSSPOOF_INI /etc/init.d/dnsspoof
chmod 755 /etc/init.d/dnsspoof
update-rc.d dnsspoof defaults

/etc/init.d/nginx restart
/etc/init.d/dnsspoof stop
/etc/init.d/dnsspoof start
