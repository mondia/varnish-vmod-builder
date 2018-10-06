#!/bin/bash

VMODS=$(ls -d /opt/modules/vmods/* | awk -F'/' '{print $5}')
ARCH=$(uname -m)
DIST="el${CENTOS_VERSION_MAJOR}"

function line {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ${1:-=}
}

for VMOD in $VMODS ; do
    if [[ $VMOD =~ $RE ]]; then
        if [ -z "${FORCE}" ] && [ -e /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm/${VMOD}-${VARNISH_VERSION}.${DIST}.${ARCH}.rpm ]; then
            line -
            echo "Building $VMOD... exists! SKIPPED. Use 'FORCE=1' to enforce rebuild."
            # line -
            continue
        else
            # delete previously built rpms
            sudo rm -rf /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm/$VMOD*
            sudo rm -rf /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/debug-rpm/$VMOD*
            sudo rm -rf /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/src-rpm/$VMOD*
        fi

        VMOD_USE_GIT=0
        unset VMOD_BRANCH
        unset VMOD_VERSION
        unset VMOD_REPO_URL
        unset AUTOGEN
        unset VMOD_LIBS
        unset V${VARNISH_PKG_VERSION}
        line -
        echo "Building $VMOD..."
        . /opt/modules/vmods/$VMOD/.env

        # resolve version mapping
        if [ -f /opt/modules/vmods/$VMOD/version_map.env ]; then
            echo "Using a version map.."
            source /opt/modules/vmods/$VMOD/version_map.env
            eval VER=\$V${VARNISH_PKG_VERSION}
            echo "VER=$VER"
            VMOD_VERSION=${VER:-$VMOD_VERSION}
        fi
        if [[ "$VMOD_VERSION" =~ https?:\/\/.*$ ]]; then
            VMOD_REPO_URL=$VMOD_VERSION
            VMOD_VERSION=$VARNISH_COMPATIBILITY_VERSION
        else
            VMOD_REPO_URL=${VMOD_REPO_URL/VERSION/$VMOD_VERSION}
        fi
        echo "VMOD_VERSION=$VMOD_VERSION"
        echo "VMOD_REPO_URL=$VMOD_REPO_URL"
        line

        AUTOGEN=${VMOD_AUTOGEN:-autogen.sh}
        if [ -z ${VMOD_LIBS+x} ]; then
            echo "No dependency libs defined in VMOD_LIBS"
        else 
            echo "Installing dependencies: $VMOD_LIBS"
            sudo yum install -y $VMOD_LIBS
        fi
        # if [ "$VMOD_USE_GIT"  -eq "1" ]; then
        #     VMOD_BRANCH=${VMOD_BRANCH:-"master"}
        #     git clone
        # else
        wget $VMOD_REPO_URL -O $VMOD.tar.gz;
        # fi
        mkdir $VMOD
        tar -xvf $VMOD.tar.gz --strip 1 -C ./$VMOD
        cp /varnish/varnish-cache/m4/* ./$VMOD/m4
        export VARNISHSRC=/varnish/varnish-cache
        if [ ! -f /opt/modules/vmods/$VMOD/vmod.spec ]; then
            cd ./$VMOD
            ./$AUTOGEN
            ./configure VARNISHSRC=/varnish/varnish-cache
            make
            make -j4 check
            sudo make install
            cd ..
        else
            echo VARNISH_COMPAT=$VARNISH_COMPATIBILITY_VERSION
            SPEC_NAME=$(awk '/Name:/' /opt/modules/vmods/$VMOD/vmod.spec | awk '{print $2}')
            cp /opt/modules/vmods/$VMOD/vmod.spec rpmbuild/SPECS/${SPEC_NAME}.spec
            tar -czvf rpmbuild/SOURCES/${SPEC_NAME}-${VMOD_VERSION}.tar.gz --transform "s/$VMOD/${SPEC_NAME}-${VMOD_VERSION}/" ./$VMOD
            rpmbuild -ba -D "dist .${DIST}" \
                -D "_version ${VMOD_VERSION}" \
                -D "_release ${VARNISH_RELEASE:-1}" \
                -D "_varnish_version ${VARNISH_COMPATIBILITY_VERSION}" \
                -D "_varnish_devel ${VARNISH_DEVEL_LIB_NAME}" \
                -D "dist .${DIST}" \
                -D "_autogen ${AUTOGEN}" \
                -D 'VARNISHSRC /varnish/varnish-cache' \
                rpmbuild/SPECS/${SPEC_NAME}.spec
            sudo cp /home/builder/rpmbuild/RPMS/$ARCH/${SPEC_NAME}-${VARNISH_COMPATIBILITY_VERSION}*.rpm /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm/
            sudo cp /home/builder/rpmbuild/RPMS/$ARCH/${SPEC_NAME}-debuginfo-${VARNISH_COMPATIBILITY_VERSION}*.rpm /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/debug-rpm/
            sudo cp /home/builder/rpmbuild/SRPMS/${SPEC_NAME}-${VARNISH_COMPATIBILITY_VERSION}*.src.rpm /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/src-rpm/
        fi
    fi
done
