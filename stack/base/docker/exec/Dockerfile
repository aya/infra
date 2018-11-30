FROM alpine:latest as dist

LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

arg GIT_AUTHOR_NAME
arg GIT_AUTHOR_EMAIL

env GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-1001Pharmacies}
env GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-technique+docker@1001pharmacies.com}
env GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
env GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}

RUN apk upgrade --no-cache \
 && apk add --no-cache \
        bash \
        git \
        make \
        openssh \
        sudo

RUN git clone https://github.com/ingydotnet/git-subrepo \
 && cd git-subrepo \
 && git fetch origin +refs/heads/release/0.4.0: \
 && git checkout release/0.4.0 \
 && git fetch origin pull/314/head \
 && git rebase a53e7a7c7ac429ec8a448f0cca4d113c14c123fd \
 && sed -i 's/install -C/install/' Makefile \
 && make install \
 && cd .. \
 && rm -rf git-subrepo

RUN echo -e "\n\
Host *\n\
  LogLevel quiet\n\
  StrictHostKeyChecking no\n\
  UserKnownHostsFile /dev/null\n\
Host github.com\n\
  Compression yes\
" >> /etc/ssh/ssh_config

CMD ["bash"]

FROM dist as local
ARG UID
ARG GID
ARG USER
ENV UID=${UID}
ENV GID=${UID}
ENV USER=${USER}

# If we provide a specific UID
RUN let $UID >/dev/null 2>&1 \
# Remove user with $UID if it is not our $USER
 && if [ "$(getent passwd $UID |awk 'BEGIN {FS=":"} {print $1}')" != "$USER" ]; then \
      sed -i '/^'$(getent passwd $UID |awk 'BEGIN {FS=":"} {print $1}')':x:'$UID':/d' /etc/passwd; \
      sed -i '/^'$(getent group $GID |awk 'BEGIN {FS=":"} {print $1}')':x:'$GID':/d' /etc/group; \
    fi \
# Force $UID if our $USER already exists
 && sed -i 's/^'$USER':x:[0-9]\+:[0-9]\+:/'$USER':x:'$UID':'$GID':/' /etc/passwd \
 && sed -i 's/^'$USER':x:[0-9]\+:/'$USER':x:'$GID':/' /etc/group \
# Create $USER if it does not exist
 && if [ "$(getent passwd $UID)" = "" ]; then \
      echo "$USER:x:$UID:$GID::/home/$USER:/bin/false" >> /etc/passwd; \
      echo "$USER:!:$(($(date +%s) / 60 / 60 / 24)):0:99999:7:::" >> /etc/shadow; \
      echo "$USER:x:$GID:" >> /etc/group; \
    fi \
 && mkdir -p /home/$USER \
 && chown $UID:$GID /home/$USER \
 || true

USER $USER
WORKDIR /home/$USER

FROM local as tests
USER root

RUN apk add --no-cache \
        docker

USER $USER

ARG BRANCH
ARG COMMIT
ARG TAG
LABEL com.1001pharmacies.branch=${BRANCH}
LABEL com.1001pharmacies.commit=${COMMIT}
LABEL com.1001pharmacies.tag=${TAG}
LABEL com.1001pharmacies.user=${USER}
