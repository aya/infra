COMPOSE_VERSION                 ?= 1.22.0
COMPOSE_PROJECT_NAME            ?= $(ENV)_$(APP)
COMPOSE_SERVICE_NAME            ?= $(ENV)-$(APP)
DOCKER_BUILD_ARGS               += GID=$(GID) UID=$(UID) USER=$(USER)
DOCKER_BUILD_TARGET             ?= local
DOCKER_COMPOSE_DOWN_OPTIONS     ?=
DOCKER_IMAGE_REPO               ?= $(USER)
DOCKER_IMAGE_RUN                ?= infra/exec
DOCKER_IMAGE_TAG                ?= $(or $(TAG), $(ENV))
DOCKER_IMAGE_SSH                ?= infra/ssh-agent
DOCKER_NETWORK                  ?= $(ENV)
DOCKER_RUN_OPTIONS              ?= --rm -it
DOCKER_RUN_VOLUME               ?= -v $$PWD:$$PWD
DOCKER_RUN_WORKDIR              ?= -w $$PWD

ifneq ($(DOCKER_BUILD_TARGET), local)
DOCKER_BUILD_ARGS               += BRANCH=$(BRANCH) COMMIT=$(COMMIT) TAG=$(TAG)
endif

ifeq ($(DOCKER), true)

ifeq ($(DRONE), true)
DOCKER_RUN_OPTIONS              := --rm
DOCKER_RUN_VOLUME               := -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(hostname) 2>/dev/null |awk 'BEGIN {FS=":"} $$0 ~ /_default:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone
ENV_SUFFIX                      := $(DRONE_BUILD_NUMBER)
ifneq ($(APP), infra)
COMPOSE_PROJECT_NAME            := $(ENV)_$(ENV_SUFFIX)_$(APP)
COMPOSE_SERVICE_NAME            := $(ENV)-$(ENV_SUFFIX)-$(APP)
endif
else
DOCKER_RUN_VOLUME               := -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD
endif

define docker-compose
	docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) docker/compose:$(COMPOSE_VERSION) $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) docker/compose:$(COMPOSE_VERSION) $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)'
endef
define docker-run
	docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1) $(2)
endef
define exec
	docker exec $(patsubst %,-e %,$(ENV_SYSTEM)) $(ENV)_$(subst /,_,$(DOCKER_IMAGE_RUN))_1 sh -c '$(1)'
endef
define run
	docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(ENV)_$(subst /,_,$(DOCKER_IMAGE_SSH)):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) ${DOCKER_IMAGE_REPO}/${DOCKER_IMAGE_RUN}:${DOCKER_IMAGE_TAG} sh -c '$(1)'
endef

else

SHELL := /bin/bash
define docker-compose
	IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$1 ~! /^\(#|$\)/') docker-compose $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$1 ~! /^\(#|$\)/') docker-compose $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) exec $(1) sh -c '$(2)'
endef
define docker-run
	docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1) $(2)
endef
define exec
	IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') sh -c '$(1)'
endef
define run
	IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') sh -c '$(1)'
endef

endif
