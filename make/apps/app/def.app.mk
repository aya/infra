BUILD_APP_VARS                  ?= APP BRANCH COMMIT DEPLOY_SLACK_HOOK ENV SYMFONY_ENV TAG VERSION
CONTEXT                         += COMPOSER_ARGS
COMPOSE_IGNORE_ORPHANS          ?= false
COMPOSER_ARGS                   ?= --optimize-autoloader
COMPOSER_MEMORY_LIMIT           ?= -1
DOCKER_SERVICE                  ?= php
ENV_VARS                        += CONSUL_HTTP_TOKEN MOUNT_NFS_CONFIG
MOUNT_NFS                       ?= false
MOUNT_SSH                       ?= true

ifneq ($(SUBREPO),)
MOUNT_SUBREPO                   ?= true
else
MOUNT_APP                       ?= true
endif

ifeq ($(MOUNT_NFS),true)
MOUNT_NFS_CONFIG                ?= addr=$(MOUNT_NFS_HOST),actimeo=3,intr,noacl,noatime,nocto,nodiratime,nolock,soft,rsize=32768,wsize=32768,tcp,rw,vers=3
MOUNT_NFS_HOST                  ?= host.docker.internal
endif

ifneq (,$(filter $(ENV),prod preprod))
MOUNT_TMPFS                     ?= false
SYMFONY_ENV                     ?= prod
else
MOUNT_TMPFS                     ?= true
SYMFONY_ENV                     ?= dev
endif
