ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG CENTOS_VERSION_MAJOR
ARG VARNISH_VERSION
ARG VARNISH_PKG_VERSION

RUN if [ "$VARNISH_PKG_VERSION" -le "40" ]; then \
        useradd varnish; \
        usermod -a -G varnish varnish; \
    fi; \
    yum install -y varnish-${VARNISH_VERSION}.el${CENTOS_VERSION_MAJOR}.x86_64

RUN mkdir -p /etc/varnish && echo "0fa4bbc5-7f35-4fc4-bbea-b0a3db51d913" > /etc/varnish/secret && chmod 600 /etc/varnish/secret

RUN  if [ "$VARNISH_PKG_VERSION" -gt "40" ]; then \
        chown -R varnish:varnish /etc/varnish /var/lib/varnish /var/run/; \
     fi

USER varnish

COPY ${PWD}/start.sh /usr/sbin/start-varnish

CMD [ "start-varnish" ]




