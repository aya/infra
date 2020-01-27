FROM phabricator/phabricator:latest as dist
LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>
ARG DOCKER_BUILD_DIR

RUN { \
        echo 'mysqli.allow_local_infile = 0'; \
    } > /usr/local/etc/php/conf.d/mysql.ini

FROM dist as local
ARG DOCKER_BUILD_DIR
