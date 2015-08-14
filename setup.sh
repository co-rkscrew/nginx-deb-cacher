#!/bin/bash

function validate_var() {
	if [ -z "$2" ]; then
		echo "Missing variable: $1"
		exit 3
	fi
}

function get_or_else() {
	if [ -n "$1" ]; then
		echo "$1"
	else
		echo "$2"
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
DEB_CACHE_DEB_MIR=`get_or_else $DEB_CACHE_DEB_MIR ftp.us.debian.org`
DEB_CACHE_DEB_SMIR=`get_or_else $DEB_CACHE_DEB_SMIR security.debian.org`
DEB_CACHE_UBU_MIR=`get_or_else $DEB_CACHE_UBU_MIR us.archive.ubuntu.com`
DEB_CACHE_UBU_SMIR=`get_or_else $DEB_CACHE_UBU_SMIR security.ubuntu.com`

# generate files
$DIR/templates/tpl_vagrantfile.sh ${DEB_CACHE_IP_ADDR} > $DIR/Vagrantfile
$DIR/templates/tpl_apt.sh ${DEB_CACHE_IP_MASK} \
							${DEB_CACHE_DEB_MIR} \
							${DEB_CACHE_DEB_SMIR} \
							${DEB_CACHE_UBU_MIR} \
							${DEB_CACHE_UBU_SMIR} > $DIR/conf/apt
$DIR/templates/tpl_dnsspoof.sh ${DEB_CACHE_IP_ADDR} \
							${DEB_CACHE_DEB_MIR} \
							${DEB_CACHE_DEB_SMIR} \
							${DEB_CACHE_UBU_MIR} \
							${DEB_CACHE_UBU_SMIR} > $DIR/conf/dnsspoof.etc