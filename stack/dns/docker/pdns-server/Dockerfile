FROM alpine:3.7
LABEL maintainer "yann.autissier@gmail.com"
ARG VERSION_PDNS_REC=4.1.4
ARG VERSION_PDNS_AUTH=4.1.4
ARG VERSION_PDNS_DNSDIST=1.3.2

RUN apk upgrade --no-cache \
 && apk add --no-cache --virtual build-deps \
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
        py-virtualenv \
        libedit-dev \
        libressl-dev \
        libstdc++ \
        libtool \
        lua-dev \
        make \
        musl \
        ragel \
 && git clone https://github.com/PowerDNS/pdns \
 && cd pdns \
 && git checkout tags/auth-${VERSION_PDNS_AUTH} -b auth-${VERSION_PDNS_AUTH} \
 && autoreconf -vi \
 && ./configure --enable-static --disable-systemd --without-systemd --with-modules="" \
 && make install clean \
 && git checkout tags/rec-${VERSION_PDNS_REC} -b rec-${VERSION_PDNS_REC} \
 && cd pdns/recursordist \
 && autoreconf -vi \
 && ./configure --enable-static --disable-systemd --without-systemd \
 && make install clean \
 && cd ../.. \
 && git checkout tags/dnsdist-${VERSION_PDNS_DNSDIST} -b dnsdist-${VERSION_PDNS_DNSDIST} \
 && cd pdns/dnsdistdist \
 && autoreconf -vi \
 && ./configure --enable-static --disable-systemd --without-systemd \
 && make install clean \
 && cd ../../.. \
 && rm -fr pdns \
 && apk del build-deps

RUN apk add --no-cache \
        boost \
        libressl2.6-libcrypto \
        libstdc++ \
        libedit \
        lua

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 53/udp 53/tcp
