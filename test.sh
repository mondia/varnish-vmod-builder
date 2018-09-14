#!/bin/bash

. ./defaults.sh

export VARNISH_IMAGE=$VARNISH_IMAGE
export MODULES_DIR=./modules/dist/$VARNISH_COMPATIBILITY_VERSION/rpm

docker-compose up