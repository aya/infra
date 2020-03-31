BUILD_APP_VARS                  ?= APP BRANCH COMMIT DEPLOY_SLACK_HOOK ENV SYMFONY_ENV TAG VERSION
CONTEXT                         += COMPOSER_ARGS COMPOSE_PROJECT_NAME DOCKER_SERVICE
COMPOSE_IGNORE_ORPHANS          ?= false
COMPOSER_ARGS                   ?= --optimize-autoloader
COMPOSER_MEMORY_LIMIT           ?= -1
DOCKER_SERVICE                  ?= php
ENV_VARS                        += CONSUL_HTTP_TOKEN MOUNT_NFS_CONFIG
MOUNT_NFS                       ?= false
MOUNT_SSH                       ?= true

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

ifeq ($(SYMFONY_ENV), prod)
COMPOSER_ARGS                   += --classmap-authoritative --prefer-dist --no-dev --no-interaction
endif
ifeq ($(DRONE), true)
COMPOSER_ARGS                   += --no-progress
endif

define composer
	$(call docker-compose-exec,$(DOCKER_SERVICE),COMPOSER_MEMORY_LIMIT=$(COMPOSER_MEMORY_LIMIT) SYMFONY_ENV=$(SYMFONY_ENV) composer $(1) $(COMPOSER_ARGS))
endef

define composer-require-vendor-binary
	$(eval vendor:=$(1))
	$(eval binary:=$(or $(2),$(lastword $(subst /, ,$(vendor)))))
	$(eval version:=$(or $(addprefix :,$(3)),$(shell awk '/'$(subst /,\\/,$(vendor))'/ {gsub("[\",]","",$$2); print ":"$$2}' composer.json 2>/dev/null)))
	$(eval DRYRUN_IGNORE := true)
	$(call docker-compose-exec,$(DOCKER_SERVICE),[ -f vendor/$(vendor)/$(binary) ]) || \
	$(ECHO) $(call docker-compose-exec,$(DOCKER_SERVICE),mkdir -p vendor/$(vendor) && cd /tmp && COMPOSER_MEMORY_LIMIT=$(COMPOSER_MEMORY_LIMIT) SYMFONY_ENV=$(SYMFONY_ENV) composer require "$(vendor)$(version)" --prefer-source --no-interaction --dev && cd - && ln -s /tmp/vendor/$(vendor)/$(binary) vendor/$(vendor)/$(binary))
	$(eval DRYRUN_IGNORE := false)
endef
