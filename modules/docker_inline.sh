#!/bin/bash

VMODS=$(ls -d /opt/modules/vmods/* | awk -F'/' '{print $5}')
ARCH=$(uname -m)
RE=${MODULE:-'.*'}

function line {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

for VMOD in $VMODS ; do
    if [[ $VMOD =~ $RE ]]; then
        line
        echo "Building $VMOD..."
        . /opt/modules/vmods/$VMOD/.env

        # resolve version mapping
        if [ -f /opt/modules/vmods/$VMOD/version_map.env ]; then
            echo "Using a version map.."
            source /opt/modules/vmods/$VMOD/version_map.env
            eval VER=\$V${VARNISH_PKG_VERSION}
            VMOD_VERSION=${VER:-$VMOD_VERSION}
        fi
        echo "VMOD_VERSION=$VMOD_VERSION"
        VMOD_REPO_URL=${VMOD_REPO_URL/VERSION/$VMOD_VERSION}
        echo "VMOD_REPO_URL=$VMOD_REPO_URL"
        line

        AUTOGEN=${VMOD_AUTOGEN:-autogen.sh}
        if [ -z ${VMOD_LIBS+x} ]; then
            echo "No dependency libs defined in VMOD_LIBS"
        else 
            echo "Installing dependencies: $VMOD_LIBS"
            sudo yum install -y $VMOD_LIBS
        fi
        wget $VMOD_REPO_URL -O $VMOD.tar.gz
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
                -D "dist .el${CENTOS_VERSION_MAJOR}" \
                -D "_autogen ${AUTOGEN}" \
                -D 'VARNISHSRC /varnish/varnish-cache' \
                rpmbuild/SPECS/${SPEC_NAME}.spec
            sudo cp /home/builder/rpmbuild/RPMS/$ARCH/${SPEC_NAME}-${VARNISH_COMPATIBILITY_VERSION}*.rpm /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/rpm/
            sudo cp /home/builder/rpmbuild/RPMS/$ARCH/${SPEC_NAME}-debuginfo-${VARNISH_COMPATIBILITY_VERSION}*.rpm /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/debug-rpm/
            sudo cp /home/builder/rpmbuild/SRPMS/${SPEC_NAME}-${VARNISH_COMPATIBILITY_VERSION}*.src.rpm /opt/modules/dist/${VARNISH_COMPATIBILITY_VERSION}/src-rpm/
        fi
    fi
done
