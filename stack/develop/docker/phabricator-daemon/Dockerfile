FROM phabricator/daemon:latest as dist
LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        openssh-client \
 && rm -rf /var/lib/apt/lists/*

