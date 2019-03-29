FROM phabricator/phabricator:latest as dist
LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

RUN { \
        echo 'mysqli.allow_local_infile = 0'; \
    } > /usr/local/etc/php/conf.d/mysql.ini
