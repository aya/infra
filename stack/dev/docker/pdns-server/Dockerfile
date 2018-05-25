FROM alpine:latest
LABEL maintainer "yann.autissier@1001pharmacies.com"
ENV PDNS_RECURSOR_VERSION 4.0.6
ENV PDNS_AUTHORITATIVE_VERSION 4.0.4

RUN apk add --no-cache --virtual .builddeps \
        autoconf \
        automake \
        bison \
        boost-dev \
        boost-program_options \
        boost-serialization \
        build-base \
        curl \
        file \
        flex \
        g++ \
        git \
        openssl-dev \
        libstdc++ \
        libtool \
        make \
        musl \
        ragel \
 && git clone https://github.com/PowerDNS/pdns \
 && cd pdns \
 && git checkout tags/auth-${PDNS_AUTHORITATIVE_VERSION} -b auth-${PDNS_AUTHORITATIVE_VERSION} \
 && ./bootstrap \
 && ./configure --with-modules="" --without-lua \
 && make \
 && make install clean \
 && git checkout tags/rec-${PDNS_RECURSOR_VERSION} -b rec-${PDNS_RECURSOR_VERSION} \
 && cd pdns/recursordist \
 && ./bootstrap \
 && ./configure \
 && make \
 && make install \
 && cd ../../.. \
 && rm -fr pdns \
 && apk del .builddeps

RUN apk add --no-cache \
        boost \
        libcrypto1.0 \
        libstdc++

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 53/udp 53/tcp
