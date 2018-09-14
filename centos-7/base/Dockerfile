ARG CENTOS_VERSION
FROM centos:$CENTOS_VERSION

RUN yum install -y epel-release

RUN yum -y reinstall glibc-common

# A solution for https://github.com/CentOS/sig-cloud-instance-images/issues/15
# RUN yum install -y yum-plugin-ovl

ARG VARNISH_PKG_VERSION
ARG CENTOS_VERSION_MAJOR
ARG VARNISH_VERSION

RUN if [ "$VARNISH_PKG_VERSION" -gt "40" ]; then \
        curl -s https://packagecloud.io/install/repositories/varnishcache/varnish${VARNISH_PKG_VERSION}/script.rpm.sh -o script.sh && os=el dist=${CENTOS_VERSION_MAJOR} source ./script.sh; \
    fi

# RUN curl -s https://packagecloud.io/install/repositories/varnishcache/varnish${VARNISH_PKG_VERSION}/script.rpm.sh -o script.sh && os=el dist=${CENTOS_VERSION_MAJOR} source ./script.sh

# Set a useful default locale
RUN echo "export LANG=en_US.utf-8" > /opt/export_LANG.sh
ENV BASH_ENV=/opt/export_LANG.sh \
    ENV=/opt/export_LANG.sh \
    PROMPT_COMMAND="source /opt/export_LANG.sh"