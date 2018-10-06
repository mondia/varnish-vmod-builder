#!/bin/bash
DIRNAME=$(dirname "$BASH_SOURCE")
DIRNAMEE_SANITIZED=${DIRNAME//.\/}
BASEDIR=$(pwd)/${DIRNAMEE_SANITIZED}

. $BASEDIR/.env
. $BASEDIR/../defaults.sh

mkdir -p $BASEDIR/dist/${VARNISH_COMPATIBILITY_VERSION}/src-rpm
mkdir -p $BASEDIR/dist/${VARNISH_COMPATIBILITY_VERSION}/debug-rpm
mkdir -p $BASEDIR/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm

if [ -z ${MODULE+x} ]; then
    RE="*."
    REX="*."
else
    RE="("
    REX=".*\("
    IFS="," read -ra MODULES <<< "$MODULE"
    for i in "${MODULES[@]}"; do
        if [ "$RE" != "(" ]; then
            RE="${RE}|"
            REX="${REX}\|"
        fi
        RE="${RE}${i}"
        REX="${REX}${i}"
    done
    RE="${RE})"
    REX="${REX}\).*"
fi

docker run -it --rm -v "$BASEDIR/vmods:/opt/modules/vmods" \
    -v "$BASEDIR/dist:/opt/modules/dist" \
    -v "$BASEDIR/docker_inline.sh:/opt/modules/docker_inline.sh" \
    -e "MODULE=${MODULE}" \
    -e "VARNISH_VERSION=${VARNISH_VERSION}" \
    -e "VARNISH_COMPATIBILITY_VERSION=${VARNISH_COMPATIBILITY_VERSION}" \
    -e "VARNISH_PKG_VERSION=${VARNISH_PKG_VERSION}" \
    -e "VARNISH_RELEASE=${VARNISH_RELEASE}" \
    -e "VARNISH_DEVEL_LIB_NAME=${VARNISH_DEVEL_LIB_NAME}" \
    -e "CENTOS_VERSION_MAJOR=${CENTOS_VERSION_MAJOR}" \
    -e "RE=${RE}" \
    -e "FORCE=${FORCE}" \
    $VARNISH_DEVEL_IMAGE /opt/modules/docker_inline.sh

line
echo "BUILT RPMs ($BASEDIR/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm/):"
line -
ls -l $BASEDIR/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm/ | grep "${REX}"
# find . -regex ".*\/${VARNISH_COMPATIBILITY_VERSION}\/rpm\/.*\.\rpm"
line