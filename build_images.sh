#!/bin/bash
. ./defaults.sh
cd ./centos-$CENTOS_VERSION_MAJOR
. ./build_images.sh
cd ..