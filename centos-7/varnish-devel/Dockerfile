ARG BASE_IMAGE
ARG CENTOS_VERSION_MAJOR
# FROM rpmbuild/centos${CENTOS_VERSION_MAJOR}
FROM $BASE_IMAGE

ARG CENTOS_VERSION_MAJOR
ARG VARNISH_VERSION
ARG VARNISH_DEVEL_LIB_NAME

# RUN yum install -y epel-release 

# RUN curl -s https://packagecloud.io/install/repositories/varnishcache/varnish${VARNISH_PKG_VERSION}/script.rpm.sh -o script.sh && os=el dist=${CENTOS_VERSION_MAJOR} source ./script.sh

RUN yum install -y \
    git \
    gcc \
    glibc-devel \
    glibc-static \
    libaio-devel \
    make \
    autoconf \
    automake \
    m4 \
    jemalloc-devel \
    libedit-devel \
    libtool \
    ncurses-devel \
    pcre-devel \
    pkgconfig \
    python-docutils \
    python-sphinx \ 
    wget \
    rpm-build \
    rpmdevtools \
    check-devel \
    sudo \
    varnish-${VARNISH_VERSION}.el${CENTOS_VERSION_MAJOR}.x86_64 \
    ${VARNISH_DEVEL_LIB_NAME}-${VARNISH_VERSION}.el${CENTOS_VERSION_MAJOR}.x86_64

RUN mkdir /varnish && mkdir /varnish/varnish-cache && \
    wget https://github.com/varnishcache/varnish-cache/archive/varnish-${VARNISH_VERSION%-*}.tar.gz -O varnish.tar.gz && \
    tar -xvf varnish.tar.gz -C /varnish/varnish-cache --strip-components=1

RUN useradd -u 1000 builder
RUN usermod -a -G wheel,builder builder

RUN echo 'builder ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo

USER builder

ENV BASH_ENV=/opt/export_LANG.sh \
    ENV=/opt/export_LANG.sh \
    PROMPT_COMMAND="source /opt/export_LANG.sh"

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# RUN rm -rf /root/.rpmmacros

# set up the build environment
# RUN cd /home/builder && mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
WORKDIR /home/builder
RUN rpmdev-setuptree
RUN rm -rf /home/builder/.rpmmacros
# RUN mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

CMD [ "bin/bash" ]





