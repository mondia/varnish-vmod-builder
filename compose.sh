#!/bin/bash

. ./defaults.sh

if [ ! -f ./docker-compose.yml ]; then
    cp template/docker-compose.yml ./docker-compose.yml
fi

mkdir -p test/config

if [ ! -f test/config/default.vcl ]; then
    cp template/default.vcl test/config/default.vcl
fi

if [ ! -f test/config/varnish.env ]; then
    cp template/varnish.env test/config/varnish.env
fi

export VARNISH_IMAGE=$VARNISH_IMAGE
export MODULES_DIR=./modules/dist/$VARNISH_COMPATIBILITY_VERSION/rpm
export NETWORK=$NETWORK

docker-compose $1