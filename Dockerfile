ARG VARNISH_IMAGE
FROM $VARNISH_IMAGE

USER root

ARG MODULES_DIR
ADD $MODULES_DIR/ /opt/modules/

RUN yum install -y uuid

RUN rpm -ivh $(find /opt/modules -regex ".*\.\rpm")

RUN varnishd -V

USER varnish


