#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "usage: tpl_dnsspoof.sh <DEB_CACHE_IP_ADDR>"
  echo "                       <DEB_CACHE_DEB_MIR>"
  echo "                       <DEB_CACHE_DEB_SMIR>"
  echo "                       <DEB_CACHE_UBU_MIR>"
  echo "                       <DEB_CACHE_UBU_SMIR>"
  exit 1
fi

DEB_CACHE_IP_ADDR=$1

DEB_CACHE_DEB_MIR=$2
DEB_CACHE_DEB_SMIR=$3
DEB_CACHE_UBU_MIR=$4
DEB_CACHE_UBU_SMIR=$5

cat <<END
${DEB_CACHE_IP_ADDR}	${DEB_CACHE_DEB_MIR}
${DEB_CACHE_IP_ADDR}	${DEB_CACHE_DEB_SMIR}
${DEB_CACHE_IP_ADDR}	${DEB_CACHE_UBU_MIR}
${DEB_CACHE_IP_ADDR}	${DEB_CACHE_UBU_SMIR}
END