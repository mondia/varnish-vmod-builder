#!/usr/bin/env bash

#!/bin/sh

. .env
. defaults.sh

mkdir -p benchmark

VARNISH_PORT=$(grep VARNISH_LISTEN_PORT test/config/varnish.env | awk -F '=' '{print $2}')

echo "***********************************************************************************"
echo
echo "Testing Varnish '${VARNISH_VERSION}' endpoint availability: http://varnish:$VARNISH_PORT/"
echo ------PING::
docker run --network=$NETWORK --rm willfarrell/ping sh -c "ping -c 1 varnish"
echo
echo ------CURL::
docker run --network=$NETWORK --rm=true appropriate/curl -X $METHOD -s -I "http://varnish:$VARNISH_PORT/"
echo ==============================================
echo "Benchmark for Varnish '${VARNISH_VERSION}' endpoint: http://varnish:$VARNISH_PORT/"
echo ------AB::
docker run --network=$NETWORK --rm=true --read-only -v `pwd`:`pwd` -w `pwd` jordi/ab \
    -l -k -c $CONCURRENT -n $NR_OF_REQUESTS -m $METHOD "http://varnish:$VARNISH_PORT/" | tee benchmark/$VARNISH_VERSION.log

bold=$(tput bold)
normal=$(tput sgr0)

echo ++++++++++++++++++++++++++++++++++
echo SUMMARY:
echo ----------------------------------
echo Requests:      ${bold}$NR_OF_REQUESTS${normal}
echo Concurrency:   ${bold}$CONCURRENT${normal}
echo ----------------------------------
echo "Varnish: ${bold}$VARNISH_VERSION${normal}"
cat benchmark/$VARNISH_VERSION.log | grep 'Time per request'
echo ---------
echo ++++++++++++++++++++++++++++++++++
