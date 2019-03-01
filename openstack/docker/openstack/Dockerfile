FROM alpine:latest

RUN apk --no-cache add libffi openssl python py-pip py-netifaces

RUN apk --no-cache add --virtual .build-deps \
        build-base \
        libffi-dev \
        openssl-dev \
        python-dev \
 && pip install --upgrade pip \
 && pip install python-openstackclient \
 && apk del .build-deps

RUN apk --no-cache upgrade

ENTRYPOINT ["/usr/bin/openstack"]
CMD ["help"]

