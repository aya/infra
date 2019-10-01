FROM consul:1.6.1 as dist

LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

# install docker
RUN apk add --no-cache docker bash \
 && adduser consul docker

# install goss
ADD https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 /usr/bin/goss
RUN chmod +rx /usr/bin/goss
COPY docker/consul/goss.yml /tests/goss.yml

COPY docker/consul/check-container-status /usr/local/bin
RUN chmod +rx /usr/local/bin/check-container-status

HEALTHCHECK CMD goss -g /tests/goss.yml validate --format json_oneline
