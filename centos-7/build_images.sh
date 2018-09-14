#!/bin/bash

. ./.env

VARNISH_DEVEL_IMAGE="$IMAGE_OWNER/varnish-devel:$VARNISH_VERSION-centos-$CENTOS_VERSION_MINOR"
VARNISH_IMAGE="$IMAGE_OWNER/varnish:$VARNISH_VERSION-centos-$CENTOS_VERSION_MINOR"

echo "VARNISH_DEVEL_IMAGE: $VARNISH_DEVEL_IMAGE"
echo "VARNISH_IMAGE: $VARNISH_IMAGE"
line

# Base image for Varnish runtime.
docker build \
    --build-arg CENTOS_VERSION=${CENTOS_VERSION} \
    --build-arg CENTOS_VERSION_MAJOR=${CENTOS_VERSION_MAJOR} \
    --build-arg VARNISH_VERSION=${VARNISH_VERSION} \
    --build-arg VARNISH_PKG_VERSION=${VARNISH_PKG_VERSION} \
    -t $BASE_IMAGE \
    base

# Development image for Varnish modules RPM building.
docker build \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg CENTOS_VERSION_MAJOR=$CENTOS_VERSION_MAJOR \
    --build-arg VARNISH_VERSION=$VARNISH_VERSION \
    --build-arg VARNISH_DEVEL_LIB_NAME=${VARNISH_DEVEL_LIB_NAME} \
    -t $VARNISH_DEVEL_IMAGE \
    varnish-devel

# Varnish runtime image
docker build \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg CENTOS_VERSION_MAJOR=$CENTOS_VERSION_MAJOR \
    --build-arg VARNISH_VERSION=$VARNISH_VERSION \
    --build-arg VARNISH_PKG_VERSION=${VARNISH_PKG_VERSION} \
    -t $VARNISH_IMAGE \
    varnish