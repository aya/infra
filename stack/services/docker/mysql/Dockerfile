FROM mariadb:10.4.8-bionic as dist

LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

# config
COPY docker/mysql/conf.d/all.cnf /etc/mysql/conf.d/

# install goss
ADD https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 /usr/bin/goss
RUN chmod +rx /usr/bin/goss
COPY docker/mysql/goss.yml /tests/goss.yml

HEALTHCHECK CMD goss -g /tests/goss.yml validate --format json_oneline

FROM dist as local

# config
COPY docker/mysql/conf.d/local.cnf /etc/mysql/conf.d/
