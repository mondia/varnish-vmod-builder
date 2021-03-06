#!/bin/bash

. .env

function line {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ${1:-=}
}

CENTOS_VERSION=${CENTOS_VERSION:-7.5.1804}
CENTOS_VERSION_MINOR=${CENTOS_VERSION%.*}
CENTOS_VERSION_MAJOR=${CENTOS_VERSION%%.*}
IMAGE_OWNER=${IMAGE_OWNER:-mondiamedia}
VARNISH_VERSION=${VARNISH_VERSION:-6.0.1-1}
VARNISH_VERSION_MINOR=${VARNISH_VERSION%.*}
VARNISH_PKG_VERSION=${VARNISH_PKG_VERSION:-${VARNISH_VERSION_MINOR/./''}}
VARNISH_COMPATIBILITY_VERSION=${VARNISH_VERSION%-*}

VARNISH_RELEASE=${VERSION#*-}
VARNISH_RELEASE=${VARNISH_RELEASE#$VERSION}
VARNISH_RELEASE=${VARNISH_RELEASE:-1}

if [ "$VARNISH_PKG_VERSION" -gt "40" ]; then
    VARNISH_DEVEL_LIB_NAME=varnish-devel
else
    VARNISH_DEVEL_LIB_NAME=varnish-libs-devel
fi

MODULE=${MODULE:-}

BASE_IMAGE=$IMAGE_OWNER/varnish-base:$VARNISH_VERSION-centos-$CENTOS_VERSION_MINOR
VARNISH_DEVEL_IMAGE="$IMAGE_OWNER/varnish-devel:$VARNISH_VERSION-centos-$CENTOS_VERSION_MINOR"
VARNISH_IMAGE="$IMAGE_OWNER/varnish:$VARNISH_VERSION-centos-$CENTOS_VERSION_MINOR"

# benchmark settings
NETWORK=${NETWORK:-'benchmark'}
METHOD=${METHOD:-'GET'}
CONCURRENT=${CONCURRENT:-30}
NR_OF_REQUESTS=${NR_OF_REQUESTS:-50000}

line
echo VARIABLES:
line -
echo "CENTOS_VERSION: $CENTOS_VERSION"
echo "CENTOS_VERSION_MINOR: $CENTOS_VERSION_MINOR"
echo "CENTOS_VERSION_MAJOR: $CENTOS_VERSION_MAJOR"
echo "VARNISH_VERSION: $VARNISH_VERSION"
echo "VARNISH_VERSION_MINOR: $VARNISH_VERSION_MINOR"
echo "VARNISH_COMPATIBILITY_VERSION: $VARNISH_COMPATIBILITY_VERSION"
echo "VARNISH_RELEASE: $VARNISH_RELEASE"
echo "VARNISH_PKG_VERSION: $VARNISH_PKG_VERSION"
echo "VARNISH_DEVEL_LIB_NAME: $VARNISH_DEVEL_LIB_NAME"
echo "IMAGE_OWNER: $IMAGE_OWNER"
echo "MODULE: $MODULE"
echo "BASE_IMAGE: $BASE_IMAGE"
echo "VARNISH_DEVEL_IMAGE: $VARNISH_DEVEL_IMAGE"
echo "VARNISH_IMAGE: $VARNISH_IMAGE"