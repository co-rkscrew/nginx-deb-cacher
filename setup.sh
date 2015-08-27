#!/bin/bash

function validate_var() {
	if [ -z "$2" ]; then
		echo "Missing variable: $1"
		exit 3
	fi
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ "$#" -ne 1 ]; then
	echo "usage: setup.sh <variables_file>"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "file $1 not found!"
	echo "usage: setup.sh <variables_file>"
	exit 2
fi

source $1

# validation
validate_var "DEB_CACHE_IP_ADDR" $DEB_CACHE_IP_ADDR
validate_var "DEB_CACHE_IP_MASK" $DEB_CACHE_IP_MASK

# generate files
$DIR/templates/tpl_vagrantfile.sh ${DEB_CACHE_IP_ADDR} > $DIR/Vagrantfile
$DIR/templates/tpl_apt.sh ${DEB_CACHE_IP_MASK} > $DIR/conf/apt