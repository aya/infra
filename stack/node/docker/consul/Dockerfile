FROM consul:1.6.1 as dist

LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

# install docker
RUN apk add --no-cache bash docker gawk sudo \
 && echo "consul ALL=(root) NOPASSWD: /usr/local/bin/container-list-status" >> /etc/sudoers

# install goss
ADD https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 /usr/bin/goss
RUN chmod +rx /usr/bin/goss
COPY docker/consul/goss.yml /tests/goss.yml

COPY docker/consul/container-check-status docker/consul/container-list-status /usr/local/bin/
RUN chmod +rx /usr/local/bin/container-check-status /usr/local/bin/container-list-status

HEALTHCHECK CMD goss -g /tests/goss.yml validate --format tap
